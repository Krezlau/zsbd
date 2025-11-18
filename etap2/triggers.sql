CREATE TRIGGER Transfers.trg_AfterTransfer_UpdatePlayerClub
ON Transfers.TRANSFERS
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE P
    SET
        P.current_club_id = i.to_club_id
    FROM
        Transfers.PLAYERS AS P
    JOIN
        inserted AS i ON P.id = i.player_id;
END;
GO

CREATE TRIGGER Transfers.trg_PreventChronologicalErrorsInTransfers
ON Transfers.TRANSFERS
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF UPDATE(transfer_date) OR (NOT EXISTS(SELECT 1 FROM deleted))
    BEGIN
        
        IF EXISTS (
            SELECT 1
            FROM inserted AS i
            CROSS APPLY (
                SELECT MAX(T.transfer_date) AS MaxExistingDate
                FROM Transfers.TRANSFERS AS T
                WHERE 
                    T.player_id = i.player_id
                    AND T.id != i.id
            ) AS ExistingData
            WHERE
                i.transfer_date < ExistingData.MaxExistingDate
        )
        BEGIN
            RAISERROR ('Can not add transfer older than a newest transfer for a given player!', 16, 1);
            ROLLBACK TRANSACTION;
        END;
    END;
END;
GO