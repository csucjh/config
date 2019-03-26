###/etc/gitlab/gitlab.rb


## GitLab URL
## 配置项目clone地址显示的域名
external_url 'https://git.airportpark.com.cn'

### Trusted proxies
### 添加NG地址到信任列表，我这里就是本机地址
gitlab_rails['trusted_proxies'] = ['127.0.0.1','172.31.88.58']


### For setting up different data storing directory
### git仓库存储路径
git_data_dirs({ "default" => { "path" => "/data/gitlabData" } })



################################################################################
## GitLab Workhorse
##! Docs: https://gitlab.com/gitlab-org/gitlab-workhorse/blob/master/README.md
################################################################################
## 配置监听网络：tcp
gitlab_workhorse['listen_network'] = "tcp"
## 配置GitLab的地址和端口
gitlab_workhorse['listen_addr'] = "0.0.0.0:9999"


################################################################################
## GitLab Web server
##! Docs: https://docs.gitlab.com/omnibus/settings/nginx.html#using-a-non-bundled-web-server
################################################################################
##! When bundled nginx is disabled we need to add the external webserver user to the GitLab webserver group.
## 指定NG的用户名
web_server['external_users'] = ['root']

################################################################################
## GitLab NGINX
##! Docs: https://docs.gitlab.com/omnibus/settings/nginx.html
################################################################################
## 禁用内置NG
nginx['enable'] = false
