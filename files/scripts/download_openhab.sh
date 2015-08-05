#!/bin/bash


if [[ $OPENHAB_VERSION == "SNAPSHOT" ]]
then
echo "Downloading runtime..."
  wget --quiet --no-cookies -O /tmp/distribution-runtime.zip https://openhab.ci.cloudbees.com/job/openHAB2/lastSuccessfulBuild/artifact/distribution/target/distribution-2.0.0-SNAPSHOT-runtime.zip 
echo "Downloading addons..."
  wget --quiet --no-cookies -O /tmp/distribution-addons.zip https://openhab.ci.cloudbees.com/job/openHAB2/lastSuccessfulBuild/artifact/distribution/target/distribution-2.0.0-SNAPSHOT-addons.zip
echo "Downloading demo..."
  wget --quiet --no-cookies -O /tmp/demo-openhab.zip https://openhab.ci.cloudbees.com/job/openHAB2/lastSuccessfulBuild/artifact/distribution/target/distribution-2.0.0-SNAPSHOT-demo.zip 
else
echo "Downloading runtime..."
  wget --quiet --no-cookies -O /tmp/distribution-runtime.zip https://bintray.com/artifact/download/openhab/bin/openhab-$OPENHAB_VERSION-runtime.zip 
echo "Downloading addons..."
  wget --quiet --no-cookies -O /tmp/distribution-addons.zip https://bintray.com/artifact/download/openhab/bin/openhab-$OPENHAB_VERSION-addons.zip 
echo "Downloading demo..."
  wget --quiet --no-cookies -O /tmp/demo-openhab.zip https://bintray.com/artifact/download/openhab/bin/openhab-$OPENHAB_VERSION-demo.zip 
fi

#wget --quiet --no-cookies -O /tmp/org.openhab.io.myopenhab-1.7.0.jar https://bintray.com/artifact/download/openhab/mvn/org/openhab/io/org.openhab.io.myopenhab/1.7.0/org.openhab.io.myopenhab-1.7.0.jar
wget --quiet --no-cookies -O /tmp/hyperic-sigar-1.6.4.tar.gz http://downloads.sourceforge.net/project/sigar/sigar/1.6/hyperic-sigar-1.6.4.tar.gz

mkdir -p /opt/openhab/addons-available
mkdir -p /opt/openhab/addons
mkdir -p /opt/openhab/demo-configuration
mkdir -p /opt/openhab/logs
mkdir -p /opt/openhab/lib
tar -zxf /tmp/hyperic-sigar-1.6.4.tar.gz --wildcards --strip-components=2 -C /opt/openhab hyperic-sigar-1.6.4/sigar-bin/lib/*
echo "Extracting runtime..."
unzip -q -d /opt/openhab /tmp/distribution-runtime.zip
echo "Extracting add-ons..."
unzip -q -d /opt/openhab/addons-available /tmp/distribution-addons.zip
echo "Extracting demo..."
unzip -q -d /opt/openhab/demo-configuration /tmp/demo-openhab.zip
chmod +x /opt/openhab/start.sh
#mv /tmp/org.openhab.io.myopenhab-1.7.0.jar /opt/openhab/addons-available
mv /opt/openhab/conf /etc/openhab
ln -s /etc/openhab /opt/openhab/conf

rm -f /tmp/distribution-* /tmp/demo-openhab.zip /tmp/hyperic-sigar-*
