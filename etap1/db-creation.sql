-- use master 
-- go
-- DROP DATABASE FootballDB
-- GO

CREATE DATABASE FootballDB
GO

USE FootballDB
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Transfers')
BEGIN
    EXEC('CREATE SCHEMA Transfers');
END
GO

CREATE TABLE Transfers.LEAGUES (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(100) NOT NULL,
    country_id INT NOT NULL,
    level INT NOT NULL
);
GO

CREATE TABLE Transfers.LEAGUESEASONS (
    id INT IDENTITY(1,1) PRIMARY KEY,
    league_id INT NOT NULL,
    season_year INT NOT NULL -- e.g., 2024 for the 2024/2025 season
);
GO

CREATE TABLE Transfers.COACHES (
    id INT IDENTITY(1,1) PRIMARY KEY,
    first_name NVARCHAR(100) NOT NULL,
    last_name NVARCHAR(100) NOT NULL,
    nationality_id int NOT NULL,
    birth_date DATE
);
GO

CREATE TABLE Transfers.CLUBS (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(100) NOT NULL,
    country_id INT NOT NULL,
    city NVARCHAR(100),
    league_id INT NULL, -- A club can be temporarily without a league
    coach_id INT NULL   -- A club can be temporarily without a coach
);
GO

CREATE TABLE Transfers.PLAYERS (
    id INT IDENTITY(1,1) PRIMARY KEY,
    first_name NVARCHAR(100) NOT NULL,
    last_name NVARCHAR(100) NOT NULL,
    nationality_id INT NOT NULL,
    birth_date DATE,
    position_id INT NOT NULL,
    height DECIMAL(3, 2), -- Height in meters, e.g., 1.85
    preferred_foot_id INT NOT NULL,
    current_club_id INT NULL, -- Player can be a free agent
    market_value INT,
    effective_date DATE NOT NULL,
    current_flag BIT
);
GO

CREATE TABLE Transfers.TRANSFERS (
    id INT IDENTITY(1,1) PRIMARY KEY,
    player_id INT NOT NULL,
    from_club_id INT NULL, -- NULL if player was a free agent
    to_club_id INT NULL,   -- NULL if player becomes a free agent
    transfer_date DATE NOT NULL,
    fee DECIMAL(18, 2) NULL -- Transfer fee, NULL for free transfers
);
GO

CREATE TABLE Transfers.STATS (
    id INT IDENTITY(1,1) PRIMARY KEY,
    player_id INT NOT NULL,
    league_season_id INT NOT NULL,
    club_id INT NOT NULL,
    appearances INT DEFAULT 0,
    minutes_played INT DEFAULT 0,
    goals INT DEFAULT 0,
    assists INT DEFAULT 0,
    yellow_cards INT DEFAULT 0,
    red_cards INT DEFAULT 0
);
GO

CREATE TABLE Transfers.AGENTS (
    id INT IDENTITY(1,1) PRIMARY KEY,
    first_name NVARCHAR(100) NOT NULL,
    last_name NVARCHAR(100) NOT NULL,
    company NVARCHAR(150) NULL
);
GO

CREATE TABLE Transfers.PLAYER_AGENTS (
    id INT IDENTITY(1,1) PRIMARY KEY,
    player_id INT NOT NULL,
    agent_id INT NOT NULL,
    contract_start_date DATE NOT NULL,
    contract_end_date DATE NULL
);
GO

CREATE TABLE Transfers.AWARDS (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(150) NOT NULL,
    description NVARCHAR(500) NULL
);
GO

CREATE TABLE Transfers.PLAYER_AWARDS (
    id INT IDENTITY(1,1) PRIMARY KEY,
    player_id INT NOT NULL,
    award_id INT NOT NULL,
    season_year INT NOT NULL
);
GO

CREATE TABLE Transfers.POSITIONS (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(50) NOT NULL

);
GO

CREATE TABLE Transfers.PREFFERED_FOOT (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(5) NOT NULL -- left/right
);
GO

CREATE TABLE Transfers.NATIONALITIES (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(50) NOT NULL
)

