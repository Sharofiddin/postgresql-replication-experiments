CREATE user replicator WITH replication encrypted password 'replicator_pass';
SELECT pg_create_physical_replication_slot('sync_slot');
SELECT pg_create_physical_replication_slot('async_slot');
