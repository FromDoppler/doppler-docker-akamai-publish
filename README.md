# doppler-docker-akamai-publish
Docker image to help us to publish releases to Akamai CDN

# How to use doppler-relay-akamai-publish docker image:

Docker HUB url: https://hub.docker.com/r/dopplerrelay/doppler-relay-akamai-publish/

This image is ready to upload to akamai CDN the resource files. Contains the cdn-uploader script and his dependencies ready to run.

Zero Step, define your environment variables:

You need to define this variables in your host machine. They are needed to login with the CDN ftp.

In Windows shell:

```bash
set AKAMAI_CDN_HOSTNAME=example.cdn.com # CDN netstorage domain
set AKAMAI_CDN_USERNAME=example         # Username from Akamai CDN
set AKAMAI_CDN_PASSWORD=12345           # Password from Akamai CDN
set AKAMAI_CDN_CPCODE=56789             # Cpcode provided by Akamai Netstorage
```

In Linux shell:

```bash
export AKAMAI_CDN_HOSTNAME=example.cdn.com # CDN netstorage domain
export AKAMAI_CDN_USERNAME=example         # Username from Akamai CDN
export AKAMAI_CDN_PASSWORD=12345           # Password from Akamai CDN
export AKAMAI_CDN_CPCODE=56789             # Cpcode provided by Akamai Netstorage, this is the root folder with write privileges inside the Akamai CDN
```

First Step, set the docker-compose.yml:

The environment variables in the host machine are integrated in the docker image by the docker-compose.yml file. It is required by the cdn-uploader.js script.

```bash
version: '3.2'
services:
  app:
    build:
      context: .
      dockerfile: editor.Dockerfile # Name of your dockerfile implementing doppler-docker-akamai-publish image
    environment: 
      - 'AKAMAI_CDN_HOSTNAME=${AKAMAI_CDN_HOSTNAME}'
      - 'AKAMAI_CDN_USERNAME=${AKAMAI_CDN_USERNAME}'
      - 'AKAMAI_CDN_PASSWORD=${AKAMAI_CDN_PASSWORD}'
      - 'AKAMAI_CDN_CPCODE=${AKAMAI_CDN_CPCODE}'
```

Second Step, define your dockerfile:

In order to implement the image you need to call it from a Dockerfile, you can multistage it with another one if you want.

Example using multistage:

```bash
FROM node:6.10.1 AS mseditor-env # You need to give an alias to previous executed images, in this example is: mseditor-env

# Define your stuff...
RUN mkdir /refactor
RUN mkdir /refactor/builds
WORKDIR /refactor
RUN pwd
COPY . .
RUN npm install -g node-sass@4.8.3
RUN npm install -g gulp
RUN npm install
RUN npm rebuild node-sass
EXPOSE 3000
RUN gulp default

# Call a second stage to CDN upload using doppler-docker-akamai-publish image
FROM dopplerrelay/doppler-relay-akamai-publish:latest
WORKDIR .
COPY --from=mseditor-env /refactor/builds /builds
CMD ["node", "cdn-uploader.js", "mseditor", "builds"]
```

Third step, run it with docker compose:

This will launch the build of your docker containers.

Docker compose command:

This command will get the docker-compose.yml config file, it is required that docker-compose.yml and your Dockerfile share the same path.

```bash
docker-compose up
```

NOTE:

This image will be updated in docker hub for each release in the master branch of this repository using continuous integration through travis yaml configuration.


# How to use cdn-uploader.js library:

This script upload via ftp resources from the docker container image to Akamai CDN.

Command:

```bash
node cdn-uploader.js arg1 arg2

# arg1: [REQUIRED] Is the base path to load different projects to the cdn, must be unique for each project.

# arg2: [REQUIRED] Is the build path where you found your resources.

```

Example:

```bash


drwxr-xr-x    2 root     root          4096 Jan  9 19:37 .
drwxr-xr-x    1 root     root          4096 Apr 13 13:25 ..
drwxr-xr-x    2 root     root          4096 Jan  9 19:37 cdn-uploader.js
drwxr-xr-x    1 root     root          4096 Apr 13 13:25 example/
drwxr-xr-x    1 root     root          4096 Apr 13 13:25 projects/other/stuff
drwxr-xr-x    1 root     root          4096 Apr 13 13:25 builds/build-v1.0
total 8



node cdn-uploader.js feature1 example # This will upload all files and folders inside of "example" folder recursively, note that the "example" folder will not be uploaded.

node cdn-uploader.js feature2 projects/other # This will upload all files and folders inside of "other" folder recursively, note that the "other" folder will not be uploaded but "stuff" yes.


#Real examples:

node cdn-uploader.js mseditor builds

#Will upload build-v1.0 inside of builds/ folder

http://cdn.example.akamai.com/mseditor/build-v1.0/scripts/example.gif

```

Note: The shell context init in the same folder where cdn-uploader.js is running.