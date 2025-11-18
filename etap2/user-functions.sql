CREATE FUNCTION Transfers.fn_GetClubHistoricalBalanceSheet (
    @club_id INT
)
RETURNS TABLE
AS
RETURN
(
    WITH SeasonTransfers AS (
        SELECT 
            fee,
            from_club_id,
            to_club_id,
            (CASE 
                WHEN MONTH(transfer_date) >= 7 THEN YEAR(transfer_date) 
                ELSE YEAR(transfer_date) - 1 
            END) AS SeasonStartYear
        FROM 
            Transfers.TRANSFERS
        WHERE
            (from_club_id = @club_id OR to_club_id = @club_id)
            AND fee IS NOT NULL AND fee != 0 
    ),
    
    GroupedBalance AS (
        SELECT
            SeasonStartYear,
            ISNULL(SUM(CASE WHEN to_club_id = @club_id THEN fee ELSE 0 END), 0) AS MoneySpent,
            ISNULL(SUM(CASE WHEN from_club_id = @club_id THEN fee ELSE 0 END), 0) AS MoneyReceived
        FROM
            SeasonTransfers
        GROUP BY 
            SeasonStartYear 
    )
    
    SELECT 
        c.name AS ClubName,
        CAST(gb.SeasonStartYear AS NVARCHAR(4)) + '/' + CAST((gb.SeasonStartYear + 1) AS NVARCHAR(4)) AS Season,
        gb.MoneySpent,
        gb.MoneyReceived,
        (gb.MoneyReceived - gb.MoneySpent) AS NetBalance
    FROM 
        GroupedBalance AS gb
    CROSS JOIN 
        Transfers.CLUBS AS c
    WHERE
        c.id = @club_id
);
GO

SELECT * FROM Transfers.fn_GetClubHistoricalBalanceSheet(1);
GO

CREATE FUNCTION Transfers.fn_GetPlayersByClub (@club_id INT)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        p.id AS player_id,
        p.first_name,
        p.last_name,
        pos.name AS position_name,
        p.birth_date,
        p.market_value
    FROM 
        Transfers.PLAYERS AS p
    JOIN 
        Transfers.POSITIONS AS pos ON p.position_id = pos.id
    WHERE 
        p.current_club_id = @club_id
        AND p.current_flag = 1
);
GO

SELECT * FROM Transfers.fn_GetPlayersByClub(1);
GO

CREATE FUNCTION Transfers.fn_SearchPlayersByLastName (@last_name_pattern NVARCHAR(100))
RETURNS TABLE
AS
RETURN
(
    SELECT 
        p.id AS player_id,
        p.first_name,
        p.last_name,
        p.birth_date,
        c.name AS club_name,
        pos.name AS position_name
    FROM 
        Transfers.PLAYERS AS p
    LEFT JOIN 
        Transfers.CLUBS AS c ON p.current_club_id = c.id
    LEFT JOIN 
        Transfers.POSITIONS AS pos ON p.position_id = pos.id
    WHERE 
        p.last_name LIKE @last_name_pattern + '%'
);
GO

SELECT * FROM Transfers.fn_SearchPlayersByLastName('Gu');
GO

CREATE FUNCTION Transfers.fn_GetPlayerStatsBySeason (@player_id INT)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        ls.season_year,
        l.name AS league_name,
        c.name AS club_name,
        s.appearances,
        s.minutes_played,
        s.goals,
        s.assists,
        s.yellow_cards,
        s.red_cards
    FROM 
        Transfers.STATS AS s
    JOIN 
        Transfers.LEAGUESEASONS AS ls ON s.league_season_id = ls.id
    JOIN 
        Transfers.LEAGUES AS l ON ls.league_id = l.id
    JOIN 
        Transfers.CLUBS AS c ON s.club_id = c.id
    WHERE 
        s.player_id = @player_id
);
GO

SELECT * FROM Transfers.fn_GetPlayerStatsBySeason(1)
GO

CREATE FUNCTION Transfers.fn_GetPlayerAwards (@player_id INT)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        pa.season_year,
        a.name AS award_name,
        a.description
    FROM 
        Transfers.PLAYER_AWARDS AS pa
    JOIN 
        Transfers.AWARDS AS a ON pa.award_id = a.id
    WHERE 
        pa.player_id = @player_id
);
GO

SELECT * FROM Transfers.fn_GetPlayerAwards(1)
GO

CREATE FUNCTION Transfers.fn_GetClubsByLeague (@league_id INT)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        c.id AS club_id,
        c.name AS club_name,
        c.city,
        ISNULL(co.first_name + ' ' + co.last_name, 'Brak trenera') AS coach_name
    FROM 
        Transfers.CLUBS AS c
    LEFT JOIN 
        Transfers.COACHES AS co ON c.coach_id = co.id
    WHERE 
        c.league_id = @league_id
);
GO

SELECT * FROM Transfers.fn_GetClubsByLeague(1);
GO
