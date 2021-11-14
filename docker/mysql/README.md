docker-compose -f docker-compose.yml up -d


docker exec -it 9956858f08fe /bin/sh

mysql -h localhost -P 3306 -u root -pexample -Dmy_db

CREATE TABLE `t` (
`id` int(11) NOT NULL,
`k` int(11) DEFAULT NULL,
PRIMARY KEY (`id`)
) ENGINE=InnoDB;

insert into t(id, k) values(1,1);

start transaction with consistent snapshot;

select k from t where id = 1;


update t set k = k+1 where id = 1;

select k from t;

select k from t where id > 0 and id < 10 for update;
update t set k = 1 where id > 0 and id < 10;
insert into t(id, k) values(2,2);
