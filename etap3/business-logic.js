db = connect(
  "mongodb://admin:password123@localhost:27017/football?authSource=admin",
);

function getNextSequenceValue(sequenceName) {
  const sequenceDocument = db
    .collection("counters")
    .findOneAndUpdate(
      { _id: sequenceName },
      { $inc: { sequence_value: 1 } },
      { returnDocument: "after" },
    );

  return sequenceDocument.sequence_value;
}

function addPlayer(playerData) {
  try {
    // walidacje

    const newPlayerId = getNextSequenceValue("player_id");

    playerData.player_id = newPlayerId;

    return db.collection("players").insertOne(playerData);
  } catch (e) {
    console.error("Błąd podczas dodawania gracza:", e);
  }
}

function findPlayerByName(name) {
  const cursor = db.players.find({
    name: { $regex: name, $options: "i" },
  });

  const count = cursor.count();

  if (count === 0) {
    print("Nie znaleziono żadnego zawodnika.");
    return;
  }

  print(`Znaleziono ${count} pasujących wyników:\n`);
  print(
    cursor.map((x) => {
      delete x["appearances"];
      delete x["market_value_history"];
      return x;
    }),
  );
}

function findPolishPlayers() {
  var query = db.players.aggregate([
    {
      $match: {
        country_of_citizenship: "Poland",
        highest_market_value_in_eur: { $gte: 50000000 },
      },
    },
    { $sort: { highest_market_value_in_eur: -1 } },
    { $project: { name: 1, last_season: 1, highest_market_value_in_eur: 1 } },
  ]);

  print(query);
}

function insertTransfer(playerId, targetClubId, fee, season) {
  const session = db.getMongo().startSession();
  session.startTransaction();

  try {
    const database = session.getDatabase(db.getName());
    const playersColl = database.getCollection("players");
    const clubsColl = database.getCollection("clubs");
    const transfersColl = database.getCollection("transfers");

    const pId = NumberInt(playerId);
    const cId = NumberInt(targetClubId);

    print(
      `>>> Rozpoczynam transfer zawodnika ID: ${pId} do klubu ID: ${cId}...`,
    );

    const player = playersColl.findOne({ player_id: pId });
    if (!player) {
      throw new Error(`Nie znaleziono zawodnika o ID ${pId}`);
    }

    if (player.current_club_id === cId) {
      throw new Error(`Zawodnik ${player.name} już gra w klubie docelowym.`);
    }

    const oldClubId = player.current_club_id
      ? NumberInt(player.current_club_id)
      : null;
    let oldClub = null;
    let fromClubName = "Bez klubu / Nieznany";

    if (oldClubId) {
      oldClub = clubsColl.findOne({ club_id: oldClubId });
      if (oldClub) {
        fromClubName = oldClub.name;
      }
    }

    const newClub = clubsColl.findOne({ club_id: cId });
    if (!newClub) {
      throw new Error(`Nie znaleziono klubu docelowego o ID ${cId}`);
    }

    const transferDoc = {
      from_club_id: oldClubId || NumberInt(-1),
      from_club_name: fromClubName,
      player_id: pId,
      player_name: player.name,
      to_club_id: cId,
      to_club_name: newClub.name,
      transfer_date: new Date(),
      transfer_fee: Double(fee),
      transfer_season: season,
      market_value_in_eur: player.market_value_in_eur
        ? Double(player.market_value_in_eur)
        : null,
    };

    const insertResult = transfersColl.insertOne(transferDoc);
    if (!insertResult.acknowledged) {
      throw new Error("Nie udało się zapisać rekordu transferu.");
    }

    const updatePlayerResult = playersColl.updateOne(
      { player_id: pId },
      {
        $set: {
          current_club_id: cId,
          current_club_name: newClub.name,
          current_club_domestic_competition_id: newClub.domestic_competition_id,
        },
      },
    );

    if (updatePlayerResult.modifiedCount === 0) {
      throw new Error("Nie udało się zaktualizować danych zawodnika.");
    }

    // Aktualizacja liczebności zespołów
    if (oldClub) {
      clubsColl.updateOne(
        { club_id: oldClubId },
        { $inc: { squad_size: NumberInt(-1) } },
      );
    }

    clubsColl.updateOne(
      { club_id: cId },
      { $inc: { squad_size: NumberInt(1) } },
    );

    session.commitTransaction();
    print("Transfer zakończony sukcesem!");
    print(
      `   ${player.name} przeszedł z ${fromClubName} do ${newClub.name} za ${fee} EUR.`,
    );
  } catch (error) {
    print("Wystąpił błąd. Wycofywanie transakcji...");
    session.abortTransaction();
    print(`   Powód: ${error.message}`);
    print(error);
  } finally {
    session.endSession();
  }
}

function updateMarketValue(playerId, value) {
  const session = db.getMongo().startSession();
  session.startTransaction();

  const database = session.getDatabase(db.getName());
  const playersColl = database.getCollection("players");

  try {
    const pId = NumberInt(playerId);
    const newValue = NumberInt(value);

    const player = playersColl.findOne({ player_id: pId });
    if (!player) {
      throw new Error(`Nie znaleziono zawodnika o ID ${pId}`);
    }

    print(`>>> Aktualizacja wartości rynkowej dla: ${player.name}...`);

    const currentHighest = player.highest_market_value_in_eur || 0;
    const newHighest =
      newValue > currentHighest ? newValue : NumberInt(currentHighest);

    const todayStr = new Date().toISOString().split("T")[0];

    const historyEntry = {
      date: todayStr,
      market_value_in_eur: newValue,
    };

    const updateResult = playersColl.updateOne(
      { player_id: pId },
      {
        $set: {
          market_value_in_eur: newValue,
          highest_market_value_in_eur: newHighest,
        },
        $push: {
          market_value_history: historyEntry,
        },
      },
    );

    if (updateResult.modifiedCount === 0) {
      throw new Error(
        "Nie udało się zaktualizować danych (brak zmian lub błąd zapisu).",
      );
    }

    session.commitTransaction();
    print("Wartość rynkowa zaktualizowana pomyślnie!");
    print(`   Nowa wartość: ${newValue} EUR`);
    if (newValue > currentHighest) {
      print(`   To nowy rekord życiowy tego zawodnika!`);
    }
  } catch (error) {
    print("Wystąpił błąd. Wycofywanie transakcji...");
    session.abortTransaction();
    print(`   Powód: ${error.message}`);
  } finally {
    session.endSession();
  }
}
