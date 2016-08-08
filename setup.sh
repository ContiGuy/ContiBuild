#!/bin/bash
#
# Copyright © 2016 - present:  Conti Guy  <mrcs.contiguy@mailnull.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

COPYRIGHT='# Copyright © 2016 - present:  Conti Guy  <mrcs.contiguy@mailnull.com>'

#
# build the docker image
#

ODEN_VERSION="--build-arg OdenVersion=0.3.5"

DOCKER_IMAGE_GOBASE="conti-guy/conti-build.base"
DOCKER_IMAGE_GOTOOLS="conti-guy/conti-build"
DOCKER_IMAGE_ELM="conti-guy/conti-build.elm"

#~ DOCKER_IMAGE_FINAL="conti-guy/conti-build.add"

. conti-build-lib.sh

if docker version ; then :
else
	SUDO=sudo
fi

if [ "XX$http_proxy" != "XX" ] ; then
PROXY="--build-arg HTTP_PROXY=$http_proxy \
	--build-arg http_proxy=$http_proxy \
	--build-arg HTTPS_PROXY=$http_proxy \
	--build-arg https_proxy=$http_proxy"
fi

USER_IDs="--build-arg UserID=$(id -u) --build-arg GroupID=$(id -g)"

docker_build base go.Dockerfile "$DOCKER_IMAGE_GOBASE" 33

docker_build extended go-tools.Dockerfile "$DOCKER_IMAGE_GOTOOLS" 43

#~ docker_build playground Dockerfile.add "$DOCKER_IMAGE_FINAL" 53

# DOCKER_IMAGE_ELM="conti-guy/conti-build.elm"
docker_build elm elm.Dockerfile "$DOCKER_IMAGE_ELM" 63


TOOLS_DIR="$(pwd)/conti-build-tools"
LT="-v $TOOLS_DIR:/conti-build-tools"

[ -d "$TOOLS_DIR" ] && rm -rf "$TOOLS_DIR"
mkdir "$TOOLS_DIR" || exit 23

echo "copying helper tools from docker image ..."
if $SUDO docker run \
	-it --rm \
	$LT \
	-e "HOME=/tmp" \
	-u $(id -u):$(id -g) \
	"$DOCKER_IMAGE_GOTOOLS" \
	bash -c "[ -d /conti-build-tools ] && cp /go/bin/cobui /conti-build-tools" ; then

	## bash -c "[ -d /conti-build-tools ] && cp /go/bin/gopath /go/bin/windows_amd64/gopath.exe /conti-build-tools" ; then

	echo " ... done."
else
	echo "FAILED."
	exit 27
fi

cat cb.sh |
	sed -e "s%^# SUDO=.*%SUDO=$SUDO%" \
		-e "s%^# Copyright.*%$COPYRIGHT%" \
		-e "s%CbDockerDefaultImage%$DOCKER_IMAGE_GOTOOLS%" \
	> "$TOOLS_DIR/cb" || exit 31

		#~ -e "s%^DOCKER_IMAGE=.*%DOCKER_IMAGE='$DOCKER_IMAGE_FINAL'%" \


## for tool in go gvt cobra ego elm psc pulp upx ; do
# for tool in go gvt cobra ego gometalinter oden elm elm-server elm-ui upx make ; do
for tool in go gvt cobra ego gometalinter oden upx make ; do

	mkScript "$TOOLS_DIR" "$tool" "$COPYRIGHT" "$DOCKER_IMAGE_GOTOOLS"

done

# for tool in go gvt cobra ego gometalinter oden elm elm-server elm-ui upx make ; do
for tool in elm elm-server elm-ui ; do

	mkScript "$TOOLS_DIR" "$tool" "$COPYRIGHT" "$DOCKER_IMAGE_ELM"

done

chmod a+x "$TOOLS_DIR"/*                                      || exit 32

export PATH="$TOOLS_DIR:$PATH"

# echo "#"
# echo "# the following tools are available for you now:"
# echo "#"

export GOPATH=/tmp/conti-build/test-$$/go
DIR="$GOPATH/src/trial"
if mkdir -p "$DIR" && cd "$DIR" ; then :
else
	echo "FAILED to create and use test folder! ABORT."
	exit 47
fi

# echo
# echo "### go tools ###"
# # set -x
# cb go version
# echo
# cb gvt help
# echo
# cb cobra help
# echo
# cb ego --version
# echo
# 
# echo
# echo "### elm tools ###"
# cb elm make --version
# echo
# cb elm package --help
# echo
# echo "elm repl"
# cb elm repl --version
# echo
# # cb elm reactor --version
# 
# # echo
# # echo "### PureScript tools ###"
# # # echo "psc # PureScript compiler"
# # cb psc --help
# # echo
# # cb pulp --help
# # set +x

# echo
# echo "SUCCESS!!  please make sure the tools in the local folder 'conti-build-tools' are in your PATH"
# echo
echo "#"
echo "# SUCCESS."
echo "#"
echo "# the following tools are available for you now"
echo "#  ( please make sure they are in your PATH ) :"
echo "#"

# file "$(basename $TOOLS_DIR)"/*
file "$TOOLS_DIR"/*   ## | sed -e "s:$(basename $TOOLS_DIR)/::"

