FROM alpine:latest AS doppler-relay-akamai-publish
WORKDIR .
RUN mkdir ./ci-last-run
RUN echo "">./ci-last-run/`date`
RUN apk update && apk upgrade && apk add nodejs
COPY cdn-uploader.js .
RUN npm init --yes
RUN npm install basic-ftp