## 1、创建日志和数据目录

```
mkdir -p logs/{ck01-01,ck01-02,ck02-01,ck02-02}
mkdir -p data/{ck01-01,ck01-02,ck02-01,ck02-02}
```



## 2、启动卸载

```
启动：docker-compose up -d
卸载：docker-compose down
```



## 3、查看集群信息

```
select * from system.clusters;
```

