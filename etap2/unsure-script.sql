\set ON_ERROR_STOP
BEGIN;
CREATE VIEW "transfers"."v_current_players_details" AS SELECT
    P.id AS Player_ID,
    P.first_name AS First_Name,
    P.last_name AS Last_Name,
    N.name AS Nationality,
    C.name AS Current_Club,
    POS.name AS Position,
    PF.name AS Preferred_Foot,
    P.height AS Height_Meters,
    P.market_value AS Market_Value,
    P.effective_date AS Value_Effective_Date
FROM
    Transfers.PLAYERS AS P
INNER JOIN
    Transfers.NATIONALITIES AS N ON P.nationality_id = N.id
INNER JOIN
    Transfers.POSITIONS AS POS ON P.position_id = POS.id
INNER JOIN
    Transfers.PREFFERED_FOOT AS PF ON P.preferred_foot_id = PF.id
LEFT JOIN
    Transfers.CLUBS AS C ON P.current_club_id = C.id
WHERE
    P.current_flag = true;

;

CREATE VIEW "transfers"."v_club_league_coach_details" AS SELECT
    CL.id AS Club_ID,
    CL.name AS Club_Name,
    N.name AS Country,
    CL.city AS City,
    L.name AS League_Name,
    L.level AS League_Level,
    C.first_name AS Coach_First_Name,
    C.last_name AS Coach_Last_Name
FROM
    Transfers.CLUBS AS CL
INNER JOIN
    Transfers.NATIONALITIES AS N ON CL.country_id = N.id
LEFT JOIN
    Transfers.LEAGUES AS L ON CL.league_id = L.id
LEFT JOIN
    Transfers.COACHES AS C ON CL.coach_id = C.id;

;

CREATE VIEW "transfers"."v_transfer_history" AS SELECT
    T.id AS Transfer_ID,
    T.transfer_date AS Transfer_Date,
    T.fee AS Transfer_Fee,
    P.first_name AS Player_First_Name,
    P.last_name AS Player_Last_Name,
    Club_From.name AS From_Club,
    Club_To.name AS To_Club
FROM
    Transfers.TRANSFERS AS T
INNER JOIN
    Transfers.PLAYERS AS P ON T.player_id = P.id
LEFT JOIN
    Transfers.CLUBS AS Club_From ON T.from_club_id = Club_From.id
LEFT JOIN
    Transfers.CLUBS AS Club_To ON T.to_club_id = Club_To.id;

;

CREATE VIEW "transfers"."v_player_season_stats" AS SELECT
    S.id AS Stat_ID,
    P.first_name AS Player_First_Name,
    P.last_name AS Player_Last_Name,
    C.name AS Club_Name,
    LS.season_year AS Season_Year,
    S.appearances AS Appearances,
    S.minutes_played AS Minutes_Played,
    S.goals AS Goals,
    S.assists AS Assists,
    S.yellow_cards AS Yellow_Cards,
    S.red_cards AS Red_Cards
FROM
    Transfers.STATS AS S
INNER JOIN
    Transfers.PLAYERS AS P ON S.player_id = P.id
INNER JOIN
    Transfers.CLUBS AS C ON S.club_id = C.id
INNER JOIN
    Transfers.LEAGUESEASONS AS LS ON S.league_season_id = LS.id;

;

CREATE VIEW "transfers"."v_current_player_agents" AS SELECT
    P.first_name AS Player_First_Name,
    P.last_name AS Player_Last_Name,
    A.first_name AS Agent_First_Name,
    A.last_name AS Agent_Last_Name,
    A.company AS Agent_Company,
    PA.contract_start_date AS Contract_Start
FROM
    Transfers.PLAYER_AGENTS AS PA
INNER JOIN
    Transfers.PLAYERS AS P ON PA.player_id = P.id
INNER JOIN
    Transfers.AGENTS AS A ON PA.agent_id = A.id
WHERE
    PA.contract_end_date IS NULL
    OR PA.contract_end_date >= CURRENT_DATE;

;

COMMIT;
