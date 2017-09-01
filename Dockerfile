FROM arm32v6/alpine

USER root
WORKDIR /root/

RUN 	mkdir -p /var/www/ghost
WORKDIR	/var/www/ghost/

RUN 	apk update && \
	apk upgrade && \
	apk add curl

RUN 	apk add --no-cache --virtual .gyp \
	python \
	make \
	g++

RUN	apk add nodejs-lts \
	nodejs-npm && \
	curl -sSLO https://github.com/TryGhost/Ghost/releases/download/0.11.8/Ghost-0.11.8.zip && \
	unzip Ghost-0.11.8.zip

RUN 	addgroup www-data
RUN	adduser -D  -h /home/ghost -s /bin/sh ghost -G www-data
RUN	chown ghost:www-data .
RUN	chown ghost:www-data -R *

RUN 	npm install -g pm2

RUN ln -s /usr/bin/node /usr/bin/nodejs

USER ghost
WORKDIR /var/www/ghost
	
RUN 	npm install

EXPOSE 2368
EXPOSE 2369

RUN	sed -e s/127.0.0.1/0.0.0.0/g ./config.example.js > ./config.js

VOLUME ["/var/www/ghost/content/apps"]
VOLUME ["/var/www/ghost/content/data"]
VOLUME ["/var/www/ghost/content/images"]

CMD ["pm2", "start", "index.js", "--name", "blog", "--no-daemon"]
