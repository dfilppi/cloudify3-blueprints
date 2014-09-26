########
# Copyright (c) 2014 <your company>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# * See the License for the specific language governing permissions and

# * limitations under the License.
from cloudify.decorators import operation
import subprocess
import urllib
import os

#
# This plugin holds the equivalent of custom command implementations
# in Cloudify 2.7.  The blueprint maps an interface to these operations
# in the node definition
#
# This operation is just a generic implementation that executes an
# arbitrary script.  When porting, you could repurpose this to point
# at custom command scripts take from old recipes.
# 
@operation
def run_a_script(ctx, **kwargs):
    ':type ctx: CloudifyContext'
    script = ctx.properties['script']
    # Note that unlike Cloudify 2.7, 3.0 does NOT zip and xfer the entire
    # blueprint directory structure to the target node.  If you want to access
    # arbitrary scripts, you have to manually download them.  This also goes
    # for lifecycle scripts referenced by the bash plugin; if those scripts
    # access other scripts in the directory structure, you have to manually
    # download them prior to execution.
    script_path = ctx.download_resource(script)
    subprocess.check_call(["chmod", "777", script_path])
    output = subprocess.check_output([script_path, kwargs["grid_name"], kwargs["schema"], str(kwargs["partitions"]),
                                      str(kwargs["backups"]), str(kwargs["max_per_vm"]), str(kwargs["max_per_machine"])])
    ctx.logger.info(script_path + " output:" + output)

