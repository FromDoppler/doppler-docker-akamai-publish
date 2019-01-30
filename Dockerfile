FROM node:lts-alpine as build
WORKDIR /app

# copy node package definitions and restore as distinct layers
COPY package.json yarn.lock ./
RUN yarn

# copy code in a different layer
COPY cdn-uploader.js ./
# TODO: run any kind of test

FROM node:lts-alpine as runtime
WORKDIR /app
# Be sure of copying only the minimum required files, by the moment only:
#     cdn-uploader.js, package.json, yarn.lock, node_modules
COPY --from=build /app ./

VOLUME /source
ENV AKAMAI_CDN_HOSTNAME=nsfoo.upload.akamai.com \
    AKAMAI_CDN_USERNAME=testuser \
    AKAMAI_CDN_PASSWORD=testpassword \
    AKAMAI_CDN_CPCODE=12345 \
    PROJECT_NAME=bar \
    VERSION_NAME=v1.0.0-build1234
CMD node cdn-uploader.js /source $PROJECT_NAME $VERSION_NAME
