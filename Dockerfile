# Openhab 2.0.0
# * configuration is injected
#
FROM ubuntu:14.04
MAINTAINER Marcus of Wetware Labs <marcus@wetwa.re>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -y update
RUN apt-get -y upgrade
RUN apt-get -y install unzip supervisor wget

RUN echo "Download and install Oracle JDK"
# For direct download see: http://stackoverflow.com/questions/10268583/how-to-automate-download-and-installation-of-java-jdk-on-linux
RUN wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" -O /tmp/jre-8u45-linux-x64.tar.gz http://download.oracle.com/otn-pub/java/jdk/8u45-b14/jre-8u45-linux-x64.tar.gz
RUN tar -zxC /opt -f /tmp/jre-8u45-linux-x64.tar.gz
RUN ln -s /opt/jre1.8.0_45 /opt/jre8

ENV OPENHAB_VERSION SNAPSHOT 
#ENV OPENHAB_VERSION 2.0.0.alpha2

#
# Download openHAB based on Environment OPENHAB_VERSION
#
ADD files/scripts/download_openhab.sh /root/docker-files/scripts/
RUN chmod +x /root/docker-files/scripts/download_openhab.sh  && \
   /root/docker-files/scripts/download_openhab.sh

#
# Download HABMIN
#
RUN echo "Download HABMin2"
RUN wget -P /opt/openhab/addons-available/addons/ https://github.com/cdjackson/HABmin2/releases/download/0.0.15/org.openhab.ui.habmin_2.0.0.SNAPSHOT-0.0.15.jar 

#
# Download Openhab 1.x dependencies
#
RUN echo "Download OpenHAB 1.x dependencies"
RUN wget -P /tmp/ https://openhab.ci.cloudbees.com/job/openHAB/lastStableBuild/artifact/distribution/target/distribution-1.8.0-SNAPSHOT-addons.zip
#RUN wget -P /tmp/ https://openhab.ci.cloudbees.com/job/openHAB/lastStableBuild/artifact/distribution/target/distribution-1.8.0-SNAPSHOT-runtime.zip
RUN unzip -q /tmp/distribution-1.8.0-SNAPSHOT-addons.zip -d /opt/openhab/addons-available-oh1
#RUN unzip -j /tmp/distribution-1.8.0-SNAPSHOT-runtime.zip server/plugins/org.openhab.io.transport.mqtt* -d /opt/openhab/addons-available-oh1/
#RUN unzip -j /tmp/distribution-1.8.0-SNAPSHOT-runtime.zip configurations/openhab_default.cfg -d /opt/openhab/
RUN wget -P /opt/openhab/ https://raw.githubusercontent.com/openhab/openhab/master/distribution/openhabhome/configurations/openhab_default.cfg
# for some reason there's now extra io.transport.mqtt in OH2 (from OH1) that interferes with MQTT if it is left there. But it works if used from addons-directory...
RUN mv /opt/openhab/runtime/server/plugins/org.openhab.io.transport.mqtt* /opt/openhab/addons-available-oh1/

#
# Setup other configuration files and scripts
#
ADD files /root/docker-files/
RUN \
  cp /root/docker-files/pipework /usr/local/bin/pipework && \
  cp /root/docker-files/supervisord.conf /etc/supervisor/supervisord.conf && \
  cp /root/docker-files/openhab.conf /etc/supervisor/conf.d/openhab.conf && \
  cp /root/docker-files/openhab_debug.conf /etc/supervisor/conf.d/openhab_debug.conf && \
  cp /root/docker-files/boot.sh /usr/local/bin/boot.sh && \
  cp /root/docker-files/openhab-restart /etc/network/if-up.d/openhab-restart && \
  touch /opt/openhab/conf/DEMO_MODE && \
  mkdir -p /opt/openhab/logs && \
  chmod +x /usr/local/bin/pipework && \
  chmod +x /usr/local/bin/boot.sh && \
  chmod +x /etc/network/if-up.d/openhab-restart && \
  chmod +x /root/docker-files/start.sh  && \
  chmod +x /root/docker-files/start_debug.sh  && \
  cp /root/docker-files/start.sh /opt/openhab/ && \
  cp /root/docker-files/start_debug.sh /opt/openhab/ && \
  rm -rf /tmp/*

EXPOSE 8080 8443 5555 9001

ENV PATH /opt/jre8/bin:$PATH

CMD ["/usr/local/bin/boot.sh"]
