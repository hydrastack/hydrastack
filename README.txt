To install HYDRA Stack, create a new CentOS 6 instance in your Rackspace Cloud account and perform the following command chain as root before you perform *any* other actions on the server:

wget https://raw.github.com/hydrastack/hydrastack/master/install.sh -O /install.sh; chmod +x /install.sh; /install.sh

This will configure the new server as your master HYDRA Stack server. Once your master server is live, you can use it to add new servers to the stack, manage configurations and perform other administrative tasks. You can promote a different server to master later, but all servers in the stack will have administrative abilities via the web control panel.

Do not interrupt the script during installation. Wait until installation completes before performing any other actions on the server.

Due to some temporary internal IP address references, only the Rackspace cloud is currently supported. Those addresses will soon be replaced with universal ones when Amazon cloud support is added.

Due to specific dependency requirements, only CentOS 6 and RHEL 6 are currently supported, although Fedora, Ubuntu and Mac support will be available very soon.

Once your master server has completed its initial setup, visit the Railo server administrator at:
http://{ipaddress}:8080/railo-context/admin/server.cfm

Hydra starts Apache by default, but nginx is also configured and ready to use. This can be easily switched at the command line or through the control panel.

The Hydra control panel is not currently finished, so new servers have to be set up manually by executing the install command chain above on each server.

This is a pre-pre-pre-alpha, so I've only pushed a few of the fully ready scripts. Some things, such as authorized_keys, have been hard-coded and will eventually be made dynamic when the final security measures are implemented.

A sample of the dashboard application is configured on your new server at http://www.YOURDOMAIN.com/

To access this application, create a host entry on your local machine for:

{ipaddress} www.YOURDOMAIN.com

So, if your new server is's IP is 123.123.123.123, your host entry will look like:

123.123.123.123 www.YOURDOMAIN.com

The dashboard is also available by accessing the default website of the new server, which will be located at http://{ipaddress}

You will also need to create and entry for:

123.123.123.123 blog.YOURDOMAIN.com

A blog driven by ContentBox (The ColdBox blogging and content management system) has also been pre-configured on on your stack.

Once you have configured your host file entry and visited http://www.YOURDOMAIN.com/ or http://{ipaddress} and see the login page, a sample CouchDB powered application will also be available at:
http://www.YOURDOMAIN.com/couch/index.cfm

A mobile application driven by jQuery Mobile and PhoneGap is also available at:
http://www.YOURDOMAIN.com/jqm/index.html

FTP is available through SFTP, which may be easier to use if you allow password logins in the SSHD.

The default credentials to log into the dashboard are:
email: admin@YOURDOMAIN.com
password: hydrastack

The stack will be locked down, with no password logins allowed, so you'll either need to enable password login in /etc/ssh/sshd_config after Hydra installs, or use the public key found in the /hydra/repo/hydra.sh file to login via ssh. You can also use the console via your Rackspace control panel if you happen to get locked out for any reason. I haven't set any of the applications to boot on startup except CouchBase, so you'll need to manually restart Apache and Tomcat if you reboot the server.

Anyway, this is all very rough and much is currently in development and testing is ongoing.

As of now, HYDRA will configure your CentOS server, modify iptables, create the proper users and permissions, install git, Java, Tomcat, Apache, nginx, Railo, ColdBox, Postfix (with Dovecot, TLS, spamassasin, virtual domains and users powered by MySQL, and spam moved to the spam folder), CouchDB with Lucene, CouchBase with the Railo extension pre-configured, Solr, BigCouch, Riak, MySQL, MySQL Proxy, node.js and the HYDRA sample application, which includes examples that connect to the stack via AJAX and a variety of other methods. Mobile application templates and other cool examples are also included, such as a CouchDB sample application. All software installed by Hydra is installed with a fully working configuration specific to your stack. The HYDRA Stack sample application uses Twitter Bootstrap, LESS and Backbone.js and includes Facebook integration for signup / login to the sample application (just change the credentials in the relevant files).

The Hydra Apache virtual host configuration allows for SSL virtual hosts on port 443, each with its own certificates, which will be generated automatically (self-signed) by HYDRA very soon, but can be replaced with your trusted CA signed certificate at anytime. These SSL virtual hosts can easily sit behind a high availability load balancer at Rackspace, and you can run nginx on port 80 for non-SSL requests and Apache on 443 for SSL requests if you'd like to further split the traffic behind the load balancers.

Once the Hydra control panel is fully-accessible, you'll be able to login to your stack from any of its servers and manage the stack, create a clustered file system, configure load balancing, set up DRBD database failovers with redundant replication, add new software to your servers and scale your stack to your specific needs, all with zero configuration on your part. Rackspace Cloud Files is also configured and ready to be mounted as a directory, just replace the credentials in /home/hydra/.cloudfuse and mount the drive using the pre-configured cloudfuse with: sudo /hydra/cloudfuse/cloudfuse /hydra/cloudfiles -o allow_other,nonempty

I'll do my best to fix problems and answer questions, but many changes are on the way, so expect big updates soon. Next on the list will be automating the DRBD and OCFS2 modules that I've already included as scripts if you want to try and manually configure them yourself (and if successful, perhaps contribute back a block of code I can plug just into setup.sh to automate this?), but right now they are not set up during the initial installation of a master instance. That will be next, unless someone beats me to it and can submit a pull request.

The Hydra control panel is called Vine. Vine allows you to easily manage your entire stack from any of the participating servers. I will publish it soon.

If you don't have a Rackspace account and want to try out HYDRA Stack, just contact me and I will create a completely clean server for you and give you the credentials so that you can do the initial login and set up a stack yourself to try it out for a little while.

Thank you to every single person who has worked on or used any of the projects that I have included (and depended on completely) here in *any* capacity. Also, thank you to the internet and the web, to users, open source, sharing, computers, community, social networks, friends and family, hackers, creators, automators, and anyone who loves technology. In the end, it's all about getting down to what's important; building stuff with people you like and still having time for everything else. Hopefully HYDRA Stack can help you do that, and maybe save you some headaches along the way. (I'll try to save you even more headaches when I add documentation and comments.)

Special thanks to Rackspace, Railo, Team ColdBox, Linux and GNU, the entire CFML community, and everyone involved in CouchDB or any other kind of open source project or initiative.

- Jim