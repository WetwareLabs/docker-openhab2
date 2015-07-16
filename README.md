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

Running
=======

* The image exposes openHAB ports 8080, 8443, 5555 and 9001 (supervisord).
* It expects you to map a configurations directory from the host to /etc/openhab. This allows you to inject your openhab configuration into the container (see example below).
* NOTE! Starting from 2.0.0 there is no general configuration file (as openhab.cfg in previous versions), but each add-on/plugin is configured separately on its services/<plugin-name>.txt file. You can manually create them, or define "EXAMPLE_CONF=1" when starting the container (see running example below). Example conf files from ALL the plugins will be then copied to services-directory. (No file will be over-written though, so you can edit them safely.)
* To use your own configuration and enable specific plugins, add a file with name addons.cfg in the configuration directory which lists all addons you want to add.

Example content for addons.cfg:
```
org.openhab.action.mail
org.openhab.action.squeezebox
org.openhab.action.xmpp
org.openhab.binding.exec
org.openhab.binding.http
org.openhab.binding.knx
org.openhab.binding.mqtt
org.openhab.binding.networkhealth
org.openhab.binding.serial
org.openhab.binding.squeezebox
org.openhab.io.squeezeserver
org.openhab.persistence.cosm
org.openhab.persistence.db4o
org.openhab.persistence.gcal
org.openhab.persistence.rrd4j
```

* The openHAB process is managed using supervisord.  You can manage the process (and view logs) by exposing port 9001. From there it is possible to switch between NORMAL and DEBUG versions of OpenHAB runtime.
* The container supports starting without network (--net="none"), and adding network interfaces using pipework.
* You can add a timezone file in the configurations directory, which will be placed in /etc/timezone. Default: UTC

Example content for timezone:
```
Europe/Brussels
```

Example: run command (with your openHAB config)
```
docker run -d -p 8080:8080 -v /tmp/configuration:/etc/openhab/ wetware/openhab
```

Example: run command (with your openHAB config) and use hosts network if to enable UPnP auto-detect feature (see above)
```
docker run -d -p 8080:8080 --net=host -v /tmp/configuration:/etc/openhab/ wetware/openhab

```
Example: run command (with your openHAB config) and populate the service directory with example plugin configuration files 
```
docker run -d -p 8080:8080 -v /tmp/configuration:/etc/openhab/ -e "EXAMPLE_CONF=1" wetware/openhab
```


Example: Map configuration and logging directory as well as allow access to Supervisor:
```
docker run -d -p 8080:8080 -p 9001:9001 -v /tmp/configurations/:/etc/openhab -v /tmp/logs:/opt/openhab/logs wetware/openhab
```

Example: run command (with Demo)
```
docker run -d -p 8080:8080 tdeckers/openhab
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


Contributors
============
* maddingo
* scottt732
* TimWeyand
* dprus
* tdeckers
* wetware

