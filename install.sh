#!/bin/bash

PATH=/hydra/:$PATH
export PATH

software[0]="node.js";
software[1]="bigcouch"

answers[0]=1
answers[1]=1

for i in ${!answers[*]};do export answers_$i="${answers[$i]}";done

total=${#answers[@]}

ESC_SEQ="\x1b["
COL_FINAL=$ESC_SEQ"0m"
COL_RESET=$ESC_SEQ"39;49;00m"
COL_RED=$ESC_SEQ"00;31m"
COL_GREEN=$ESC_SEQ"00;32m"
COL_YELLOW=$ESC_SEQ"33;01m"

run() {
echo "" >> /etc/hosts
echo "127.0.0.1 local.$DOMAINNAME" >> /etc/hosts
echo "127.0.0.1 www.$DOMAINNAME" >> /etc/hosts
echo "127.0.0.1 blog.$DOMAINNAME" >> /etc/hosts
#sudo echo "" >> /etc/hosts
echo "10.179.71.24 beta.hydrastack.com" >> /etc/hosts
#sudo echo "" >> /etc/hosts

chmod +x /install.sh
mkdir /hydra
mv /install.sh /hydra/install.sh
cd /hydra

groupadd hydra
useradd -g hydra hydra

sudo groupadd -g 5000 vmail
sudo useradd -s /usr/sbin/nologin -g vmail -u 5000 vmail -d /home/vmail -m

groupadd spamd
useradd -g spamd -s /bin/false -d /var/log/spamassassin spamd

iptables -I INPUT -p tcp -m tcp --dport 80 -j ACCEPT
iptables -I INPUT -p tcp -m tcp --dport 8080 -j ACCEPT
iptables -I INPUT -p tcp -m tcp --dport 8009 -j ACCEPT
iptables -I INPUT -p tcp -m tcp --dport 3306 -j ACCEPT
iptables -I INPUT -p tcp -m tcp --dport 4040 -j ACCEPT
iptables -I INPUT -p tcp -m tcp --dport 8091 -j ACCEPT
iptables -I INPUT -p tcp -m tcp --dport 8983 -j ACCEPT
iptables -I INPUT -p tcp -m tcp --dport 5983 -j ACCEPT
iptables -I INPUT -p tcp -m tcp --dport 5984 -j ACCEPT
iptables -I INPUT -p tcp -m tcp --dport 5985 -j ACCEPT
iptables -I INPUT -p tcp -m tcp --dport 5986 -j ACCEPT
iptables -I INPUT -p tcp -m tcp --dport 11211 -j ACCEPT
iptables -I INPUT -p tcp -m tcp --dport 11210 -j ACCEPT
iptables -I INPUT -p tcp -m tcp --dport 4369 -j ACCEPT
iptables -I INPUT -p tcp -m tcp --dport 7789 -j ACCEPT
iptables -I INPUT -p tcp -m tcp --dport 7777 -j ACCEPT
iptables -I INPUT -p tcp -m tcp --dport 1337 -j ACCEPT

iptables -I INPUT -p tcp -m tcp --dport 25 -j ACCEPT
iptables -I INPUT -p tcp -m tcp --dport 587 -j ACCEPT
iptables -I INPUT -p tcp -m tcp --dport 465 -j ACCEPT
iptables -I INPUT -p tcp -m tcp --dport 110 -j ACCEPT
iptables -I INPUT -p tcp -m tcp --dport 995 -j ACCEPT
iptables -I INPUT -p tcp -m tcp --dport 993 -j ACCEPT
iptables -I INPUT -p tcp -m tcp --dport 143 -j ACCEPT

iptables -I INPUT -p tcp -m tcp --dport 21100:21199 -j ACCEPT

service iptables save
service iptables restart

echo "hydra    ALL=(ALL)       ALL" >> /etc/sudoers
echo "%hydra    ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers

mkdir /home/hydra/.ssh

echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEArdZRM0IJr1QEwFrlVoJt0v6ggYjOJkL7GLW21hNJ09r6LyA6tBq4L6ngGv+V+bExk609eohMIhqUMWc2pEsbdR3BAgPYeZFU9dtTSPTuWhAgS8+2GrWHvdIurWcQ2jusYcv2TWI9jApDN3pJ27Yhl9nefo4yQ4YvWShdLx5fWWIK5yrKeLXpwh2/QA96sD/v6uIHGrUDaU5bk3yAtKsGu/7B9IGlHvqP5yLrR0HE0T3K4zedQf+fHiPv6Iq7Zz0BG7jL7kSsHB4U0vj5gZIxwexsxjvrqhTkHlbRBhvonJcCZDtEWGNo+EanFu6yHXrNr1QmlpIGRLG9sMc76zW3Xw== root@hydra" >> /home/hydra/.ssh/authorized_keys

mkdir /root/.ssh

cp /home/hydra/.ssh/authorized_keys /root/.ssh/authorized_keys

chmod 700 /home/hydra/.ssh
chmod 600 /home/hydra/.ssh/authorized_keys

chmod 700 /root/.ssh
chmod 600 /root/.ssh/authorized_keys

chown -R hydra /home/hydra

sudo chmod 700 /home/hydra/.ssh
sudo chmod 700 /root/.ssh

sudo chown -R hydra /hydra

cd /home/hydra/.ssh
sudo ssh-keygen -N '' -f ./id_rsa -t rsa -q

sudo cp /home/hydra/.ssh/id_rsa /root/.ssh/id_rsa
sudo cp /home/hydra/.ssh/id_rsa.pub /root/.ssh/id_rsa.pub

sudo cat id_rsa.pub >> /home/hydra/.ssh/authorized_keys
sudo cat id_rsa.pub >> /root/.ssh/authorized_keys

sudo chmod 600 /home/hydra/.ssh/id_rsa
sudo chmod 600 /home/hydra/.ssh/id_rsa.pub

sudo chmod 600 /root/.ssh/id_rsa.pub
sudo chmod 600 /root/.ssh/id_rsa

sudo mkdir /hydra/cluster
sudo mkdir /hydra/cluster/keys
cd /hydra/cluster/keys
sudo ssh-keygen -N '' -f ./id_rsa -t rsa -q
sudo cat /hydra/cluster/keys/id_rsa.pub >> /home/hydra/.ssh/authorized_keys
sudo cat /hydra/cluster/keys/id_rsa.pub >> /root/.ssh/authorized_keys

cd /hydra

wget https://raw.github.com/hydrastack/hydrastack/master/setup.sh -O /hydra/setup.sh

chmod +x /hydra/setup.sh

mkdir /hydra/install

mkdir /hydra/cloudfiles

touch /hydra/install/answers.txt
echo "yes" > /hydra/install/answers.txt

JAVA_HOME=/hydra/install/jdk1.7.0
JAVA_PATH=/hydra/install/jdk1.7.0
export JAVA_HOME=/hydra/install/jdk1.7.0
export JAVA_PATH=/hydra/install/jdk1.7.0
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin:/hydra/install/jdk1.7.0/bin:/hydra/install/maven/bin:/root/bin:/hydra/install/jdk1.7.0:/hydra/install/maven
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin:/hydra/install/jdk1.7.0/bin:/hydra/install/maven/bin:/root/bin:/hydra/install/jdk1.7.0:/hydra/install/maven

#sudo echo "export M2_HOME=/hydra/maven" >> /root/.bashrc
#sudo echo "export PATH=${M2_HOME}/bin:${PATH}" >> /root/.bashrc

echo "export JAVA_HOME=/hydra/install/jdk1.7.0/" >> /etc/profile
echo "export JAVA_PATH=/hydra/install/jdk1.7.0/" >> /etc/profile
echo "export PATH=$PATH:$JAVA_HOME/bin" >> /etc/profile

#echo "export JAVA_HOME=/hydra/install/jdk1.7.0/" >> /etc/bashrc
#echo "export JAVA_PATH=/hydra/install/jdk1.7.0/" >> /etc/bashrc
#echo "export PATH=$PATH:$JAVA_HOME/bin" >> /etc/bashrc

#echo "export JAVA_HOME=/hydra/install/jdk1.7.0/" >> /root/.bash_profile
#echo "export JAVA_PATH=/hydra/install/jdk1.7.0/" >> /root/.bash_profile
#echo "export PATH=$PATH:$JAVA_HOME/bin" >> /root/.bash_profile

chmod +x /hydra/setup.sh
chmod +x /hydra/*

chown -R hydra /hydra

sed -i 's/Defaults    requiretty/#Defaults    requiretty/g' /etc/rc.d/rc.local

cat <<'EOF' > /etc/yum.repos.d/cloudant.repo
[cloudant]
name=Cloudant Repo
baseurl=http://packages.cloudant.com/rpm/$releasever/$basearch
enabled=1
gpgcheck=0
priority=1
EOF

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin:/hydra/install/jdk1.7.0/bin:/hydra/install/maven/bin:/root/bin:/hydra/install/jdk1.7.0:/hydra/install/maven
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin:/hydra/install/jdk1.7.0/bin:/hydra/install/maven/bin:/root/bin:/hydra/install/jdk1.7.0:/hydra/install/maven

su hydra /hydra/setup.sh

echo "" >> /etc/rc.d/rc.local
sed -i 's/HOSTNAME=/#OLDHOSTNAME=/g' /etc/sysconfig/network
echo "HOSTNAME=mail.$DOMAINNAME.com" >> /etc/sysconfig/network
#echo "sudo /hydra/bigcouch/bin/bigcouch >> /hydra/bigcouch.log" >> /etc/rc.d/rc.local

exit 0
}

packagesCall()
{
        packages
}

finish() {
echo "Installing HYDRA Stack..."
run
}

packages()
{
echo ""
echo "The following additional packages will be installed:"
for (( i=0; i<=$(( $total-1 )); i++ ))
do
        answer=${answers[$i]}

        color=$COL_GREEN
        if [ ${answers[$i]} -eq 0 ]
        then
                color=$COL_RED
        fi
echo -e "$color $i $COL_FINAL ${software[$i]}"
done
echo ""
echo "Enter the number of any software package you wish to enable/disable and press enter. When you are finished toggling software packages, press enter to continue:"
read item

        if [ -z "$item" ]; then
                finish
        elif [ $item -eq $item 2> /dev/null ]; then
                if [ ${answers[$item]} -eq 0 ]; then
                        answers[$item]=1
						for i in ${!answers[*]};do export answers_$i="${answers[$i]}";done
                else
                        answers[$item]=0
						for i in ${!answers[*]};do export answers_$i="${answers[$i]}";done
                fi
                clear
                packagesCall
        else
                echo "You must enter a valid number"
fi
}

setup() {
        finish
}

options() {
        echo -e "Select an option:"
        echo -e "Press $COL_GREEN enter $COL_FINAL to install with defaults"
        echo -e "Press $COL_GREEN c $COL_FINAL to customize installation"

        read -n 1 -s install

                if [ -z "$install" ]; then
                        clear
                        setup
                elif [ $install == 'c' ]; then
                        clear
                        packages
                else
                        echo "You must select a valid option"
        fi
}

main() {
        echo -e "Press $COL_GREEN enter $COL_FINAL to install using example.com as your domain name"
        echo -e "OR"
        echo -e "Type $COL_GREEN yourdomain.com $COL_FINAL to customize installation"

        read -e option

                if [ -z "$option" ]; then
                        DOMAINNAME=example.com
                else
                        DOMAINNAME=$option
        fi

        export DOMAINNAME

        echo -e "Are you sure you want to install using $DOMAINNAME? (y or n)"

        read -n 1 -s confirm

                if [ "$confirm" == "y" ]; then
                        packages
                else
                        clear
                        main
        fi

}

main