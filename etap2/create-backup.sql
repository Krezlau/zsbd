USE FootballDB;
GO
BACKUP DATABASE FootballDB
TO DISK = '/var/opt/mssql/data/FootballDB.bak'
   WITH FORMAT,
      MEDIANAME = 'SQLServerBackups',
      NAME = 'Full Backup of FootballDB';
GO


RESTORE DATABASE NewFootballDB
FROM DISK = '/var/opt/mssql/data/FootballDB.bak'
WITH
   MOVE 'FootballDb' TO '/var/opt/mssql/data/NewFootballDB.mdf',
   MOVE 'FootballDb_log' TO '/var/opt/mssql/data/NewFootballDB.ldf';
GO


USE NewFootballDB
GO
SELECT * FROM Transfers.PLAYERS