ALTER TABLE Transfers.LEAGUESEASONS ADD CONSTRAINT FK_LeagueSeasons_Leagues FOREIGN KEY (league_id) REFERENCES Transfers.LEAGUES(id);
ALTER TABLE Transfers.CLUBS ADD CONSTRAINT FK_Clubs_Leagues FOREIGN KEY (league_id) REFERENCES Transfers.LEAGUES(id);
ALTER TABLE Transfers.CLUBS ADD CONSTRAINT FK_Clubs_Coaches FOREIGN KEY (coach_id) REFERENCES Transfers.COACHES(id);
ALTER TABLE Transfers.PLAYERS ADD CONSTRAINT FK_Players_Clubs FOREIGN KEY (current_club_id) REFERENCES Transfers.CLUBS(id);
ALTER TABLE Transfers.PLAYERS ADD CONSTRAINT FK_Players_Positions FOREIGN KEY (position_id) REFERENCES Transfers.POSITIONS(id);
ALTER TABLE Transfers.PLAYERS ADD CONSTRAINT FK_Players_Nationalities FOREIGN KEY (nationality_id) REFERENCES Transfers.NATIONALITIES(id);
ALTER TABLE Transfers.PLAYERS ADD CONSTRAINT FK_Players_PreferredFoot FOREIGN KEY (preferred_foot_id) REFERENCES Transfers.PREFFERED_FOOT(id);
ALTER TABLE Transfers.TRANSFERS ADD CONSTRAINT FK_Transfers_Players FOREIGN KEY (player_id) REFERENCES Transfers.PLAYERS(id);
ALTER TABLE Transfers.TRANSFERS ADD CONSTRAINT FK_Transfers_FromClub FOREIGN KEY (from_club_id) REFERENCES Transfers.CLUBS(id);
ALTER TABLE Transfers.TRANSFERS ADD CONSTRAINT FK_Transfers_ToClub FOREIGN KEY (to_club_id) REFERENCES Transfers.CLUBS(id);
ALTER TABLE Transfers.STATS ADD CONSTRAINT FK_Statistics_Players FOREIGN KEY (player_id) REFERENCES Transfers.PLAYERS(id);
ALTER TABLE Transfers.STATS ADD CONSTRAINT FK_Statistics_LeagueSeasons FOREIGN KEY (league_season_id) REFERENCES Transfers.LEAGUESEASONS(id);
ALTER TABLE Transfers.STATS ADD CONSTRAINT FK_Statistics_Clubs FOREIGN KEY (club_id) REFERENCES Transfers.CLUBS(id);
ALTER TABLE Transfers.PLAYER_AGENTS ADD CONSTRAINT FK_PlayerAgents_Players FOREIGN KEY (player_id) REFERENCES Transfers.PLAYERS(id);
ALTER TABLE Transfers.PLAYER_AGENTS ADD CONSTRAINT FK_PlayerAgents_Agents FOREIGN KEY (agent_id) REFERENCES Transfers.AGENTS(id);
ALTER TABLE Transfers.PLAYER_AWARDS ADD CONSTRAINT FK_PlayerAwards_Players FOREIGN KEY (player_id) REFERENCES Transfers.PLAYERS(id);
ALTER TABLE Transfers.PLAYER_AWARDS ADD CONSTRAINT FK_PlayerAwards_Awards FOREIGN KEY (award_id) REFERENCES Transfers.AWARDS(id);
ALTER TABLE Transfers.LEAGUES ADD CONSTRAINT FK_Leagues_Nationalities FOREIGN KEY (country_id) REFERENCES Transfers.NATIONALITIES(id);
ALTER TABLE Transfers.CLUBS ADD CONSTRAINT FK_Clubs_Nationalities FOREIGN KEY (country_id) REFERENCES Transfers.NATIONALITIES(id);
ALTER TABLE Transfers.COACHES ADD CONSTRAINT FK_Coaches_Nationalities FOREIGN KEY (nationality_id) REFERENCES Transfers.NATIONALITIES(id);
GO


CREATE NONCLUSTERED INDEX IX_LeagueSeasons_league_id ON Transfers.LEAGUESEASONS(league_id);
CREATE NONCLUSTERED INDEX IX_Clubs_league_id ON Transfers.CLUBS(league_id);
CREATE NONCLUSTERED INDEX IX_Clubs_coach_id ON Transfers.CLUBS(coach_id);
CREATE NONCLUSTERED INDEX IX_Players_current_club_id ON Transfers.PLAYERS(current_club_id);
CREATE NONCLUSTERED INDEX IX_Transfers_player_id ON Transfers.TRANSFERS(player_id);
CREATE NONCLUSTERED INDEX IX_Statistics_player_id ON Transfers.STATS(player_id);
CREATE NONCLUSTERED INDEX IX_Statistics_league_season_id ON Transfers.STATS(league_season_id);
CREATE NONCLUSTERED INDEX IX_PlayerAgents_player_id ON Transfers.PLAYER_AGENTS(player_id);
CREATE NONCLUSTERED INDEX IX_PlayerAgents_agent_id ON Transfers.PLAYER_AGENTS(agent_id);
CREATE NONCLUSTERED INDEX IX_PlayerAwards_player_id ON Transfers.PLAYER_AWARDS(player_id);
CREATE NONCLUSTERED INDEX IX_PlayerAwards_award_id ON Transfers.PLAYER_AWARDS(award_id);

CREATE NONCLUSTERED INDEX IX_Players_last_name ON Transfers.PLAYERS(last_name);
CREATE NONCLUSTERED INDEX IX_Agents_last_name on Transfers.AGENTS(last_name);
CREATE NONCLUSTERED INDEX IX_Coaches_last_name on Transfers.COACHES(last_name);
CREATE NONCLUSTERED INDEX IX_Players_last_name_first_name ON Transfers.PLAYERS (last_name, first_name); 
CREATE NONCLUSTERED INDEX IX_Players_market_value ON Transfers.PLAYERS (market_value DESC);
CREATE NONCLUSTERED INDEX IX_Clubs_name ON Transfers.CLUBS (name);
CREATE NONCLUSTERED INDEX IX_Coaches_last_name_first_name ON Transfers.COACHES (last_name, first_name);
CREATE NONCLUSTERED INDEX IX_Agents_last_name_first_name ON Transfers.AGENTS (last_name, first_name);
CREATE NONCLUSTERED INDEX IX_Transfers_transfer_date ON Transfers.TRANSFERS (transfer_date DESC);
GO