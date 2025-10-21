use [master]
go

create login db_admin 
with password = 'adminPassword123!@#',
default_database = [FootballDB];
go

create login db_editor
with password = 'editorPassword123!@#',
default_database = [FootballDB];
go

create login db_analyst 
with password = 'analystPassword123!@#',
default_database = [FootballDB];
go

use [FootballDB]
go

create user db_analyst
for login db_analyst;
go

create user db_admin
for login db_admin;
go

create user db_editor
for login db_editor;
go

-- dodanie pełnych uprawnień adminowi
alter role [db_owner] add member [db_admin]
go

-- dodanie uprawnień editorowi 
grant select on schema :: [Transfers] to [db_editor]
grant insert, update, delete on Transfers.TRANSFERS to [db_editor]
grant insert, update, delete on Transfers.PLAYERS to [db_editor]
grant insert, update, delete on Transfers.STATS to [db_editor]
go

grant select on schema :: [Transfers] to [db_analyst]
go