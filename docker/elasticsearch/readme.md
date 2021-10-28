[TOC]

##  安装并启动

1. 检查目录权限

```
查出来容器里的mysql用户组id
    docker run -ti --rm --entrypoint="/bin/bash" es镜像id -c "cat /etc/group"
    可以看到elasticsearch用户组的id为1000

    查看宿主机cat /etc/group,发现确实存在组id为1000的用户
    然后修改服务器文件用户组id
    sudo chown -R 1000:1000 backup (保证backup目录所属用户组和容器内部es运行的用户组一样，不然会有权限问题)

如果嫌麻烦可以直接简单粗暴，暂且授权给所有人好了
	sudo chmod 777 backup -R
```

2. 启动

```
docker-compose:
	-f 指定具体的配置文件
	-p 指定compose的project name，默认就是所在目录名称

ES集群：
    启动：docker-compose -f docker-compose.yml up -d
    停止：docker-compose -f docker-compose.yml stop
    重启：docker-compose -f docker-compose.yml restart
```

3. 生成密码

```
# 进入es pod内部
docker exec -it es01 /bin/bash

# 创建密码
[root@cfeeab4bb0eb elasticsearch]# ./bin/elasticsearch-setup-passwords auto
Initiating the setup of passwords for reserved users elastic,apm_system,kibana,logstash_system,beats_system,remote_monitoring_user.
The passwords will be randomly generated and printed to the console.
Please confirm that you would like to continue [y/N]y

Changed password for user apm_system
PASSWORD apm_system = j7NZWiWV6hY7ssTtuhK9

Changed password for user kibana_system
PASSWORD kibana_system = CawnYhDSfQfZiAqeKSOc

Changed password for user kibana
PASSWORD kibana = CawnYhDSfQfZiAqeKSOc

Changed password for user logstash_system
PASSWORD logstash_system = s4zELOabFgaTmKT6zCWT

Changed password for user beats_system
PASSWORD beats_system = jfW8i4Et0hKiNSYGsYRX

Changed password for user remote_monitoring_user
PASSWORD remote_monitoring_user = 3cRaIKBQ0rgTx86RMrW2

Changed password for user elastic
PASSWORD elastic = rxwPYHPPwYlUys9ZmpYn
```


4. 重新启动

修改kibana.yml

```
elasticsearch.password: 你的密码
```

重启

```
docker-compose -f docker-compose.yml restart
```

5. 浏览器访问localhost:9200  输入elastic和对应的密码即可

6. 浏览器访问localhost:5601  kibana里输入elastic和对应密码即可
7. 可选择安装metricbeat

```
# 加载metricbeat自带的dashboard模板
sudo docker run \
  --network=docker-elasticsearch_elastic \
docker.elastic.co/beats/metricbeat:7.6.2 \
setup -E setup.kibana.host=kib01:5601 \
-E output.elasticsearch.hosts=["es01:9200"] \
-E output.elasticsearch.username=elastic \
-E output.elasticsearch.password=q5f2qNfUJQyvZPIz57MZ


# 收集宿主机运行的docker实例信息
sudo docker rm metricbeat
sudo docker run -it \
  --network=docker-elasticsearch_elastic \
  --name=metricbeat \
  --user=root \
  --volume="$(pwd)/metricbeat.docker.yml:/usr/share/metricbeat/metricbeat.yml" \
  --volume="/var/run/docker.sock:/var/run/docker.sock:ro" \
  --volume="/sys/fs/cgroup:/hostfs/sys/fs/cgroup:ro" \
  --volume="/proc:/hostfs/proc:ro" \
  --volume="/:/hostfs:ro" \
  docker.elastic.co/beats/metricbeat:7.6.2 metricbeat \
   -E   ELASTICSEARCH_HOSTS=es01:9200 \
   -E   ELASTICSEARCH_USERNAME=elastic \
   -E   ELASTICSEARCH_PASSWORD=q5f2qNfUJQyvZPIz57MZ 
```

- network是要和es网络联通
- out到es需要填写es的密码

更多收集细节见 https://www.elastic.co/guide/en/beats/metricbeat/7.6/running-on-docker.html



##  备份安全配置

1. 创建backup目录

   ```
   # 如果目录存在就不用创建了
   mkdir -p backup/{config/{es01,es02,es03},snapshot}
   ```

