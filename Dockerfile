FROM python:2.7

ADD requirements.txt  /root/
RUN pip install -r /root/requirements.txt
ADD templates/ /templates/
ADD generate /root/
VOLUME /etc/nginx/conf.d

ENTRYPOINT ["/root/generate"]