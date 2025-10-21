USE FootballDB;
GO

-- 1. Insert data into Transfers.NATIONALITIES (Countries for Leagues, Clubs, Players, Coaches)
INSERT INTO Transfers.NATIONALITIES (name) VALUES
('Poland'),
('Slovakia'),
('Croatia'),
('Portugal'),
('Spain'),
('Germany'),
('Serbia');
GO

-- 2. Insert data into Transfers.POSITIONS
INSERT INTO Transfers.POSITIONS (name) VALUES
('Goalkeeper'),
('Centre-Back'),
('Right-Back'),
('Defensive Midfield'),
('Central Midfield'),
('Attacking Midfield'),
('Left Winger'),
('Centre-Forward'),
('Right Winger');
GO

-- 3. Insert data into Transfers.PREFFERED_FOOT
INSERT INTO Transfers.PREFFERED_FOOT (name) VALUES
('Right'),
('Left'),
('Both');
GO

-- 4. Insert data into Transfers.LEAGUES (Ekstraklasa and others)
-- Poland_id = 1, Germany_id = 6
INSERT INTO Transfers.LEAGUES (name, country_id, level) VALUES
('Ekstraklasa', 1, 1),
('1. Liga', 1, 2),
('Bundesliga', 6, 1),
('Premier League', 7, 1), -- Serbia, just for variety
('Liga Portugal', 4, 1); -- Portugal
GO

-- 5. Insert data into Transfers.LEAGUESEASONS
-- Ekstraklasa_id = 1
INSERT INTO Transfers.LEAGUESEASONS (league_id, season_year) VALUES
(1, 2024), -- Ekstraklasa 2024/2025
(1, 2023), -- Ekstraklasa 2023/2024
(2, 2024), -- 1. Liga 2024/2025
(3, 2024), -- Bundesliga 2024/2025
(1, 2022); -- Ekstraklasa 2022/2023
GO

-- 6. Insert data into Transfers.COACHES (Coaches for Ekstraklasa clubs)
-- Poland_id = 1, Croatia_id = 3, Slovakia_id = 2, Portugal_id = 4
INSERT INTO Transfers.COACHES (first_name, last_name, nationality_id, birth_date) VALUES
('Nino', 'Bule', 3, '1975-02-12'),    -- Pogoń Szczecin (Croatia)
('Kosta', 'Runjaić', 5, '1971-06-04'), -- Legia Warszawa (Spain/Germany) - Assuming Spanish/German as Nationality
('Dariusz', 'Żuraw', 1, '1972-11-14'), -- Warta Poznań (Poland)
('Mariusz', 'Magoń', 1, '1980-05-21'), -- Sample coach (Poland)
('Gonçalo', 'Feio', 4, '1989-08-17'); -- Sample coach (Portugal)
GO

-- 7. Insert data into Transfers.CLUBS (Ekstraklasa clubs)
-- Poland_id = 1, Ekstraklasa_id = 1, Coach_ids from step 6
INSERT INTO Transfers.CLUBS (name, country_id, city, league_id, coach_id) VALUES
('Legia Warszawa', 1, 'Warszawa', 1, 2), -- Coach Runjaić
('Pogoń Szczecin', 1, 'Szczecin', 1, 1), -- Coach Bule
('Śląsk Wrocław', 1, 'Wrocław', 1, 3),   -- Coach Żuraw (Just for example)
('Lech Poznań', 1, 'Poznań', 1, 5),     -- Coach Feio (Just for example)
('Jagiellonia Białystok', 1, 'Białystok', 1, NULL), -- No coach assigned yet
('Warta Poznań', 1, 'Poznań', 1, 4);
GO

-- 8. Insert data into Transfers.AGENTS
INSERT INTO Transfers.AGENTS (first_name, last_name, company) VALUES
('Pini', 'Zahavi', 'Gol International'),
('Mino', 'Raiola', 'RAIOLA SRL'), -- Historical, for variety
('Cezary', 'Kulesza', 'CK Sport Agency'),
('Bartłomiej', 'Płatek', 'BP Agency'),
('Jakub', 'Wawrzyniak', 'JW Management'),
('Jorge', 'Mendes', 'Gestifute');
GO

-- 9. Insert data into Transfers.AWARDS
INSERT INTO Transfers.AWARDS (name, description) VALUES
('Ekstraklasa Player of the Season', 'Best player in the Ekstraklasa for the given season'),
('Ekstraklasa Top Scorer', 'Player with the most goals in the Ekstraklasa'),
('Ekstraklasa Defender of the Season', 'Best defender in the Ekstraklasa'),
('Ekstraklasa Young Player of the Season', 'Best young player (under 23) in the Ekstraklasa'),
('Polish Cup MVP', 'Most valuable player of the Polish Cup tournament');
GO

