#####################################
##########  DEVELOPMENT
#####################################

########## Run developement client app 
# Pull node to build client
FROM node:18.12.0-alpine as client-development

WORKDIR /home/atmmotors

COPY ./traccar-web/modern/ .

RUN npm install 

VOLUME /home/atmmotors
VOLUME /home/atmmotors/node_modules 

EXPOSE 3000

CMD ["npm", "start"]

########## Build server continiously 
# Pull gradle 7 for build time docker
FROM gradle:7.6.0-jdk17 AS gradlew-development

WORKDIR /home/atmmotors

COPY . .
RUN mkdir -p tmp target
RUN ./gradlew assemble

VOLUME /home/atmmotors/target
VOLUME /home/atmmotors/target/lib
VOLUME /home/atmmotors/schema
VOLUME /home/atmmotors/templates
VOLUME /home/atmmotors/conf
VOLUME /home/atmmotors

CMD [ "./gradlew" , "-t", "assemble" ]

########## Run development sever
# Pull gradle 7 for build time docker
FROM openjdk:17-jdk-alpine as server-development

WORKDIR /home/atmmotors

# Install Supervisor.
RUN \
  apk update && \
  apk add  --update --no-cache \  
    gcc \
    g++ \
    make \
    python3 \
    nano \
    supervisor \
    bash \
    nano && \
  rm -rf /var/cache/apk/*

RUN mkdir -p tmp lib media logs data bin build conf modern
RUN mkdir -p /var/log/supervisor  /etc/supervisor/ 
COPY ./setup/supervisord.conf /etc/supervisor/
COPY ./setup/entrypoint.sh /
RUN chmod +x /entrypoint.sh


VOLUME /home/atmmotors/logs
VOLUME /home/atmmotors/data
VOLUME /home/atmmotors/media
VOLUME /home/atmmotors/conf
VOLUME /home/atmmotors/modern
VOLUME /home/atmmotors/lib
VOLUME /home/atmmotors
VOLUME /etc/supervisor

EXPOSE 8082
EXPOSE 9000
EXPOSE 5000-5150

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]

#####################################
##########  PRODUCTION
#####################################

########## client production 
# Pull node to build client
FROM node:18.12.0-alpine as client-production

ARG GIT_REPO="https://github.com/aristide/traccar-web"
ARG GIT_BRANCH="production"

WORKDIR /home/atmmotors

RUN \
  apk update && \
  apk add git && \
  rm -rf /var/cache/apk/*

RUN mkdir -p /tmp/traccar-web && \
    git clone -b ${GIT_BRANCH} ${GIT_REPO} /tmp/traccar-web && \
    cp -a /tmp/traccar-web/modern/.  /home/atmmotors/

RUN npm install
RUN npm run build

########## gradle build production server
# Pull gradle 7 for build time docker
FROM gradle:7.6.0-jdk17 AS gradlew-production

WORKDIR /home/atmmotors

COPY . .
RUN mkdir -p tmp
RUN ./gradlew assemble

########## Server production
# Pull java 11 runtime for running atmmotors
FROM openjdk:17-jdk-alpine as server-production

RUN apk upgrade --update && \
    apk add --update curl bash && \
    rm -rf /var/cache/apk/* && \
    mkdir -p /opt/atmmotors/logs && \
    mkdir -p /opt/atmmotors/data &&  \
    mkdir -p /opt/atmmotors/media && \
    mkdir -p /opt/atmmotors/conf

ENV JAVA_OPTS -Xms256m -Xmx1024m
COPY ./setup/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# only copy needed binaries 
COPY --from=gradlew-production /home/atmmotors/setup/traccar.xml /opt/atmmotors/conf/traccar.xml
COPY --from=gradlew-production /home/atmmotors/setup/default.xml /opt/atmmotors/conf/default.xml
COPY --from=gradlew-production /home/atmmotors/schema /opt/atmmotors/schema
COPY --from=gradlew-production /home/atmmotors/templates /opt/atmmotors/templates
COPY --from=client-production  /home/atmmotors/build /opt/atmmotors/modern
COPY --from=gradlew-production /home/atmmotors/target/lib /opt/atmmotors/lib
COPY --from=gradlew-production /home/atmmotors/target/tracker-server.jar /opt/atmmotors/atmmotors-server.jar

EXPOSE 8082
EXPOSE 5000-5150

VOLUME /opt/atmmotors/logs
VOLUME /opt/atmmotors/data
VOLUME /opt/atmmotors/media
VOLUME /opt/atmmotors/conf
VOLUME /opt/atmmotors/web

WORKDIR /opt/atmmotors

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "java", "-Xms1g", "-Xmx1g", "-Djava.net.preferIPv4Stack=true", "-jar", "atmmotors-server.jar", "conf/traccar.xml" ]

# Api reference 
FROM redocly/redoc:v2.0.0 as api-reference

RUN mkdir -p /opt/docs
COPY ./customswagger.json /usr/share/nginx/html/swagger.json
COPY ./setup/api-run.sh /usr/local/bin/docker-run.sh