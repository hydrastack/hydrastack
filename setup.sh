sudo sed -i 's/wget/#wget/g' /etc/rc.d/rc.local

sudo sed -i "s/PasswordAuthentication yes/PasswordAuthentication no/g" /etc/ssh/sshd_config

#sudo echo -e "hydrastack\hydrastack" | passwd root

#sudo wget --no-check-certificate http://download.oracle.com/otn-pub/java/jdk/7/jdk-7-linux-x64.tar.gz -O /hydra/install/jdk-7-linux-x64.tar.gz
#sudo wget --no-check-certificate http://www.apache.org/dist/tomcat/tomcat-7/v7.0.21/bin/apache-tomcat-7.0.21.tar.gz -O /hydra/install/apache-tomcat-7.0.21.tar.gz

sudo wget --no-check-certificate http://beta.hydrastack.com/downloads/jdk-7-linux-x64.tar.gz -O /hydra/install/jdk-7-linux-x64.tar.gz
sudo wget --no-check-certificate http://beta.hydrastack.com/downloads/apache-tomcat-7.0.21.tar.gz -O /hydra/install/apache-tomcat-7.0.21.tar.gz

sudo mkdir /hydra/sites/

cd /hydra/install/
sudo tar -xf /hydra/install/jdk-7-linux-x64.tar.gz
cd /hydra/
sudo tar -xf /hydra/install/apache-tomcat-7.0.21.tar.gz
sudo mv /hydra/apache-tomcat-7.0.21 /hydra/tomcat
sudo rpm -Uvh http://download.fedora.redhat.com/pub/epel/6/x86_64/epel-release-6-5.noarch.rpm
sudo rpm -Uvh http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.2-2.el6.rf.x86_64.rpm
sudo yum -y install git

sudo chown -R hydra /hydra

sudo git clone git://github.com/hydrastack/hydrastack.git repo

sudo chown -R hydra /hydra

sudo grep -rl example.com /hydra/repo/ | sudo xargs sudo sed -i "s|example.com|$DOMAINNAME|g"
sudo grep -rl hydrastack.com /hydra/repo/ | sudo xargs sudo sed -i "s|hydrastack.com|$DOMAINNAME|g"

#sudo cp /hydra/repo/assets/id_rsa /home/hydra/.ssh/id_rsa
#sudo cp /hydra/repo/assets/id_rsa.pub /home/hydra/.ssh/id_rsa.pub

#sudo cp /hydra/repo/assets/id_rsa /root/.ssh/id_rsa
#sudo cp /hydra/repo/assets/id_rsa.pub /root/.ssh/id_rsa.pub

sudo yum -y install httpd mod_ssl
sudo yum -y install nginx
sudo yum -y install mysql-devel
sudo yum -y install mysql-server

#cd /hydra/
#sudo wget http://nginx.org/download/nginx-1.0.5.tar.gz
#sudo tar zxvf nginx-1.0.5.tar.gz
#cd nginx-1.0.5
#yum install -y pcre-devel.x86_64
#sudo ./configure
#sudo make
#sudo make install

sudo mkdir /hydra/sites
sudo mkdir /hydra/sites/$DOMAINNAME
sudo mkdir /hydra/sites/$DOMAINNAME/ROOT
sudo mkdir /hydra/sites/$DOMAINNAME/ROOT/WEB-INF
sudo mkdir /hydra/sites/$DOMAINNAME/ROOT/WEB-INF/lib

sudo mkdir /etc/httpd/conf/hydra/

sudo cp /hydra/repo/assets/httpd.conf /etc/httpd/conf/httpd.conf
sudo cp /hydra/repo/assets/httpd-vhosts.conf /etc/httpd/conf/hydra/httpd-vhosts.conf
sudo cp /hydra/repo/assets/ssl.sh /etc/httpd/conf/ssl.sh

sudo cp /hydra/repo/assets/nginx.conf /etc/nginx/nginx.conf

sudo cp /hydra/repo/assets/catalina.properties /hydra/tomcat/conf/catalina.properties
sudo cp /hydra/repo/assets/server.xml /hydra/tomcat/conf/server.xml
sudo cp /hydra/repo/assets/webNoRewrite.xml /hydra/tomcat/conf/web.xml

