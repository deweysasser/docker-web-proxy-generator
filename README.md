NGINX Proxy Generator
=====================

A container that 
* subscribes to docker events
* writes out NGINX config files to proxy traffic to containers
* notifies NGINX to update itself


Usage
=====

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