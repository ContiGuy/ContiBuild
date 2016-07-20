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

DOCKER_IMAGE_BASE="conti-guy/conti-build.base"
DOCKER_IMAGE_ENV="conti-guy/conti-build"
DOCKER_IMAGE_FINAL="conti-guy/conti-build.add"

if docker version ; then :
else
	SUDO=sudo
fi

function getwd ()
{
	if PwdCmd=$(which pwd) ; then
		"$PwdCmd"
	else
		pwd
	fi
}

if [ "XX$http_proxy" != "XX" ] ; then
PROXY="--build-arg HTTP_PROXY=$http_proxy \
	--build-arg http_proxy=$http_proxy \
	--build-arg HTTPS_PROXY=$http_proxy \
	--build-arg https_proxy=$http_proxy"
fi

USER_IDs="--build-arg UserID=$(id -u) --build-arg GroupID=$(id -g)"

echo "building base docker image ..."
if $SUDO docker build -f Dockerfile.base -t "$DOCKER_IMAGE_BASE" $PROXY $USER_IDs . ; then
	echo "done."
else
	echo "FAILED. ABORT."
	exit 29
fi

echo "building extended docker image ..."
if $SUDO docker build -f Dockerfile.ext -t "$DOCKER_IMAGE_ENV" $PROXY $USER_IDs $ODEN_VERSION . ; then
	echo "done."
else
	echo "FAILED. ABORT."
	exit 29
fi

echo "building playground docker image ..."
if $SUDO docker build -f Dockerfile.add -t "$DOCKER_IMAGE_FINAL" $PROXY $USER_IDs . ; then
	echo "done."
else
	echo "FAILED. ABORT."
	exit 29
fi

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
	"$DOCKER_IMAGE_ENV" \
	bash -c "[ -d /conti-build-tools ] && cp /go/bin/cobui /conti-build-tools" ; then

	## bash -c "[ -d /conti-build-tools ] && cp /go/bin/gopath /go/bin/windows_amd64/gopath.exe /conti-build-tools" ; then

	echo " ... done."
else
	echo "FAILED."
	exit 27
fi

cat cb.sh |
	sed -e "s%^# SUDO=.*%SUDO=$SUDO%" \
		-e "s%^DOCKER_IMAGE=.*%DOCKER_IMAGE='$DOCKER_IMAGE_FINAL'%" \
		-e "s%^# Copyright.*%$COPYRIGHT%" \
	> "$TOOLS_DIR/cb" || exit 31

## for tool in go gvt cobra ego elm psc pulp upx ; do
for tool in go gvt cobra ego gometalinter oden elm upx make ; do
	## cat > "$TOOLS_DIR/$tool" <<EOF
	cat <<EOF | sed -e "s%^# Copyright.*%$COPYRIGHT%" > "$TOOLS_DIR/$tool"
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

#
# containerizing wrapper for $tool
#

cb $tool "\$@"

EOF

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

