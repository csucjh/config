# 使用docker-compose创建Redis单机模式

版本信息：5.0.6

# 一、结构如下

## 1.1 docker-compose.yaml

```yaml
version: '3'

services:
  redis:
    image: redis:latest
    container_name: redis
    restart: always
    ports:
      - 6379:6379
    networks:
      - default
    volumes:
      - ./conf/redis.conf:/etc/redis/redis.conf
      - data01:/data
      - logs01:/logs
    command:
      /bin/bash -c "redis-server /etc/redis/redis.conf"
      
volumes:
  data01:
    driver: local
  logs01:
    driver: local
    
networks:
  default:
    driver: bridge
```

## 1.2 redis.conf

```
bind 0.0.0.0
protected-mode no
port 6379
timeout 0
save 900 1 # 900s内至少一次写操作则执行bgsave进行RDB持久化
save 300 10
save 60 10000
rdbcompression yes
dbfilename dump.rdb
dir /data
appendonly yes
appendfsync everysec
requirepass 123456
```

这个是根据自己需要设置的redis配置参数



## 二、 启动容器

## 2.1 本地连接启动的服务

```bash
~ docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                    NAMES
6d784c652a20        redis:latest        "docker-entrypoint.s…"   3 minutes ago       Up 3 minutes        0.0.0.0:6379->6379/tcp   redis

~ docker exec -it 6d784c652a20 redis-cli
127.0.0.1:6379> 
127.0.0.1:6379> keys *
(error) NOAUTH Authentication required.
127.0.0.1:6379> auth 123456
OK
127.0.0.1:6379> keys *
1) "name"
127.0.0.1:6379> get name
"zhangsan"
127.0.0.1:6379> 
```

- docker ps 查看当前运行的服务
- docker exec -it 6d784c652a20 redis-cli 连接redis服务
- keys * 查看当前redis中的key
- auth 123456 验证密码

到此结束