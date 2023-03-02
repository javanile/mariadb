
## ====
## Dist
## ====

update:
	@bash contrib/update.sh
	@docker compose build mariadb

release:
	@bash contrib/update.sh --release

## ====
## Test
## ====

test-dataset: update
	@docker compose down -v
	@docker compose up -d mariadb
	@docker compose exec mariadb dataset load sample
	@rm -f tests/fixtures/dataset/sample-clone.sql && true
	@docker compose exec mariadb dataset save sample-clone

test-my-cnf: update
	@docker compose up -d --force-recreate mysql
	@docker compose exec mariadb sh -c "cat /etc/mysql/my.cnf"
	@docker compose exec mariadb execute "SHOW VARIABLES LIKE 'delayed_insert_timeout'"

test-execute: update
	@docker compose up -d --force-recreate mariadb
	@docker compose exec mariadb execute "SHOW DATABASES"
