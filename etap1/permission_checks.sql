insert into Transfers.TRANSFERS (player_id, from_club_id, to_club_id, transfer_date, fee) values (1, 1, 2, '2025-01-01', 100000)

insert into Transfers.AGENTS (first_name, last_name, company) values ('sample', 'agent', 'company')

delete from Transfers.AGENTS where first_name = 'sample'

select * from Transfers.PLAYERS