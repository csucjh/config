# 使用docker-compose创建Redis集群

版本信息：5.0.6

# 一、结构如下

## 1.1 docker-compose的网络

### 1.1.1 docker-compose中project、service、container

```
Docker-Compose将所管理的容器分为三层，分别是工程（project），服务（service）以及容器（container）

项目 (project)：由一组关联的应用容器组成的一个完整业务单元，在 docker-compose.yml 文件中定义。即是Compose的一个配置文件可以解析为一个项目，Compose通过分析指定配置文件，得出配置文件所需完成的所有容器管理与部署操作。

服务 (service)：一个应用的容器，实际上可以包括若干运行相同镜像的容器实例。每个服务都有自己的名字、使用的镜像、挂载的数据卷、所属的网络、依赖哪些其他服务等等，即以容器为粒度，用户需要Compose所完成的任务。

容器 (container)：一个运行起来的容器示例，可以通过docker ps -a看到的
```

### 1.1.2 network_mode

```
network_mode不会创建新网络

network_mode: "bridge"    桥接模式，容器内部网络和宿主机网络桥接，不是一个网段
network_mode: "host"      宿主机模式，容器直接使用宿主机网络
network_mode: "none"      禁用网络，感觉没啥用
network_mode: "service:[service name]"  共享docker-compose.yml中定义的services中的某个service的网络
network_mode: "container:[container name/id]"  共享某个具体在运行中的容器实例的网络
```

### 1.1.3 networks

```
networks会创建新网络，名称为redis，类型是桥接
networks:
  redis:
    driver: bridge
```



## 1.2 docker-compose-host.yaml（使用宿主机网络）

