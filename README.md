Overview
========

Docker image for Openhab (2.0.0). 

The image is constructed from daily snapshots of Openhab 2 builds, but can be changed to the last "stable" build (currently 2.0.0-alpha2) by editing Dockerfile, changing OPENHAB_VERSION and then rebuilding the image.

Included is JRE 1.8.45 instead of JDK 1.7.79 (in original tdeckers/openhab)


Official DEMO Included
========

If you do not have a openHAB configuration yet, you can start this Docker without one. The official openHAB DEMO will be started. 

PULL
=======
```docker pull wetware/openhab2```

Building
========

```docker build -t <username>/openhab2 .```

Auto-detect of devices with UPnP
==========
Openhab 2.0's new Paper UI includes feature to recognize devices on the same network using UPnP protocol. This in done by sending discovery UDP messages to 239.255.255.250:1900. Other UPnP devices (such as Philips Hue hub) will response message to this same address. Sending the UDP multicast message is done correctly from the container, but receiving them however requires support from Docker to enable
 MULTICASTING on container network interface, which is not yet implemented (7/2015). You can follow the discussion [here at the GitHub issue page][1] There are 2 work-arounds available: 

* Run container with --net=host option. This will use the network interface of the host instead of creating a separate one for the container. In practice it will map 1:1 all ports on the container to the host and enable the container to receive multicast UDP messages.
* Run container with --net=none option. This defers creating the network interface during the startup. Then on the host use [__pipework__][2] to create the network interface on the container side with IFF_MULTICAST set:
```
pipework docker0 -i eth0 CONTAINER_ID IP_ADDRESS/IP_MASK@DEFAULT_ROUTE_IP
```

[1]: https://github.com/docker/docker/issues/3043
[2]: https://github.com/jpetazzo/pipework

Configuring
=======

This container expects you to map a configurations directory from the host to /etc/openhab. This allows you to inject your openhab configuration into the container (see example below).

OpenHAB 2.0 plugins
--------

Starting from 2.0.0 there is no general configuration file (as openhab.cfg in previous versions), but each add-on/plugin is configured separately on its services/<plugin-name>.txt file. You can manually create them, or define "EXAMPLE_CONF=1" when starting the container (see running example below). Example conf files from ALL the (OpenHAB 2.0) plugins will be then copied to services-directory. (No file will be over-written though, so you can edit them safely.)

To use your own configuration and enable specific plugins, add a file with name __addons.cfg__ in the configuration directory which lists all addons you want to add.

Example content for addons.cfg:
```
org.eclipse.smarthome.binding.hue
org.eclipse.smarthome.binding.yahooweather
org.openhab.action.mail
org.openhab.action.xmpp
org.openhab.binding.squeezebox
org.openhab.binding.exec
org.openhab.binding.http
org.openhab.binding.knx
org.openhab.persistence.rrd4j
org.openhab.persistence.logging
```

OpenHAB 1.x plugins
----------
Since not all 1.x plugins have yet been ported to 2.0 platform, you can enable them by adding a file __addons-oh1.cfg__ to the configuration directory which lists all addons you want to add.
For example, to add __MQTT__ support using OpenHAB 1.x plugins:
```
org.openhab.binding.mqtt
org.openhab.io.transport.mqtt
```
Configuring 1.x plugins is done by editing __\[conf-directory\]/services/openhab.cfg__, which uses old 1.x syntax. If openhab.cfg is not found, a default configuration is copied to services-directory when conteiner is started. Note that all other entries in the file are ignored by default, except by those plugins that are explicitly defined in addons-oh1.cfg.


Timezone
---------
You can add a timezone file in the configurations directory, which will be placed in /etc/timezone. Default: UTC

Example content for timezone:
```
Europe/Brussels
```

Running
=======

* The image exposes openHAB ports 8080, 8443, 5555 and 9001 (supervisord).

* The openHAB process is managed using supervisord.  You can manage the process (and view logs) by exposing port 9001. From there it is possible to switch between NORMAL and DEBUG versions of OpenHAB runtime.
* The container supports starting without network (--net="none"), and adding network interfaces using pipework.

Example: run command (with your openHAB config)
```
docker run -d -p 8080:8080 -v /tmp/configuration:/etc/openhab/ wetware/openhab2
```

Example: run command (with your openHAB config) and use hosts network if to enable UPnP auto-detect feature (see above)
```
docker run -d -p 8080:8080 --net=host -v /tmp/configuration:/etc/openhab/ wetware/openhab2

```
Example: run command (with your openHAB config) and populate the service directory with example plugin configuration files 
```
docker run -d -p 8080:8080 -v /tmp/configuration:/etc/openhab/ -e "EXAMPLE_CONF=1" wetware/openhab2
```

Example: Map configuration and logging directory as well as allow access to Supervisor:
```
docker run -d -p 8080:8080 -p 9001:9001 -v /tmp/configurations/:/etc/openhab -v /tmp/logs:/opt/openhab/userdata/logs wetware/openhab2
```

Example: run command (with Demo)
```
docker run -d -p 8080:8080 wetware/openhab2
```

Start the Demo with: 
```
http://[IP-of-Docker-Host]:8080/openhab.app?sitemap=demo
```
Access Supervisor with: 
```
http://[IP-of-Docker-Host]:9001
```



HABmin
=======

HABmin is not automatically included in this deployment.  However you can easily enable it by adding following plugins to addons.cfg:
```
org.openhab.binding.zwave
org.openhab.ui.habmin

```

After starting container, you can then access HABmin on the address:
```
http://[IP-of-Docker-Host]:8080/habmin/index.html
```

Logging
=======
In OpenHAB 1.x logging was configured by modifying __logback.xml__ and __logback_debug.xml__ files in *configuration*-directory and log files were saved to /opt/openhab/logs. In OpenHAB 2.0 this has changed in following ways:

 * Logging directory is now __/opt/openhab/userdata/logs__ (easily mapped to host directory as Docker volume)
 * logback conf files are now situated in /opt/openhab/runtime/etc/, BUT since modifying these directly in the container causes headache (also mapping as volume would overwite other files there), these two files are __mapped again to configuration directory__. If user specified logback files are not found there, default files will be copied and are easily modified afterwards. 


Contributors
============
* maddingo
* scottt732
* TimWeyand
* dprus
* tdeckers
* wetware

