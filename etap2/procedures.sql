CREATE OR ALTER PROCEDURE Transfers.sp_EndSeason
    @league_id INT,
    @season_year INT,
    @winning_club_id INT,
    @champion_award_name NVARCHAR(150),
    @top_scorer_award_name NVARCHAR(150)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @league_season_id INT;
    DECLARE @champion_award_id INT;
    DECLARE @top_scorer_award_id INT;

    BEGIN TRY
        BEGIN TRANSACTION;

        SELECT @league_season_id = id
        FROM Transfers.LEAGUESEASONS
        WHERE league_id = @league_id AND season_year = @season_year;

        IF @league_season_id IS NULL
        BEGIN
            RAISERROR('Could not find the league season!', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN -1;
        END;

        IF NOT EXISTS (SELECT 1 FROM Transfers.CLUBS WHERE id = @winning_club_id)
        BEGIN
            RAISERROR('Could not find the winning club.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN -1;
        END;

        -- tworzenie nagród
        SELECT @champion_award_id = id
        FROM Transfers.AWARDS
        WHERE name = @champion_award_name;

        IF @champion_award_id IS NULL
        BEGIN
            INSERT INTO Transfers.AWARDS (name, description)
            VALUES (@champion_award_name, 'League winning award.');
            
            SET @champion_award_id = SCOPE_IDENTITY();
            PRINT 'Created a new award: ' + @champion_award_name;
        END;

        SELECT @top_scorer_award_id = id
        FROM Transfers.AWARDS
        WHERE name = @top_scorer_award_name;

        IF @top_scorer_award_id IS NULL
        BEGIN
            INSERT INTO Transfers.AWARDS (name, description)
            VALUES (@top_scorer_award_name, 'Best scorer award.');
            
            SET @top_scorer_award_id = SCOPE_IDENTITY();
            PRINT 'Created a new award: ' + @top_scorer_award_name;
        END;

        -- mistrzostwo kraju
        INSERT INTO Transfers.PLAYER_AWARDS (player_id, award_id, season_year)
        SELECT DISTINCT
            s.player_id,
            @champion_award_id, 
            @season_year
        FROM
            Transfers.STATS s
        WHERE
            s.league_season_id = @league_season_id
            AND s.club_id = @winning_club_id
            AND s.appearances > 0

        -- król strzelców
        INSERT INTO Transfers.PLAYER_AWARDS (player_id, award_id, season_year)
        SELECT
            player_id,
            @top_scorer_award_id,
            @season_year
        FROM
        (
            SELECT
                player_id,
                DENSE_RANK() OVER (ORDER BY goals DESC) as goal_rank
            FROM
                Transfers.STATS
            WHERE
                league_season_id = @league_season_id
                AND goals > 0
        ) AS RankedScorers
        WHERE
            goal_rank = 1

        COMMIT TRANSACTION;

        PRINT 'Success. Awards granted.';

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        PRINT 'Error. Transaction has been rollbacked';
    END CATCH
END
GO


CREATE OR ALTER PROCEDURE Transfers.sp_ExecutePlayerTransfer
    @player_id INT,
    @from_club_id INT,
    @to_club_id INT,
    @fee DECIMAL(18, 2),
    @transfer_date DATE
AS
BEGIN
    SET NOCOUNT ON;


    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM Transfers.PLAYERS WHERE id = @player_id)
        BEGIN
            RAISERROR('Error: Player with the specified ID does not exist.', 16, 1);
            RETURN; 
        END

        IF @from_club_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Transfers.CLUBS WHERE id = @from_club_id)
        BEGIN
            RAISERROR('Error: The "From" club (from_club_id) does not exist.', 16, 1);
            RETURN;
        END

        IF @to_club_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Transfers.CLUBS WHERE id = @to_club_id)
        BEGIN
            RAISERROR('Error: The "To" club (to_club_id) does not exist.', 16, 1);
            RETURN;
        END
        
        IF @from_club_id = @to_club_id
        BEGIN
            RAISERROR('Error: Cannot execute a transfer to the same club.', 16, 1);
            RETURN;
        END

        DECLARE @current_club_id INT;
        SELECT @current_club_id = current_club_id 
        FROM Transfers.PLAYERS 
        WHERE id = @player_id;

        IF ISNULL(@current_club_id, 0) != ISNULL(@from_club_id, 0)
        BEGIN
            RAISERROR('Error: Player is not currently assigned to the specified "From" club (from_club_id).', 16, 1);
            RETURN;
        END

        INSERT INTO Transfers.TRANSFERS
            (player_id, from_club_id, to_club_id, transfer_date, fee)
        VALUES
            (@player_id, @from_club_id, @to_club_id, @transfer_date, @fee);

        UPDATE Transfers.PLAYERS
        SET 
            current_club_id = @to_club_id
        WHERE 
            id = @player_id;

        COMMIT TRANSACTION;
        
        PRINT 'Transfer executed successfully.';

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'Error: Transaction was rolled back.';
        END

    END CATCH
END;
GO