2. 备份elasticsearch.keystore

   ```
   #详细备份请参考
   https://www.elastic.co/guide/en/elasticsearch/reference/current/security-backup.html
   
   #简单备份
   docker cp es01:/usr/share/elasticsearch/config/elasticsearch.keystore ./backup/config/es01/elasticsearch.keystore
   docker cp es02:/usr/share/elasticsearch/config/elasticsearch.keystore ./backup/config/es02/elasticsearch.keystore
   docker cp es03:/usr/share/elasticsearch/config/elasticsearch.keystore ./backup/config/es03/elasticsearch.keystore
   ```

3. 备份security-*索引快照

   ```
   #security-*索引主要包含：
       本机领域中的用户定义(包括散列密码)
       角色定义(通过创建角色API定义)
       角色映射(通过创建角色映射API定义)
       应用程序权限
       API密钥
       
   #创建可用于备份.security索引的存储库
   PUT _snapshot/my_backup
   {
     "type": "fs",
     "settings": {
       "location": "/usr/share/elasticsearch/backup"
     }
   }
   
   #创建一个用户，并且只给它分配内置的snapshot_user角色。
   POST /_security/user/snapshot_user
   {
     "password" : "secret",
     "roles" : [ "snapshot_user" ]
   }
   
   #将.security索引备份到my_backup存储库
   #include_global_state参数值捕获存储在全局集群元数据中的所有持久设置，以及其他配置，如别名和存储的脚本。注意，这包括非安全配置，它补充但不替代文件系统配置文件备份。
   #这里只备份安全数据，所以include_global_state是false
   PUT /_snapshot/my_backup/snapshot_1
   {
     "indices": ".security",
     "include_global_state": false 
   }
   ```

   

##  恢复安全配置

1. 先清理下本地数据

   ```
   #清理本地网络
   docker network prune
   
   #清理本地挂载卷
   docker volume prune
   ```

2. 重建集群

   ```
   docker-compose -f docker-compose.yml up -d
   ```

3. 使用初始密码进入系统

   ```
   # 进入es pod内部
   docker exec -it es01 /bin/bash
   
   # 创建密码
   [root@cfeeab4bb0eb elasticsearch]# ./bin/elasticsearch-setup-passwords auto
   
   # 使用elastic账号密码进入es-head管理集群（这里是临时密码，恢复后就失效了）
   http://localhost:9100/?auth_user=elastic&auth_password=7V5SYsKTf72RbSHN9RS9
   ```

4. 恢复快照数据

   ```
   # 查看自定义的备份配置
   GET _snapshot/my_backup
   
   # 备份配置不存在时执行(location是当时生成备份时的路径)
   PUT _snapshot/my_backup
   {
     "type": "fs",
     "settings": {
       "location": "/usr/share/elasticsearch/backup"
     }
   }
   
   # 查看自定义备份配置下的已备份快照(这一步是不会重新创建的)
   GET _snapshot/my_backup/snapshot_1
   ```

   

5. 使用超级用户增加一个恢复用账户

   ```
   docker exec -it es01 /bin/bash
   
   #为了方便，恢复密码简单使用111111
   bin/elasticsearch-users useradd restore_user -p 111111 -r superuser
   ```

6. 因为是从快照恢复，可能之前存在过.security-*索引，需要删除

   ```
   curl -u restore_user -X DELETE "localhost:9200/.security-*"
   ```

   ![image-20211026162652744](https://user-images.githubusercontent.com/12841424/138844909-045218dd-64c9-4b3f-a5c7-05451f38bdfc.png)

7. 从快照恢复security-*索引

   ```
   # "include_global_state": false 代表只从快照中恢复security-*索引
   curl -u restore_user -X POST "localhost:9200/_snapshot/my_backup/snapshot_1/_restore" -H 'Content-Type: application/json' -d '{ "indices": ".security-*", "include_global_state": false}'
   ```

   ![image-20211026162609737](https://user-images.githubusercontent.com/12841424/138844971-a381ddf1-4afb-437f-9e97-3aa4e52f08b0.png)

8. 重启看结果

   ```
   # 重启集群
   docker-compose -f docker-compose.yml restart
   
   #临时密码已经失效
   http://localhost:9100/?auth_user=elastic&auth_password=7V5SYsKTf72RbSHN9RS9
   
   #恢复后的密码可以访问了
   http://localhost:9100/?auth_user=elastic&auth_password=rxwPYHPPwYlUys9ZmpYn
   ```
   
   
