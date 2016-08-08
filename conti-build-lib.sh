###!/bin/bash
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

function docker_build()
{
	set -x
	TITLE="$1"
	DOCKER_FILE="$2"
	DOCKER_IMAGE="$3"
	ERR_STATUS=${4:-333}
	
	echo "building $TITLE docker image ..."
	if $SUDO docker build -f "$DOCKER_FILE" -t "$DOCKER_IMAGE" $PROXY $USER_IDs $ODEN_VERSION . ; then
		echo "done."
	else
		echo "FAILED to build $DOCKER_FILE. ABORT."
		exit $ERR_STATUS
	fi
	set +x
}

function getwd ()
{
	if PwdCmd=$(which pwd) ; then
		"$PwdCmd"
	else
		pwd
	fi
}

function mkScript()
{
	SCRIPT_DIR="$1"
	SCRIPT_FNAME="$2"
	COPYRIGHT="$3"
	_DOCKER_IMAGE="$4"
	
	cat <<EOF | sed -e "s%^# Copyright.*%$COPYRIGHT%" > "$SCRIPT_DIR/$SCRIPT_FNAME"
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

export CB_DOCKER_IMAGE="$_DOCKER_IMAGE"

# any options for docker run, e.g. port mappings, volume mappings, etc.
#  can be defined in this environment variable:
export CB_DOCKER_RUN_OPTS="-p 8001:8001 -p 8002:8002 -p 8003:8003"

cb $SCRIPT_FNAME "\$@"

EOF
}
