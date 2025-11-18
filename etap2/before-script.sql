
BEGIN;
CREATE SCHEMA IF NOT EXISTS "transfers";


CREATE TABLE "transfers"."agents"( 
	"id" int NOT NULL,
	"first_name" varchar(100) NOT NULL,
	"last_name" varchar(100) NOT NULL,
	"company" varchar(150));

CREATE TABLE "transfers"."awards"( 
	"id" int NOT NULL,
	"name" varchar(150) NOT NULL,
	"description" varchar(500));

CREATE TABLE "transfers"."clubs"( 
	"id" int NOT NULL,
	"name" varchar(100) NOT NULL,
	"country_id" int NOT NULL,
	"city" varchar(100),
	"league_id" int,
	"coach_id" int);

CREATE TABLE "transfers"."coaches"( 
	"id" int NOT NULL,
	"first_name" varchar(100) NOT NULL,
	"last_name" varchar(100) NOT NULL,
	"nationality_id" int NOT NULL,
	"birth_date" date);

CREATE TABLE "transfers"."leagues"( 
	"id" int NOT NULL,
	"name" varchar(100) NOT NULL,
	"country_id" int NOT NULL,
	"level" int NOT NULL);

CREATE TABLE "transfers"."leagueseasons"( 
	"id" int NOT NULL,
	"league_id" int NOT NULL,
	"season_year" int NOT NULL);

CREATE TABLE "transfers"."nationalities"( 
	"id" int NOT NULL,
	"name" varchar(50) NOT NULL);

CREATE TABLE "transfers"."players"( 
	"id" int NOT NULL,
	"first_name" varchar(100) NOT NULL,
	"last_name" varchar(100) NOT NULL,
	"nationality_id" int NOT NULL,
	"birth_date" date,
	"position_id" int NOT NULL,
	"height" numeric(3, 2),
	"preferred_foot_id" int NOT NULL,
	"current_club_id" int,
	"market_value" int,
	"effective_date" date NOT NULL,
	"current_flag" boolean);

CREATE TABLE "transfers"."player_agents"( 
	"id" int NOT NULL,
	"player_id" int NOT NULL,
	"agent_id" int NOT NULL,
	"contract_start_date" date NOT NULL,
	"contract_end_date" date);

CREATE TABLE "transfers"."player_awards"( 
	"id" int NOT NULL,
	"player_id" int NOT NULL,
	"award_id" int NOT NULL,
	"season_year" int NOT NULL);

CREATE TABLE "transfers"."positions"( 
	"id" int NOT NULL,
	"name" varchar(50) NOT NULL);

CREATE TABLE "transfers"."preffered_foot"( 
	"id" int NOT NULL,
	"name" varchar(5) NOT NULL);

CREATE TABLE "transfers"."stats"( 
	"id" int NOT NULL,
	"player_id" int NOT NULL,
	"league_season_id" int NOT NULL,
	"club_id" int NOT NULL,
	"appearances" int,
	"minutes_played" int,
	"goals" int,
	"assists" int,
	"yellow_cards" int,
	"red_cards" int);

CREATE TABLE "transfers"."transfers"( 
	"id" int NOT NULL,
	"player_id" int NOT NULL,
	"from_club_id" int,
	"to_club_id" int,
	"transfer_date" date NOT NULL,
	"fee" numeric(18, 2));

COMMIT;
