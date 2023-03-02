# docker-compose.yaml

## 一 、docker-compose基本介绍

### 1.1 中project、service、container

```
Docker-Compose将所管理的容器分为三层，分别是工程（project），服务（service）以及容器（container）

项目 (project)：由一组关联的应用容器组成的一个完整业务单元，在 docker-compose.yml 文件中定义。即是Compose的一个配置文件可以解析为一个项目，Compose通过分析指定配置文件，得出配置文件所需完成的所有容器管理与部署操作。

服务 (service)：一个应用的容器，实际上可以包括若干运行相同镜像的容器实例。每个服务都有自己的名字、使用的镜像、挂载的数据卷、所属的网络、依赖哪些其他服务等等，即以容器为粒度，用户需要Compose所完成的任务。

容器 (container)：一个运行起来的容器示例，可以通过docker ps -a看到的
```



## 二、配置信息

### 1.1.1 设置docker compose版本

```yaml
version: '3'
```

### 1.1.2 设置services

```yaml
services:
  redis: # 服务名
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

#### 1.1.2.3 重启docker引擎后重启容器

```yaml
    restart: always
```

#### 1.1.2.4 映射端口到宿主机

```yaml
    ports: #expose只在容器内部导出端口，宿主机不能访问，ports是映射到宿主机的
      - 6379:6379
      - 16379:16379
```

#### 1.1.2.5 volumes

挂载一个目录或者一个已存在的数据卷容器，可以直接使用 [HOST:CONTAINER]格式，或者使用[HOST:CONTAINER:ro]格式，后者对于容器来说，数据卷是只读的，可以有效保护宿主机的文件系统。
Compose的数据卷指定路径可以是相对路径，使用 . 或者 .. 来指定相对目录。

这里配置了`redis.conf`文件和`data`目录分别映射了主机的`redis.conf`文件和主机的`data`目录

```yaml
    volumes: #指定挂载目录
      - ./conf/redis.conf:/etc/redis/redis.conf
      - data01:/data  #引用1.1.4中定义的本地挂载卷data01
      - logs01:/logs  #引用1.1.4中定义的本地挂载卷logs01
```

#### 1.1.2.6 启动时执行的命令

　使用command可以覆盖容器启动后默认执行的命令。这里启动执行指定的`redis.conf`文件

```yaml
    command:
     	 /bin/bash -c "redis-server /etc/redis/redis.conf"
```

#### 1.1.2.7 networks

```yaml
    networks:
      	- redis  #引用1.1.3中定义的本地内部网络redis
```

#### 1.1.2.9 network_mode网络模式

```yaml
    # "bridge"    桥接模式，容器内部网络和宿主机网络桥接，不是一个网段
    # "host"      宿主机模式，不会生成新的网络，直接使用宿主机网络
    # "none"      禁用网络，感觉没啥用
    # "service:[service name]"  共享docker-compose.yml中定义的services中的某个service的网络
    # "container:[container name/id]"  共享某个具体在运行中的容器实例的网络
    network_mode: "host"
```

host模式仅能在linux主机上使用：参考[Use host networking (docker.com)](https://docs.docker.com/network/host/)

```
The host networking driver only works on Linux hosts, and is not supported on Docker Desktop for Mac, Docker Desktop for Windows, or Docker EE for Windows Server.
```

#### 1.1.2.10 环境变量

```yaml
    environment: # 环境变量
     	 - TZ=Asia/Shanghai
```



------

### 1.1.3 networks

```yaml
#networks与version同级时，为当前compose文件创建新的内部网络
networks:
  redis: #自定义内部网络[该名称可以被service中networks引用]
    driver: bridge  #网络模式桥接
    name: redis  #指定网络名称，不指定默认是当前目录名、下划线、网络名
```

### 1.1.4 volumes

```yaml
volumes:
  data01: #本地数据卷
    driver: local
  logs01: #本地日志卷
    driver: local
```



------

## 三、 容器操作

### 2.1 后台启动应用

```yaml
docker-compose:
    -f 指定具体的配置文件
    -p 指定compose的project name，默认就是所在目录名称

    
# 为了命令简化将自己的yml重命名为docker-compose.yml
mv docker-compose-bridge.yml docker-compose.yml

# 部署和销毁容器实例[不用-f参数指定yml文件]
- 使用 docker-compose up -d 命令后台启动应用  #没有重命名需要docker-compose -f docker-compose-bridge.yml up -d
- 使用 docker-compose down 卸载应用
- 使用 docker-compose restart 重启应用
- 使用 docker-compose stop 停止应用，但是不会卸载
```



## 2.2 docker基本操作

```yaml
# 使用查看容器
docker ps -a

# 进入es pod内部
docker exec -it es01 /bin/bash

#清理本地网络
docker network prune

#清理本地挂载卷
docker volume prune
```

