# postgresql-replication-experiments
Playing with postgresql replication.

# Requiremets

- docker

# Overall

This project for experimenting sync and async replication with postgresql.
`compose.yaml` starts 3 postgresql containers:
  - primary
	- replica-sync
	- replica-async
Steps:
	1. Comment out`synchronous_standby_names = '"replica-sync"'`  _./postgres-config/primary/postgresql.conf_ becuase if sync standby added and not running fisrt start fails for primary. (This step need only fresh start, after successdully db creation, we don't need it)
 2. Run `docker compose up -d` 
 3. Stop primary by `docker compose stop primary`
 4. Remove comment added in first stecomment added in first step
 5. Start primary `docker compose start primary`
 6. Run `select * from pg_stat_replication;` from primary DB, check if it has two replicas, with _sync_state_ sync and async.
