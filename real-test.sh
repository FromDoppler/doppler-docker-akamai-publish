#!/usr/bin/env bash

pkgName="doppler-docker-akamai-publish-test"
pkgVersion=${1:-"latest"}
contentFolder=${2:-"/`pwd`/test-content"}

# It requires having this environment variables defined with the right values:
# AKAMAI_CDN_HOSTNAME, AKAMAI_CDN_USERNAME, AKAMAI_CDN_PASSWORD, AKAMAI_CDN_CPCODE

# Stop script on NZEC
set -e
# Stop script if unbound variable found (use ${var:-} if intentional)
set -u

# Lines added to get the script running in the script path shell context
# reference: http://www.ostricher.com/2014/10/the-right-way-to-get-the-directory-of-a-bash-script/
cd $(dirname $0)

# Generate the image locally based on local content
sh build-w-docker.sh

# Run usinglocal image
docker run --rm \
	-e AKAMAI_CDN_HOSTNAME \
	-e AKAMAI_CDN_USERNAME \
	-e AKAMAI_CDN_PASSWORD \
	-e AKAMAI_CDN_CPCODE \
	-e "PROJECT_NAME=$pkgName" \
	-e "VERSION_NAME=$pkgVersion" \
	-v $contentFolder:/source \
	doppler-docker-akamai-publish