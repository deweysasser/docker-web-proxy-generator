NGINX Proxy Generator
=====================

A container that 
* subscribes to docker events
* writes out NGINX config files to proxy traffic to containers
* notifies NGINX to update itself

Includes configuration templates for standard and SSL proxies.


Quick Start 
===========

Manual container cration
------------------------

Create some back end servers with appropriate labels:

```
docker run -d --name web1 --label proxy.host=www.example.com my-web-server
docker run -d --name web2 --label proxy.host=www.example.com my-web-server
```

Now create an NGINX proxy server that will be configured to proxy
traffic to these systems.

```
docker run -d --name proxy --label proxy.notify -v /etc/nginx/conf.d -v /usr/share/nginx/html nginx
```

and last start the generator

```
docker run -d --name proxy-generator -v /var/run/docker.sock:/var/run/docker.sock --volumes-from proxy deweysasser/web-proxy-generator
```

docker-compose
--------------

Alternatively, you can use an orchestration tool.  Here is an exmaple
docker-compose.yml file to demonstrate capability

```
web1:
  image: nginx
  command: bash -c 'echo $$(hostname) > /usr/share/nginx/html/index.html; nginx -g "daemon off;"'
  labels:
    - proxy.host=www.example.com

web2:
  image: nginx
  command: bash -c 'echo $$(hostname) > /usr/share/nginx/html/index.html; nginx -g "daemon off;"'
  labels:
    - proxy.host=www.example.com


proxy:
  image: nginx
  volumes:
    - /etc/nginx/conf.d
    - /usr/share/nginx/html
  ports:
    - 80:80
  labels:
    - proxy.notify

updater:
  build: .
  volumes_from:
    - proxy
  volumes:
    - /var/run/docker.sock:/var/run/docker.sock

```

Extending the proxy
===================

Templates are defined in [Jinja2](http://jinja.pocoo.org/docs/2.9/).
You can override or extend them by arranging for files to be placed in
the `/templates` directory in the container (either via docker
inheritance or volume mapping)

There are command line options to override which templates are used in
which context.  The default is:

* vhost.conf -- used to generate a conf file for each virual host
* default.conf -- create a default web server
* index.html -- used to generate an index file for debugging or index purposes

Alternatives include

* vhost-ssl.conf -- generate an SSL terminating proxy (See SSL note)
* default-ssl-redirect.conf -- generate a default server that
  redirects all unencrypted traffic to https
* index-ssl.conf -- generate an index.html that links to the https:// sites instead of http:// sites


Using SSL
=========

If you are going to use SSL, you need to make sure you have your SSL
configuration in the NGINX container in `/etc/nginx/ssl/ssl.conf`.

Because of the way SSL works, you will need a certificate that is
valid for all proxied sites.  You can generate this certificate with
[LetsEncrypt](http://letsencrypt.org) or a commerical service.
Documentation on how to do this would be a welcome contribution to
this project (or I'll eventually get to it).

We will eventually support automatic LetsEncrypt certificate
generation.