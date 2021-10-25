
## docker-elasticsearch

##  安装并启动

1. 创建data和logs目录

```
mkdir -p backup/{config/{es01,es02,es03},snapshot}
目录授权
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

5. 浏览器访问localhost:9200

输入elastic和对应的密码即可

6. 浏览器访问localhost:5601

kibana里输入elastic和对应密码即可

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