Windows下Docker desktop不能用host模式：参考[Use host networking (docker.com)](https://docs.docker.com/network/host/)

```
The host networking driver only works on Linux hosts, and is not supported on Docker Desktop for Mac, Docker Desktop for Windows, or Docker EE for Windows Server.
```

host的配置文件如下：

```yaml
version: '3'
services:
  # redis-01配置
  redis-01:
    image: redis:5.0
    container_name: redis-01
    environment:
      - TZ=Asia/Shanghai
    ports:
      - 6379:6379
      - 16379:16379
    stdin_open: true # 标准输入打开
    tty: true # 后台运行不退出
    privileged: true # 拥有容器内命令执行的权限
    network_mode: "host" #不会生成新的网络 直接使用宿主机网络，不然redis info replication的slave中会显示容器内网络的ip
    volumes:
      - ./conf/6379/redis.conf:/config/redis.conf
      - ./data/6379:/data
      - ./logs/6379:/logs
    command: [ "redis-server", "/config/redis.conf" ] # 设置服务默认的启动命令
    
  # redis2配置
  redis-02:
    image: redis:5.0
    container_name: redis-02
    environment: # 环境变量
      - TZ=Asia/Shanghai
    ports:
      - 6380:6380
      - 16380:16380
    stdin_open: true # 标准输入打开
    tty: true # 后台运行不退出
    privileged: true # 拥有容器内命令执行的权限
    network_mode: "host" #不会生成新的网络 直接使用宿主机网络，不然redis info replication的slave中会显示容器内网络的ip
    volumes:
      - ./conf/6380/redis.conf:/config/redis.conf
      - ./data/6380:/data
      - ./logs/6380:/logs
    command: [ "redis-server", "/config/redis.conf" ] # 设置服务默认的启动命令
    
  # redis-03配置
  redis3:
    image: redis:5.0
    container_name: redis-03
    environment: # 环境变量
      - TZ=Asia/Shanghai
    ports:
      - 6381:6381
      - 16381:16381
    stdin_open: true # 标准输入打开
    tty: true # 后台运行不退出
    privileged: true # 拥有容器内命令执行的权限
    network_mode: "host" #不会生成新的网络 直接使用宿主机网络，不然redis info replication的slave中会显示容器内网络的ip
    volumes:
      - ./conf/6381/redis.conf:/config/redis.conf
      - ./data/6381:/data
      - ./logs/6381:/logs
    command: [ "redis-server", "/config/redis.conf" ] # 设置服务默认的启动命令
    
  # redis4配置
  redis-04:
    image: redis:5.0
    container_name: redis-04
    environment: # 环境变量
      - TZ=Asia/Shanghai
    ports:
      - 6382:6382
      - 16382:16382
    stdin_open: true # 标准输入打开
    tty: true # 后台运行不退出
    privileged: true # 拥有容器内命令执行的权限
    network_mode: "host" #不会生成新的网络 直接使用宿主机网络，不然redis info replication的slave中会显示容器内网络的ip
    volumes:
      - ./conf/6382/redis.conf:/config/redis.conf
      - ./data/6382:/data
      - ./logs/6382:/logs
    command: [ "redis-server", "/config/redis.conf" ] # 设置服务默认的启动命令
    
  # redis5配置
  redis-05:
    image: redis:5.0
    container_name: redis-05
    environment: # 环境变量
      - TZ=Asia/Shanghai
    ports:
      - 6383:6383
      - 16383:16383    
    stdin_open: true # 标准输入打开
    tty: true # 后台运行不退出
    privileged: true # 拥有容器内命令执行的权限
    network_mode: "host" #不会生成新的网络 直接使用宿主机网络，不然redis info replication的slave中会显示容器内网络的ip
    volumes:
      - ./conf/6383/redis.conf:/config/redis.conf
      - ./data/6383:/data
      - ./logs/6383:/logs
    command: [ "redis-server", "/config/redis.conf" ] # 设置服务默认的启动命令
    
  # redis6配置
  redis-06:
    image: redis:5.0
    container_name: redis-06
    environment: # 环境变量
      - TZ=Asia/Shanghai
    ports:
      - 6384:6384
      - 16384:16384    
    stdin_open: true # 标准输入打开
    tty: true # 后台运行不退出
    privileged: true # 拥有容器内命令执行的权限
    network_mode: "host" #不会生成新的网络 直接使用宿主机网络，不然redis info replication的slave中会显示容器内网络的ip
    volumes:
      - ./conf/6384/redis.conf:/config/redis.conf
      - ./data/6384:/data
      - ./logs/6384:/logs
    command: [ "redis-server", "/config/redis.conf" ] # 设置服务默认的启动命令
```



## 1.3 docker-compose-bridge.yaml（使用桥接网络）

```yaml
version: '3'
services:
  # redis-01配置
  redis-01:
    image: redis:5.0
    container_name: redis-01
    environment:
      - TZ=Asia/Shanghai
    ports:
      - 6379:6379
      - 16379:16379
    stdin_open: true # 标准输入打开
    tty: true # 后台运行不退出
    privileged: true # 拥有容器内命令执行的权限
    networks:
      - redis
    volumes:
      - ./conf/6379/redis.conf:/config/redis.conf
      - ./data/6379:/data
      - ./logs/6379:/logs
    command: [ "redis-server", "/config/redis.conf" ] # 设置服务默认的启动命令
    
  # redis2配置
  redis-02:
    image: redis:5.0
    container_name: redis-02
    environment: # 环境变量
      - TZ=Asia/Shanghai
    ports:
      - 6380:6380
      - 16380:16380
    stdin_open: true # 标准输入打开
    tty: true # 后台运行不退出
    privileged: true # 拥有容器内命令执行的权限
    networks:
      - redis
    volumes:
      - ./conf/6380/redis.conf:/config/redis.conf
      - ./data/6380:/data
      - ./logs/6380:/logs
    command: [ "redis-server", "/config/redis.conf" ] # 设置服务默认的启动命令
    
  # redis-03配置
  redis3:
    image: redis:5.0
    container_name: redis-03
    environment: # 环境变量
      - TZ=Asia/Shanghai
    ports:
      - 6381:6381
      - 16381:16381
    stdin_open: true # 标准输入打开
    tty: true # 后台运行不退出
    networks:
      - redis
    volumes:
      - ./conf/6381/redis.conf:/config/redis.conf
      - ./data/6381:/data
      - ./logs/6381:/logs
    command: [ "redis-server", "/config/redis.conf" ] # 设置服务默认的启动命令
    
  # redis4配置
  redis-04:
    image: redis:5.0
    container_name: redis-04
    environment: # 环境变量
      - TZ=Asia/Shanghai
    ports:
      - 6382:6382
      - 16382:16382
    stdin_open: true # 标准输入打开
    tty: true # 后台运行不退出
    networks:
      - redis
    volumes:
      - ./conf/6382/redis.conf:/config/redis.conf
      - ./data/6382:/data
      - ./logs/6382:/logs
    command: [ "redis-server", "/config/redis.conf" ] # 设置服务默认的启动命令
    
  # redis5配置
  redis-05:
    image: redis:5.0
    container_name: redis-05
    environment: # 环境变量
      - TZ=Asia/Shanghai
    ports:
      - 6383:6383
      - 16383:16383    
    stdin_open: true # 标准输入打开
    tty: true # 后台运行不退出
    networks:
      - redis
    volumes:
      - ./conf/6383/redis.conf:/config/redis.conf
      - ./data/6383:/data
      - ./logs/6383:/logs
    command: [ "redis-server", "/config/redis.conf" ] # 设置服务默认的启动命令
    
  # redis6配置
  redis-06:
    image: redis:5.0
    container_name: redis-06
    environment: # 环境变量
      - TZ=Asia/Shanghai
    ports:
      - 6384:6384
      - 16384:16384    
    stdin_open: true # 标准输入打开
    tty: true # 后台运行不退出
    networks:
      - redis
    volumes:
      - ./conf/6384/redis.conf:/config/redis.conf
      - ./data/6384:/data
      - ./logs/6384:/logs
    command: [ "redis-server", "/config/redis.conf" ] # 设置服务默认的启动命令
    
networks:
  redis:
    driver: bridge
```



## 1.2 redis-cluster.tmpl

redis.conf的配置模板，其中端口${PORT}是占位符

```
bind 0.0.0.0
#禁止后台运行，不然docker容器会退出
daemonize no
protected-mode no
port ${PORT}
timeout 0
save 900 1
save 300 10
save 60 10000
rdbcompression yes
dbfilename dump.rdb
appendonly yes
dir /data
appendfsync everysec
cluster-enabled yes
cluster-config-file nodes.conf
cluster-node-timeout 10000
#这里是部署redis容器所在机器的宿主机ip，不填的话默认是docker桥接网关的ip，会导致外部不能访问容器集群redis
cluster-announce-ip 192.168.1.6
cluster-announce-port ${PORT}
cluster-announce-bus-port 1${PORT}
requirepass 123456
masterauth 123456
pidfile /var/run/redis.pid
# 日志配置
# debug:会打印生成大量信息，适用于开发/测试阶段
# verbose:包含很多不太有用的信息，但是不像debug级别那么混乱
# notice:适度冗长，适用于生产环境
# warning:仅记录非常重要、关键的警告消息
loglevel notice
# 日志文件路径
logfile "/logs/redis.log"
```

使用linux命令自动生成目录结构，并填充模板中的端口号

```sh
for port in `seq 6379 6384`; 
do \
mkdir -p conf/${port} \
&& PORT=${port} envsubst <redis-cluster.tmpl> conf/${port}/redis.conf \
&& mkdir -p logs/${port} \
&& mkdir -p data/${port};\
done
```



## 二、 启动容器

## 2.1 后台启动应用

```bash
# 我们这里先使用桥接网络模式，为了方便先重命名下
mv docker-compose-bridge.yml docker-compose.yml

# 部署和销毁容器实例[不用-f参数指定yml文件]
- 使用 docker-compose up -d 命令后台启动应用
- 使用 docker-compose down 卸载应用
- 使用docker ps -a 查看容器
```

## 2.2 进入容器后创建集群

```bash
# 进入容器内部(可以随便哪一个容器的id)
docker exec -it container_id /bin/bash

# 这里使用宿主机ip，不能弄localhost，--cluster-replicas 1意思是每个master有一个slave节点
redis-cli -a 123456 -p 6379 --cluster create \
192.168.1.6:6379 \
192.168.1.6:6380 \
192.168.1.6:6381 \
192.168.1.6:6382 \
192.168.1.6:6383 \
192.168.1.6:6384 \
--cluster-replicas 1


# 执行cluster create后输出如下信息，说明集群创建成功
Master[0] -> Slots 0 - 5460
Master[1] -> Slots 5461 - 10922
Master[2] -> Slots 10923 - 16383
Adding replica 192.168.1.6:6383 to 192.168.1.6:6379
Adding replica 192.168.1.6:6384 to 192.168.1.6:6380
Adding replica 192.168.1.6:6382 to 192.168.1.6:6381

# redis-cli -a 123456 -p 6379连接redis后
cluster info 查看集群信息
cluster nodes查看节点信息：我们会看到这里输出的ip是上文cluster-announce-ip配置中的ip
```

