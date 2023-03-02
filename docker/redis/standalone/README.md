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

### 配置信息

### 1.1.1 设置docker compose版本

```yaml
version: '3'
```

### 1.1.2 设置services

```yaml
services:
  redis:
```

#### 设置 redis这个service的相关配置

#### 1.1.2.1 指定镜像

```yaml
    image: redis:latest
```

#### 1.1.2.2 指定容器名称

```yaml
    container_name: redis
```

#### 1.1.2.3 重启docker引擎后该容器也重启

```yaml
    restart: always
```

#### 1.1.2.4 指定映射端口

```yaml
    ports:
      - 6379:6379
```

#### 1.1.2.5 指定挂载目录

挂载一个目录或者一个已存在的数据卷容器，可以直接使用 [HOST:CONTAINER]格式，或者使用[HOST:CONTAINER:ro]格式，后者对于容器来说，数据卷是只读的，可以有效保护宿主机的文件系统。
Compose的数据卷指定路径可以是相对路径，使用 . 或者 .. 来指定相对目录。

这里配置了`redis.conf`文件和`data`目录分别映射了主机的`redis.conf`文件和主机的`data`目录

```yaml
    volumes:
      - ./conf/redis.conf:/etc/redis/redis.conf
      - data01:/data
      - logs01:/logs
```

#### 1.1.2.6 启动时执行的命令

　使用command可以覆盖容器启动后默认执行的命令。这里启动执行指定的`redis.conf`文件

```yaml
    command:
      /bin/bash -c "redis-server /etc/redis/redis.conf"
```

#### 1.1.2.7 使用的网络

```yaml
    networks:
      - default
```

### 1.1.3 网络配置

```yaml
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

## 2.1 后台启动应用

```bash
- 使用 docker-compose up -d 命令后台启动应用
- 使用docker ps 查看当前运行的容器
```

## 2.2 本地连接启动的服务

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