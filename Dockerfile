FROM node:alpine

RUN mkdir -p /opt/app
RUN apk add --no-cache libc6-compat
ENV NODE_ENV development
ENV PORT 3000
EXPOSE 3000

VOLUME ./src:/opt/app/src
VOLUME ./pages:/opt/app/pages

WORKDIR /opt/app

COPY package.json /opt/app
COPY package-lock.json /opt/app

RUN npm install --no-optional

COPY . /opt/app

RUN addgroup -g 1001 -S nodejs
RUN adduser -S nextjs -u 1001
RUN chown nextjs /opt/app

USER nextjs

# RUN npm run build
RUN npx next telemetry disable

CMD [ "npx", "next" ]

##   FROM node:12.15.0 AS base
##   LABEL maintainer="Terry J. Owen <terry.owen@duke.edu>"
##   ARG BUILD_ENV
##   ENV BUILD_ENV ${BUILD_ENV:-local}
##   RUN apt-get update
##   WORKDIR /tams
##
##   #####################################
##   #        API ENVIRONMENT            #
##   #####################################
##
##   FROM base AS api-base
##   COPY ./tams-api/package.json ./tams-api/package-lock.json ./
##   RUN npm install && npm cache clean --force
##   COPY ./tams-api/ ./
##   RUN chmod 777 /tams/data /tams/private
##   VOLUME /tams/data
##   VOLUME /tams/private
##   EXPOSE 8004
##
##   FROM api-base AS api-dev
##   CMD ["npm", "start"]
##
##   FROM api-base AS api
##   RUN npm install pm2 -g
##   RUN npm run build && rm -rf node_modules src
##   RUN chmod +x /tams/entrypoint.sh
##   ENTRYPOINT /tams/entrypoint.sh $BUILD_ENV
##
##   #####################################
##   #       REACT ENVIRONMENT           #
##   #####################################
##
##   FROM base AS react-base
##   ENV REACT_APP_BUILD_ENV $BUILD_ENV
##   COPY ./tams-react/package.json ./tams-react/package-lock.json ./
##   RUN npm install && npm cache clean --force
##   COPY ./tams-react /tams
##
##   FROM react-base AS react-dev
##   EXPOSE 3000
##   COPY ./tams-react/.env.local /tams/
##   CMD [ "npx", "concurrently", "npm:start:instrumented:dockerized" ]
##
##   FROM react-base AS react-test
##   CMD ["npm", "run", "start:instrumented"]
##
##   FROM react-base AS react
##   RUN apt-get install -y nginx
##   COPY ./tams-react/nginx.conf /etc/nginx/nginx.conf
##   RUN npm run build && rm -rf node_modules src
##   EXPOSE 80
##   CMD [ "/usr/sbin/nginx" ]
