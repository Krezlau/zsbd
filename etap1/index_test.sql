USE FootballDB;
GO

--------------------------------------------------------------------------
-- KROK 1: Wstawienie danych referencyjnych (jeśli nie istnieją)
-- Tabela PLAYERS wymaga kluczy obcych z tych tabel.
--------------------------------------------------------------------------

-- Upewnij się, że istnieje przynajmniej jedna narodowość
IF NOT EXISTS (SELECT 1 FROM Transfers.NATIONALITIES)
BEGIN
    PRINT 'Wstawianie testowej narodowości...';
    INSERT INTO Transfers.NATIONALITIES (name) VALUES ('Testlandia');
END;
GO

-- Upewnij się, że istnieje przynajmniej jedna pozycja
IF NOT EXISTS (SELECT 1 FROM Transfers.POSITIONS)
BEGIN
    PRINT 'Wstawianie testowej pozycji...';
    INSERT INTO Transfers.POSITIONS (name) VALUES ('Test_Position');
END;
GO

-- Upewnij się, że istnieje przynajmniej jedna preferowana noga
IF NOT EXISTS (SELECT 1 FROM Transfers.PREFFERED_FOOT)
BEGIN
    PRINT 'Wstawianie testowej preferowanej nogi...';
    INSERT INTO Transfers.PREFFERED_FOOT (name) VALUES ('Test');
END;
GO

--------------------------------------------------------------------------
-- KROK 2: Przygotowanie zmiennych i pętli
--------------------------------------------------------------------------

-- Pobierz ID dla danych testowych
DECLARE @TestNationalityId INT, @TestPositionId INT, @TestFootId INT;
SELECT TOP 1 @TestNationalityId = id FROM Transfers.NATIONALITIES;
SELECT TOP 1 @TestPositionId = id FROM Transfers.POSITIONS;
SELECT TOP 1 @TestFootId = id FROM Transfers.PREFFERED_FOOT;

-- Wyłącza komunikaty "1 row affected" dla każdej iteracji, co przyspiesza pętlę
SET NOCOUNT ON;

DECLARE @i INT = 0;
DECLARE @TotalPlayers INT = 1000000;

PRINT 'Rozpoczynanie wstawiania ' + CAST(@TotalPlayers AS VARCHAR(10)) + ' wierszy...';

-- Rozpocznij pętlę
WHILE @i < @TotalPlayers
BEGIN
    
    INSERT INTO Transfers.PLAYERS (
        first_name,
        last_name,
        nationality_id,
        birth_date,
        position_id,
        preferred_foot_id,
        effective_date,
        current_flag
    )
    VALUES (
        CAST(NEWID() AS NVARCHAR(100)), -- Losowe imię (GUID)
        CAST(NEWID() AS NVARCHAR(100)), -- Losowe nazwisko (GUID) - dla testu indeksu
        @TestNationalityId,
        GETDATE(), -- Przykładowa data urodzenia
        @TestPositionId,
        @TestFootId,
        GETDATE(), -- Przykładowa data wejścia w życie
        1          -- Flaga "current"
    );
    
    SET @i = @i + 1;

    -- Opcjonalny licznik postępu (drukuje co 10 000 wierszy)
    IF (@i % 10000 = 0)
    BEGIN
        PRINT CAST(@i AS VARCHAR(10)) + ' wierszy wstawionych...';
    END;
END

PRINT 'Zakończono. Wstawiono ' + CAST(@i AS VARCHAR(10)) + ' wierszy.';

-- Włącz komunikaty z powrotem
SET NOCOUNT OFF;
GO

select count(*) from Transfers.PLAYERS

select top(10) * from Transfers.PLAYERS

drop index IX_Players_last_name on Transfers.PLAYERS

INSERT INTO Transfers.PLAYERS (first_name, last_name, nationality_id, birth_date, position_id, height, preferred_foot_id, current_club_id, market_value, effective_date, current_flag) VALUES
-- Legia Players
('Sample', 'Player', 4, '1990-09-17', 6, 1.74, 1, 1, 800000, '2024-09-01', 1);
go

-- Total execution time: 00:00:00.034
select top(100) * from Transfers.PLAYERS where last_name = 'Player'

CREATE NONCLUSTERED INDEX IX_Players_last_name ON Transfers.PLAYERS(last_name);

-- Total execution time: 00:00:00.015
select top(100) * from Transfers.PLAYERS where last_name = 'Player'
