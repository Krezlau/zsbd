SELECT
    P.first_name + ' ' + P.last_name AS PlayerName,
    POS.name AS Position,
    C.name AS ClubName,
    P.market_value AS CurrentMarketValue,
    S.goals AS CurrentSeasonGoals
FROM
    Transfers.PLAYERS AS P
JOIN
    Transfers.CLUBS AS C ON P.current_club_id = C.id
JOIN
    Transfers.POSITIONS AS POS ON P.position_id = POS.id
JOIN
    Transfers.STATS AS S ON P.id = S.player_id
WHERE
    P.current_flag = 1
    AND S.league_season_id = (
        SELECT TOP 1 id
        FROM Transfers.LEAGUESEASONS
        ORDER BY season_year DESC
    )
    AND P.market_value > (
        SELECT AVG(market_value)
        FROM Transfers.PLAYERS
        WHERE current_flag = 1
    )
    AND S.goals > (
        SELECT AVG(goals)
        FROM Transfers.STATS
        WHERE league_season_id = (
            SELECT TOP 1 id
            FROM Transfers.LEAGUESEASONS
            ORDER BY season_year DESC
        )
    )
ORDER BY
    P.market_value DESC, S.goals DESC;



SELECT
    C.name AS ClubName,
    ISNULL(SUM(CASE WHEN T.to_club_id = C.id THEN T.fee ELSE 0 END), 0) AS TotalSpent,
    ISNULL(SUM(CASE WHEN T.from_club_id = C.id THEN T.fee ELSE 0 END), 0) AS TotalReceived,
    ISNULL(SUM(CASE WHEN T.from_club_id = C.id THEN T.fee ELSE 0 END), 0) - ISNULL(SUM(CASE WHEN T.to_club_id = C.id THEN T.fee ELSE 0 END), 0) AS TransferBalance
FROM
    Transfers.CLUBS AS C
LEFT JOIN
    Transfers.TRANSFERS AS T ON C.id = T.from_club_id OR C.id = T.to_club_id
GROUP BY
    C.name
ORDER BY
    TransferBalance DESC;