sudo cp /hydra/repo/assets/web.xml /hydra/sites/$DOMAINNAME/ROOT/WEB-INF/web.xml
sudo cp /hydra/repo/assets/webNoRewrite.xml /hydra/tomcat/webapps/ROOT/WEB-INF/web.xml
sudo cp /hydra/repo/assets/urlrewrite.xml /hydra/sites/$DOMAINNAME/ROOT/WEB-INF/urlrewrite.xml
sudo cp /hydra/repo/assets/lib/urlrewrite-3.2.0.jar /hydra/sites/$DOMAINNAME/ROOT/WEB-INF/lib/urlrewrite-3.2.0.jar

sudo cp /hydra/repo/java.sh /etc/profile.d/java.sh
sudo chmod +x /etc/profile.d/java.sh

sudo cp /hydra/repo/assets/tomcat /etc/init.d/tomcat
sudo chmod +x /etc/init.d/tomcat

sudo cp /hydra/repo/assets/bigcouch /etc/init.d/bigcouch
sudo chmod +x /etc/init.d/bigcouch

source /etc/bashrc
source ~/.bashrc

cd /hydra/install/

#sudo wget --no-check-certificate http://www.getrailo.org/down.cfm?item=/railo/remote/download/3.2.3.000/custom/all/railo-3.2.3.000-jars.tar.gz -O /hydra/install/railo.tar.gz
sudo wget --no-check-certificate http://beta.hydrastack.com/downloads/railo-3.3.1.000-jars.tar.gz -O /hydra/install/railo.tar.gz

sudo tar -xvf /hydra/install/railo.tar.gz

sudo mv /hydra/install/railo-3.3.1.000-jars /hydra/tomcat/railo

cd /hydra/sites/

sudo git clone git://github.com/ColdBox/coldbox-platform.git
cd /hydra/sites/coldbox-platform
sudo git checkout development

sudo mv /hydra/sites/coldbox-platform /hydra/sites/coldbox

sudo cp -r /hydra/sites/coldbox /hydra/sites/$DOMAINNAME/ROOT/coldbox

