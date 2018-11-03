.ssh目录在用户目录下(自动生成，没有可以手动生成)

config文件用于配置不同站点代码库的私钥信息(手动创建)

known_hosts自动生成，每次有新的[域名<--->IP]关系将会添加到文件中，此文件一般在第一次使用git clone时自动生成

github_rsa是ssh协议的私钥文件（手动生成）

github_rsa.pub是ssh协议的公钥文件（手动生成）


github_rsa与github_rsa.pub文件是一对，config文件中每新增一个host的配置，一般需要生成一对公司钥来支持ssh协议，当然所有仓库统一使用一对公私钥也是可以的，就看自己的喜好

生成公司钥命令：ssh-keygen -t rsa -C 'csucjh@163.com' -f id_rsa 注意会提示输入密码，如果选择输入密码则每次提交代码都会要求验证密码，所以一般不设置（毕竟没人闲的蛋疼冒充你去改你的代码）

最后，把生成的公钥配置到代码库中，就可以使用git clone克隆代码库了


#################################################################
1、生成SSH key
	ssh-keygen -t rsa -C "csucjh@163.com" -f ~/.ssh/id_rsa

2、Adding your SSH key to the ssh-agent(linux才必须要)
	ssh-add ~/.ssh/id_rsa

	若执行ssh-add ....是出现错误:Could not open a connection to your authentication agent，则先执行如下命令即可：
	ssh-agent bash
	再执行add命令

	Permissions 0664 for '.ssh/github_rsa' are too open.
	It is required that your private key files are NOT accessible by others.
	This private key will be ignored.
	chmod  600 ~/.ssh/*


3、测试SSH connection
	ssh -vT git@github.com

	查看md5码
	ssh-keygen -E md5 -lf ~/.ssh/id_rsa

4、配置多站点
	touch ~/.ssh/config
	参考config配置