FROM node:lts-alpine AS doppler-relay-akamai-publish
WORKDIR /app
COPY . .
RUN yarn
VOLUME /source
ENV AKAMAI_CDN_HOSTNAME=nsfoo.upload.akamai.com
ENV AKAMAI_CDN_USERNAME=testuser
ENV AKAMAI_CDN_PASSWORD=testpassword
ENV AKAMAI_CDN_CPCODE=12345
ENV PROJECT_NAME=bar
ENV VERSION_NAME=v1.0.0-build1234
CMD node cdn-uploader.js /source $PROJECT_NAME $VERSION_NAME