sudo cp -r /hydra/repo/application/* /hydra/sites/$DOMAINNAME/ROOT/

sudo cp -r /hydra/repo/assets/jqm /hydra/sites/$DOMAINNAME/ROOT/

#sudo wget --no-check-certificate https://github.com/ColdBox/coldbox-platform/tarball/development -O /hydra/sites/coldbox.tar.gz
#sudo tar xf coldbox.tar.gz

cd /hydra

sudo git clone git://github.com/hydrastack/ContentBox.git

sudo mkdir /hydra/sites/blog
sudo mkdir /hydra/sites/blog/ROOT
sudo mkdir /hydra/sites/blog/ROOT/WEB-INF
sudo mkdir /hydra/sites/blog/ROOT/WEB-INF/lib

sudo mv /hydra/ContentBox/* /hydra/sites/blog/ROOT/

sudo cp /hydra/repo/assets/web.xml /hydra/sites/blog/ROOT/WEB-INF/web.xml
sudo cp /hydra/repo/assets/urlrewriteContentBox.xml /hydra/sites/blog/ROOT/WEB-INF/urlrewrite.xml
sudo cp /hydra/repo/assets/lib/urlrewrite-3.2.0.jar /hydra/sites/blog/ROOT/WEB-INF/lib/urlrewrite-3.2.0.jar
sudo cp /hydra/repo/assets/ContentBoxRoutes.cfm /hydra/sites/blog/ROOT/config/Routes.cfm
sudo mkdir /hydra/repo/assets/railo/railo-webContentBox.xml.cfm /hydra/sites/blog/ROOT/WEB-INF/railo/
sudo cp /hydra/repo/assets/railo/railo-webContentBox.xml.cfm /hydra/sites/blog/ROOT/WEB-INF/railo/railo-web.xml.cfm

sudo cp -R /hydra/repo/assets/contentbox/bootstrap /hydra/sites/blog/ROOT/modules/contentbox-ui/layouts/

sudo chmod +x /hydra/*
sudo chown -R hydra /hydra

JAVA_HOME=/hydra/install/jdk1.7.0
JAVA_PATH=/hydra/install/jdk1.7.0

export JAVA_HOME=/hydra/install/jdk1.7.0
export JAVA_PATH=/hydra/install/jdk1.7.0

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin:/hydra/install/jdk1.7.0/bin:/hydra/install/maven/bin:/root/bin:/hydra/install/jdk1.7.0:/hydra/install/maven
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin:/hydra/install/jdk1.7.0/bin:/hydra/install/maven/bin:/root/bin:/hydra/install/jdk1.7.0:/hydra/install/maven

#/hydra/tomcat/bin/startup.sh

sudo cp /hydra/repo/assets/modules/mod_cache.so /etc/httpd/modules/mod_cache.so
sudo cp /hydra/repo/assets/modules/mod_file_cache.so /etc/httpd/modules/mod_file_cache.so
sudo cp /hydra/repo/assets/modules/mod_mem_cache.so /etc/httpd/modules/mod_mem_cache.so

sudo service tomcat start
sudo service httpd start
sudo service mysqld start

sleep 10

sudo mkdir /hydra/tomcat/railo/railo-server/
sudo mkdir /hydra/tomcat/railo/railo-server/context/
sudo mkdir /hydra/tomcat/railo/railo-server/context/admin/
sudo mkdir /hydra/tomcat/webapps/ROOT/WEB-INF/railo/
sudo mkdir /hydra/tomcat/webapps/ROOT/WEB-INF/railo/context/
sudo mkdir /hydra/tomcat/webapps/ROOT/WEB-INF/railo/context/admin/
sudo mkdir /hydra/sites/$DOMAINNAME/ROOT/WEB-INF/railo/
sudo mkdir /hydra/sites/$DOMAINNAME/ROOT/WEB-INF/railo/extension/
sudo mkdir /hydra/sites/$DOMAINNAME/ROOT/WEB-INF/railo/extension/gateway/

sudo mkdir /hydra/sites/$DOMAINNAME/ROOT/WEB-INF/railo/gateway/
sudo mkdir /hydra/sites/$DOMAINNAME/ROOT/WEB-INF/railo/gateway/railo/
sudo mkdir /hydra/sites/$DOMAINNAME/ROOT/WEB-INF/railo/gateway/railo/extension/
sudo mkdir /hydra/sites/$DOMAINNAME/ROOT/WEB-INF/railo/gateway/railo/extension/gateway/

sudo mkdir /hydra/sites/$DOMAINNAME/ROOT/WEB-INF/railo/context/
sudo mkdir /hydra/sites/$DOMAINNAME/ROOT/WEB-INF/railo/context/admin/
sudo mkdir /hydra/sites/$DOMAINNAME/ROOT/WEB-INF/railo/context/admin/cdriver/
sudo mkdir /hydra/sites/$DOMAINNAME/ROOT/WEB-INF/railo/context/admin/gdriver/
sudo cp /hydra/repo/assets/railo/railo-server.xml /hydra/tomcat/railo/railo-server/context/railo-server.xml
sudo cp -r /hydra/repo/assets/railo/lib /hydra/tomcat/railo/railo-server/context/lib
sudo cp -r /hydra/repo/assets/railo/extensions /hydra/tomcat/railo/railo-server/context/extensions
sudo mkdir /hydra/tomcat/webapps/ROOT/WEB-INF/railo/context/admin/cdriver/
sudo cp /hydra/repo/assets/railo/MembaseCache.cfc /hydra/tomcat/webapps/ROOT/WEB-INF/railo/context/admin/cdriver/MembaseCache.cfc
sudo cp /hydra/repo/assets/railo/MembaseCache.cfc /hydra/sites/$DOMAINNAME/ROOT/WEB-INF/railo/context/admin/cdriver/MembaseCache.cfc
sudo cp /hydra/repo/assets/railo/railo-web.xml.cfm /hydra/sites/$DOMAINNAME/ROOT/WEB-INF/railo/railo-web.xml.cfm

sudo cp -r /hydra/repo/assets/gateway/gdriver/hydra.cfc /hydra/sites/$DOMAINNAME/ROOT/WEB-INF/railo/context/admin/gdriver/
sudo cp -r /hydra/repo/assets/gateway/hydraListener.cfc /hydra/sites/$DOMAINNAME/ROOT/WEB-INF/railo/extension/gateway/
sudo cp -r /hydra/repo/assets/gateway/hydra.cfc /hydra/sites/$DOMAINNAME/ROOT/WEB-INF/railo/extension/gateway/
sudo cp -r /hydra/repo/assets/gateway/Application.cfc /hydra/sites/$DOMAINNAME/ROOT/WEB-INF/railo/extension/gateway/
sudo cp -r /hydra/repo/assets/gateway/Application.cfm /hydra/sites/$DOMAINNAME/ROOT/WEB-INF/railo/extension/gateway/

sudo cp -r /hydra/repo/assets/gateway/hydraListener.cfc /hydra/sites/$DOMAINNAME/ROOT/WEB-INF/railo/gateway/railo/extension/gateway/
sudo cp -r /hydra/repo/assets/gateway/hydra.cfc /hydra/sites/$DOMAINNAME/ROOT/WEB-INF/railo/gateway/railo/extension/gateway/
sudo cp -r /hydra/repo/assets/gateway/Application.cfc /hydra/sites/$DOMAINNAME/ROOT/WEB-INF/railo/gateway/railo/extension/gateway/
sudo cp -r /hydra/repo/assets/gateway/Application.cfm /hydra/sites/$DOMAINNAME/ROOT/WEB-INF/railo/gateway/railo/extension/gateway/

sudo chown -R hydra /home/hydra

qry="CREATE DATABASE mail  DEFAULT CHARACTER SET utf8  DEFAULT COLLATE utf8_general_ci; CREATE DATABASE hydra  DEFAULT CHARACTER SET utf8  DEFAULT COLLATE utf8_general_ci; CREATE DATABASE contentbox  DEFAULT CHARACTER SET utf8  DEFAULT COLLATE utf8_general_ci; USE mysql; GRANT ALL PRIVILEGES ON *.* TO 'hydra'@'%' IDENTIFIED BY 'hydrastack' WITH GRANT OPTION; GRANT ALL PRIVILEGES ON *.* TO 'hydra'@'localhost' IDENTIFIED BY 'hydrastack' WITH GRANT OPTION; FLUSH PRIVILEGES;"

sudo /usr/bin/mysql -u root  << eof
$qry
eof

qry="USE contentbox; source /hydra/repo/assets/blog.sql;"

sudo /usr/bin/mysql -u root  << eof
$qry
eof

qry="USE hydra; source /hydra/repo/assets/hydra.sql;"

sudo /usr/bin/mysql -u root  << eof
$qry
eof

qry="USE mail; source /hydra/repo/assets/postfix/mail.sql;"

sudo /usr/bin/mysql -u root  << eof
$qry
eof

cd /hydra/install

sudo yum -y install gcc.x86_64 make

#sudo wget http://curl.haxx.se/download/curl-7.22.0.tar.gz
#sudo tar -xf curl-7.22.0.tar.gz
#cd curl-7.20.1
#./configure --prefix=/usr/local
#sudo make
#sudo make install

sudo yum -y install curl-devel.x86_64 fuse.x86_64 fuse-devel.x86_64 fuse-libs.x86_64 libxml2.x86_64 libxml2-devel.x86_64 libcurl-devel

cd /hydra

sudo git clone git://github.com/redbo/cloudfuse.git
cd cloudfuse
sudo ./configure
sudo make
sudo make install
which cloudfuse
sudo mkdir /hydra/cloudfiles
sudo touch /home/hydra/.cloudfuse
sudo chown -R hydra /home/hydra

sudo echo "username=rackspaceusername" >> /home/hydra/.cloudfuse
sudo echo "api_key=rackspaceapikey" >> /home/hydra/.cloudfuse

sudo yum -y install libidn

sudo yum -y install cyrus-sasl

sudo yum -y install openssl098e

#sudo wget http://files.couchbase.com/developer-previews/couchbase-server-2.0.0-dev-preview/linux/couchbase-server-community_x86_64_2.0.0r-1-ge4c8742.rpm -O /hydra/install/couchbase-server-community_x86_64_2.0.0r-1-ge4c8742.rpm
sudo wget http://beta.hydrastack.com/downloads/couchbase-server-community_x86_64_2.0.0r-1-ge4c8742.rpm -O /hydra/install/couchbase-server-community_x86_64_2.0.0r-1-ge4c8742.rpm

sudo rpm --install /hydra/install/couchbase-server-community_x86_64_2.0.0r-1-ge4c8742.rpm

bigcouch() {

sudo yum -y install zlib-devel rubygem-rake ruby-rdoc

#git clone git://github.com/cloudant/bigcouch.git
#cd bigcouch
#./configure -p /hydra/bigcouch
#make
#sudo make install

sudo cat <<'EOF' > /etc/yum.repos.d/cloudant.repo
[cloudant]
name=Cloudant Repo
baseurl=http://packages.cloudant.com/rpm/$releasever/$basearch
enabled=1
gpgcheck=0
priority=1
EOF

sudo yum -y install bigcouch

}

if [ $answers_0 == 1 ]; then
	bigcouch
fi

#CouchDB 1.1, not available on CentOS 5.6
sudo yum -y install libicu-devel openssl-devel erlang js-devel libtool which xulrunner-devel ncurses-devel libicu icu
cd /hydra/install
sudo wget http://beta.hydrastack.com/downloads/apache-couchdb-1.1.1.tar.gz -O /hydra/install/apache-couchdb-1.1.1.tar.gz
sudo tar -xf /hydra/install/apache-couchdb-1.1.1.tar.gz
cd /hydra/install/apache-couchdb-1.1.1
sudo adduser -r --home /hydra/couch/var/lib/couchdb -M --shell /bin/bash --comment "CouchDB Administrator" couchdb
sudo mkdir /hydra/couch
sudo ./configure --with-erlang=/usr/lib64/erlang/usr/include --prefix=/hydra/couch --enable-js-trunk
#sudo ./configure --prefix=/usr/local --enable-js-trunk
sudo make
sudo make install
sudo cp /hydra/repo/assets/default111.ini /hydra/couch/etc/couchdb/default.ini
sudo chown -R couchdb:couchdb /hydra/couch/var/lib/couchdb /hydra/couch/var/log/couchdb
sudo chown -R couchdb:couchdb /hydra/couch
sudo cp /hydra/repo/assets/movies.couch /hydra/couch/var/lib/couchdb/
sudo cp /hydra/repo/assets/couchdb.init /etc/init.d/couchdb
sudo chmod +x /etc/init.d/couchdb
sudo mkdir /hydra/couch/couchdb
sudo chown -R couchdb:couchdb /hydra/couch/

sudo mkdir /var/run/couchdb/
sudo chown couchdb:couchdb /var/run/couchdb/

sudo chown -R couchdb:couchdb /hydra/couch

sudo service couchdb start
#sudo -u couchdb /hydra/couch/bin/couchdb

sudo cat > /etc/yum.repos.d/jpackage-generic-free.repo << EOF
[jpackage-generic-free]
name=JPackage generic free
baseurl=http://mirrors.dotsrc.org/jpackage/6.0/generic/free/
enabled=1
gpgcheck=1
gpgkey=http://www.jpackage.org/jpackage.asc
EOF

sudo cat > /etc/yum.repos.d/jpackage-generic-devel.repo << EOF
[jpackage-generic-devel]
name=JPackage Generic Developer
baseurl=http://mirrors.dotsrc.org/jpackage/6.0/generic/devel/
enabled=1
gpgcheck=1
gpgkey=http://www.jpackage.org/jpackage.asc
EOF

#BigCouch (CouchDB 1.1)
#sudo wget http://curl.haxx.se/download/curl-7.22.0.tar.gz
#sudo tar -xf curl-7.22.0.tar.gz
#cd curl-7.22.0
#./configure --prefix=/usr/local
#sudo make
#sudo make install
#yum -y install ncurses-devel
#curl -O https://raw.github.com/spawngrid/kerl/master/kerl; chmod a+x kerl
#./kerl build R14B03 r14b03
#./kerl install r14b03 /opt/erlang/r14b03
#. /opt/erlang/r14b03/activate
#yum install js-devel libicu libicu-devel openssl openssl-devel python python-devel libtool which xulrunner-devel
#git clone git://github.com/cloudant/bigcouch.git
#cd bigcouch
#./configure -p /hydra/bigcouch
#make
#sudo make install

#starts on 5986
cd /hydra/install
#sudo wget --no-check-certificate https://github.com/downloads/cloudant/bigcouch/bigcouch-0.3.1-1.x86_64.rpm
#sudo wget --no-check-certificate http://beta.hydrastack.com/downloads/bigcouch-0.3.1-1.x86_64.rpm
#sudo rpm --install /hydra/install/bigcouch-0.3.1-1.x86_64.rpm
sudo hostname mail.$DOMAINNAME.com
#sudo mv /opt/bigcouch /hydra/bigcouch
sudo cp /hydra/repo/assets/default.ini /opt/bigcouch/etc/default.ini
#sudo /hydra/bigcouch/bin/bigcouch

sudo wget http://www.alliedquotes.com/mirrors/apache/maven/binaries/apache-maven-2.2.1-bin.tar.gz
sudo chmod 700 apache-maven-2.2.1-bin.tar.gz
sudo tar xzf apache-maven-2.2.1-bin.tar.gz
sudo mv /hydra/install/apache-maven-2.2.1 /hydra/install/maven

sudo echo "export M2_HOME=/hydra/install/maven" >> /root/.bashrc
sudo echo "export PATH=${M2_HOME}/bin:${PATH}" >> /root/.bashrc

M2_HOME=/hydra/install/maven
export M2_HOME=/hydra/install/maven

JAVA_HOME=/hydra/install/jdk1.7.0
JAVA_PATH=/hydra/install/jdk1.7.0

export JAVA_HOME=/hydra/install/jdk1.7.0
export JAVA_PATH=/hydra/install/jdk1.7.0

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin:/hydra/install/jdk1.7.0/bin:/hydra/install/maven/bin:/root/bin:/hydra/install/jdk1.7.0:/hydra/install/maven
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin:/hydra/install/jdk1.7.0/bin:/hydra/install/maven/bin:/root/bin:/hydra/install/jdk1.7.0:/hydra/install/maven

cd /hydra/install/
sudo git clone git://github.com/rnewson/couchdb-lucene.git
cd couchdb-lucene

JAVA_HOME=/hydra/install/jdk1.7.0
export JAVA_HOME=/hydra/install/jdk1.7.0

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin:/hydra/install/jdk1.7.0/bin:/hydra/install/maven/bin:/root/bin:/hydra/install/jdk1.7.0:/hydra/install/maven
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin:/hydra/install/jdk1.7.0/bin:/hydra/install/maven/bin:/root/bin:/hydra/install/jdk1.7.0:/hydra/install/maven

sudo JAVA_HOME=/hydra/install/jdk1.7.0 /hydra/install/maven/bin/mvn
cd target
sudo yum -y install unzip
sudo unzip /hydra/install/couchdb-lucene/target/couchdb-lucene-0.9.0-SNAPSHOT-dist.zip
sudo chown -R hydra /hydra
#sudo /hydra/install/couchdb-lucene/target/couchdb-lucene-0.9.0-SNAPSHOT/bin/run > /dev/null 2>&1 &

#compiled and ready
#cd /hydra/install
#sudo wget http://beta.hydrastack.com/downloads/couchdb-lucene-0.9.0-SNAPSHOT-dist.tar.gz
#sudo tar -xvf /hydra/install/couchdb-lucene-0.9.0-SNAPSHOT-dist.tar.gz

#riak
#sudo wget http://downloads.basho.com/riak/riak-1.0.0/riak-1.0.0-1.el5.x86_64.rpm
#sudo rpm -Uvh riak-1.0.0-1.el5.x86_64.rpm

#starts on 5985
#sudo yum -y install couchdb
#sudo cp /hydra/repo/assets/couch/default.ini /etc/couchdb/default.ini
#sudo cp /hydra/repo/assets/couch/local.ini /etc/couchdb/local.ini
#sudo service couchdb start

sudo cp /hydra/repo/assets/railo/railo-server.xml /hydra/tomcat/railo/railo-server/context/railo-server.xml
sudo cp -r /hydra/repo/assets/railo/lib /hydra/tomcat/railo/railo-server/context/
sudo cp -r /hydra/repo/assets/railo/extensions /hydra/tomcat/railo/railo-server/context/
sudo mkdir /hydra/tomcat/webapps/ROOT/WEB-INF/railo/context/admin/cdriver/
sudo cp /hydra/repo/assets/railo/MembaseCache.cfc /hydra/tomcat/webapps/ROOT/WEB-INF/railo/context/admin/cdriver/MembaseCache.cfc
sudo cp /hydra/repo/assets/railo/MembaseCache.cfc /hydra/sites/$DOMAINNAME/ROOT/WEB-INF/railo/context/admin/cdriver/MembaseCache.cfc
sudo cp /hydra/repo/assets/railo/railo-web.xml.cfm /hydra/sites/$DOMAINNAME/ROOT/WEB-INF/railo/railo-web.xml.cfm


sudo chown -R hydra /home/hydra
sudo chown -R hydra /hydra

sudo service tomcat restart

cd /hydra/install
sudo mkdir /hydra/proxy
#sudo wget http://dev.mysql.com/get/Downloads/MySQL-Proxy/mysql-proxy-0.8.2-linux-rhel5-x86-64bit.tar.gz/from/http://mirror.services.wisc.edu/mysql/
sudo wget http://beta.hydrastack.com/downloads/mysql-proxy-0.8.2-linux-rhel5-x86-64bit.tar.gz -O mysql-proxy-0.8.2-linux-rhel5-x86-64bit.tar.gz
sudo tar -xf mysql-proxy-0.8.2-linux-rhel5-x86-64bit.tar.gz
sudo mv /hydra/install/mysql-proxy-0.8.2-linux-rhel5-x86-64bit /hydra/proxy/mysql-proxy

sudo mkdir /hydra/config
sudo cp /hydra/repo/assets/config/mysql-proxy /hydra/config/mysql-proxy
sudo chmod +x -R /hydra/config
sudo chmod +x -R /hydra/proxy

sudo chown -R hydra /hydra

sudo cp /hydra/repo/assets/mysql-proxy /etc/init.d/mysql-proxy

sudo cp /hydra/repo/assets/failover.lua /hydra/proxy/failover.lua

#sudo /hydra/mysql-proxy/bin/mysql-proxy --defaults-file=/hydra/config/mysql-proxy.conf 	 

sudo chmod +x /etc/init.d/mysql-proxy

sudo service mysql-proxy start

sudo yum -y install bzip2 and bzip2-devel bzip2-libs

node() {

	cd /hydra
	sudo wget http://beta.hydrastack.com/downloads/Python-2.5.4.tgz

	sudo tar xzvf Python-2.5.4.tgz

	cd Python-2.5.4
	sudo ./configure
	sudo make
	sudo make install

	sudo ln -s /hydra/Python-2.5.4/python /usr/bin/python

	sudo touch /etc/ld.so.conf.d/python2.5.conf

	sudo chown -R hydra /etc/ld.so.conf.d/python2.5.conf

	sudo echo "'/usr/local/lib'" >> /etc/ld.so.conf.d/python2.5.conf

	sudo ldconfig

	PATH=$HOME/bin:$PATH
	export PATH=$HOME/bin:$PATH

	cd /hydra

	sudo wget http://beta.hydrastack.com/downloads/node-v0.6.6.tar.gz
	sudo tar xvf node-v0.6.6.tar.gz
	sudo mv node-v0.6.6 node
	cd node

	sudo yum -y install gcc-c++

	sudo CC=/usr/bin/gcc CXX=/usr/bin/g++ ./configure
	sudo make
	sudo make install

	sudo mkdir /hydra/node/www

	sudo cp /hydra/repo/assets/hydra.js /hydra/node/www/hydra.js

	sudo chown -R hydra /hydra

	sudo rm /usr/local/bin/python

	sudo ln -s /usr/bin/python2.6 /usr/local/bin/python

	sudo ln -s /usr/bin/python2.6 /usr/bin/python
	
}

if [ $answers_0 == 1 ]; then
	node
fi

PATH=/hydra/install/jdk1.7.0/bin:$PATH
export PATH=/hydra/install/jdk1.7.0/bin:$PATH

cd /hydra/
#sudo wget --no-check-certificate http://newverhost.com/pub//lucene/solr/3.4.0/apache-solr-3.4.0.tgz -O apache-solr-3.4.0.tgz
sudo wget --no-check-certificate http://beta.hydrastack.com/downloads/apache-solr-3.4.0.tgz -O apache-solr-3.4.0.tgz
sudo tar -xf apache-solr-3.4.0.tgz
cd /hydra/apache-solr-3.4.0/example
sudo mv /hydra/apache-solr-3.4.0.tgz /hydra/install/apache-solr-3.4.0.tgz
sudo cp /hydra/repo/assets/schema.xml /hydra/apache-solr-3.4.0/example/solr/conf/schema.xml
sudo chown -R hydra /hydra
#sudo java -Dsolr.solr.home=/hydra/apache-solr-3.4.0/example/solr/ -jar start.jar
#sudo java -Dsolr.solr.home=/hydra/apache-solr-3.4.0/example/solr/ -jar start.jar > /dev/null 2>&1 &

#sudo cp /hydra/repo/assets/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo
sudo yum -y install postfix dovecot dovecot-mysql procmail spamassassin

sudo groupadd -g 5000 vmail
sudo useradd -s /usr/sbin/nologin -g vmail -u 5000 vmail -d /home/vmail -m

sudo chmod +x /home/vmail
sudo chown -R vmail /home/vmail
sudo chmod +w /home/vmail

sudo cp /hydra/repo/assets/postfix/smtpd.conf /usr/lib64/sasl2/smtpd.conf

sudo cp -R /hydra/repo/assets/postfix/* /etc/postfix/

sudo cp -R /hydra/repo/assets/dovecot/* /etc/dovecot/

sudo cp -R /hydra/repo/assets/mail/spamassassin/* /etc/mail/spamassassin/

sudo cp -R /hydra/repo/assets/mail/aliases /etc/mail/aliases

sudo cp -R /hydra/repo/assets/mail/procmailrc /etc/procmailrc

sudo cp -R /hydra/repo/assets/mail/spamfilter /usr/local/bin/spamfilter

sudo cp -R /hydra/repo/assets/postfix/virtual /etc/postfix/

sudo chmod o= /etc/postfix/mysql-*
sudo chgrp postfix /etc/postfix/mysql-*

sudo groupadd spamd
sudo useradd -g spamd -s /bin/false -d /var/log/spamassassin spamd
sudo chown spamd:spamd /var/log/spamassassin

sudo useradd spamfilter

sudo postmap /etc/postfix/virtual

sudo yum -y install crypto-utils

sudo chmod +x /hydra/repo/assets/mail/mkcert.sh

sudo mkdir /hydra/certs
sudo mkdir /hydra/private

sudo chmod +x /hydra/repo/assets/mail/mkcert.sh

sudo /hydra/repo/assets/mail/mkcert.sh

sudo cp /hydra/private/dovecot.pem /etc/pki/tls/private/mail.$DOMAINNAME.com.key
sudo cp /hydra/certs/dovecot.pem /etc/pki/tls/certs/mail.$DOMAINNAME.com.cert

sudo chmod +x /usr/local/bin/spamfilter

sudo chown spamfilter /usr/local/bin/spamfilter

sudo service saslauthd start
sudo service spamassassin start
sudo service postfix start
sudo service dovecot start