-- 10. Insert data into Transfers.PLAYERS (Ekstraklasa 2024/2025 players)
-- Positions: GK=1, CB=2, AM=6, CF=8, LW=7
-- Preferred_Foot: Right=1, Left=2
-- Nationalities: Poland=1, Slovakia=2, Croatia=3, Serbia=7
-- Clubs: Legia=1, Pogoń=2, Śląsk=3, Lech=4, Jagiellonia=5
INSERT INTO Transfers.PLAYERS (first_name, last_name, nationality_id, birth_date, position_id, height, preferred_foot_id, current_club_id, market_value, effective_date, current_flag) VALUES
-- Legia Players
('Josué', 'Pesqueira', 4, '1990-09-17', 6, 1.74, 1, 1, 800000, '2024-09-01', 1), -- AM, Portugal, Legia
('Marc', 'Gual', 5, '1996-03-01', 8, 1.81, 1, 1, 1200000, '2024-09-01', 1), -- CF, Spain, Legia (Hypothetical current club)
('Rafał', 'Augustyniak', 1, '1993-08-14', 2, 1.86, 1, 1, 600000, '2024-09-01', 1), -- CB, Poland, Legia
-- Pogoń Players
('Kamil', 'Grosicki', 1, '1988-06-24', 7, 1.80, 2, 2, 900000, '2024-09-01', 1), -- LW, Poland, Pogoń
('Valentin', 'Coțofană', 7, '2001-04-05', 1, 1.95, 1, 2, 400000, '2024-09-01', 1), -- GK, Serbia, Pogoń (Hypothetical)
-- Śląsk Player
('Erik', 'Expósito', 5, '1996-06-23', 8, 1.90, 1, 3, 2000000, '2024-09-01', 1), -- CF, Spain, Śląsk
-- Lech Player
('Miha', 'Blažič', 2, '1993-05-08', 2, 1.84, 1, 4, 1500000, '2024-09-01', 1), -- CB, Slovakia (Used 2 for a different country)
-- Jagiellonia Player
('Bartłomiej', 'Wdowik', 1, '2000-09-25', 3, 1.85, 2, 5, 1000000, '2024-09-01', 1); -- RB (used 3), Poland
GO

-- 11. Insert data into Transfers.TRANSFERS
-- Players: Josué=1, Marc Gual=2, Grosicki=4, Expósito=6, Wdowik=8
-- Clubs: Legia=1, Pogoń=2, Śląsk=3, Lech=4, Jagiellonia=5, Warta=6
INSERT INTO Transfers.TRANSFERS (player_id, from_club_id, to_club_id, transfer_date, fee) VALUES
(2, 6, 1, '2024-07-15', 500000.00),  -- Marc Gual from Warta to Legia (Example)
(1, NULL, 1, '2021-07-01', NULL),    -- Josué free agent to Legia
(4, NULL, 2, '2021-08-16', NULL),    -- Grosicki free agent to Pogoń
(6, NULL, 3, '2024-08-20', 0.00),    -- Expósito from free agent (fee 0)
(8, 5, 4, '2025-01-05', 2500000.00), -- Wdowik from Jagiellonia to Lech (Winter transfer example)
(5, NULL, 2, '2024-07-01', 100000.00);-- Valentin Coțofană to Pogoń
GO

-- 12. Insert data into Transfers.PLAYER_AGENTS
-- Players: Josué=1, Marc Gual=2, Augustyniak=3, Grosicki=4, Coțofană=5, Expósito=6, Blažič=7, Wdowik=8
-- Agents: Zahavi=1, Raiola=2, Kulesza=3, Płatek=4, Wawrzyniak=5, Mendes=6
INSERT INTO Transfers.PLAYER_AGENTS (player_id, agent_id, contract_start_date, contract_end_date) VALUES
(1, 6, '2021-05-01', '2025-06-30'), -- Josué with Mendes
(2, 1, '2024-07-01', '2027-06-30'), -- Marc Gual with Zahavi
(4, 5, '2021-08-01', NULL),         -- Grosicki with Wawrzyniak (Open end date)
(6, 3, '2023-01-01', '2026-12-31'), -- Expósito with Kulesza
(3, 4, '2022-06-01', '2025-06-30'), -- Augustyniak with Płatek
(5, 4, '2024-06-01', '2028-06-30'), -- Coțofană with Płatek
(7, 3, '2023-01-01', '2026-12-31'), -- Blažič with Kulesza
(8, 5, '2024-01-01', NULL);         -- Wdowik with Wawrzyniak
GO

-- 13. Insert data into Transfers.STATS (Ekstraklasa 2024/2025 - season_id=1)
-- Players: Josué=1, Marc Gual=2, Augustyniak=3, Grosicki=4, Coțofană=5, Expósito=6
-- Clubs: Legia=1, Pogoń=2, Śląsk=3
-- LeagueSeason_id = 1 (Ekstraklasa 2024/2025)
INSERT INTO Transfers.STATS (player_id, league_season_id, club_id, appearances, minutes_played, goals, assists, yellow_cards, red_cards) VALUES
(1, 1, 1, 10, 850, 4, 3, 2, 0), -- Josué (Legia)
(2, 1, 1, 12, 950, 7, 1, 1, 0), -- Marc Gual (Legia)
(4, 1, 2, 11, 990, 2, 6, 0, 0), -- Grosicki (Pogoń)
(6, 1, 3, 9, 810, 6, 2, 3, 0), -- Expósito (Śląsk)
(3, 1, 1, 8, 720, 0, 0, 4, 1), -- Augustyniak (Legia)
(5, 1, 2, 10, 900, 0, 0, 0, 0), -- Coțofană (Pogoń)
(7, 1, 4, 12, 1080, 1, 0, 5, 0); -- Blažič (Lech)
GO

-- 14. Insert data into Transfers.PLAYER_AWARDS
-- Players: Josué=1, Marc Gual=2, Grosicki=4, Expósito=6
-- Awards: Player of the Season=1, Top Scorer=2, Defender of the Season=3, Young Player=4, Polish Cup MVP=5
INSERT INTO Transfers.PLAYER_AWARDS (player_id, award_id, season_year) VALUES
(6, 2, 2023), -- Expósito Top Scorer (2023/2024 season)
(4, 1, 2023), -- Grosicki Player of the Season (2023/2024 season)
(1, 5, 2022), -- Josué Polish Cup MVP (2022/2023)
(3, 3, 2024), -- Augustyniak Defender of the Season (2024/2025 - hypothetical)
(2, 4, 2021), -- Marc Gual Young Player (from a past season, e.g., 2021/2022)
(8, 4, 2023); -- Wdowik Young Player (2023/2024)
GO

SELECT * FROM Transfers.PLAYERS