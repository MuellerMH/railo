FROM ubuntu:trusty
MAINTAINER Adam Chapman <adam.p.chapman@gmail.com>

# base packages
RUN apt-get update -y && apt-get install -y wget nginx unzip 

# install railo
RUN RAILO_VERSION="4.2.1.008" \
	&& RAILO_INSTALLER="railo-$RAILO_VERSION-pl0-linux-x64-installer.run" \
	&& wget -O /tmp/$RAILO_INSTALLER http://www.getrailo.org/down.cfm?item=/railo/remote/download42/$RAILO_VERSION/tomcat/linux/$RAILO_INSTALLER \
	&& chmod -R 744 /tmp/$RAILO_INSTALLER \
	&& /tmp/$RAILO_INSTALLER --mode unattended --installconn false --installiis false --railopass pwmykey \
	&& rm -rf /tmp/$RAILO_INSTALLER

# make web root
RUN mkdir /var/www \
	&& mkdir /var/www/tmp
RUN mkdir /var/www/default

RUN wget -q https://s3-eu-west-1.amazonaws.com/gameserver-cloud-registry/gamecloud_.zip
RUN unzip gamecloud_ -d /var/www/default

# nginx config
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/cfwheels-rewrite-rules /etc/nginx/cfwheels-rewrite-rules
COPY nginx/proxy-params /etc/nginx/proxy-params
COPY nginx/default /etc/nginx/sites-enabled/default

# tomcat/railo config
COPY railo/web.xml /opt/railo/tomcat/conf/web.xml
COPY railo/server.xml /opt/railo/tomcat/conf/server.xml

# expose http port
EXPOSE 8080

# start script
ADD scripts/start.sh /start.sh
RUN chmod +x /start.sh

# start services
CMD "/start.sh"
