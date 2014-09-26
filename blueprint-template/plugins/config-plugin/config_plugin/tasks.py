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

#
# Example operation that is called by a relationship.  Note that
# the "related" field contains the blueprint node that was
# called out in the relationship declaration.
#
# Note that the relationship plugin execution is controlled by
# the blueprint declaration and may be called before or after
# the nodes are configured.  Since this recipe is using the
# bash plugin, whatever info I discover here must be written
# somewhere a bash script can get it (the filesystem for example).
#
# In this case, "runtime_properties" is being accessed, and it
# must be set via the REST API in the target node.
#
@operation
def relationship_get_ip(ctx, **kwargs):
    ':type ctx: CloudifyContext'
    
    """
    Gets the lookup locator for the related node running the lus
    """
    
    # Get ip address of related node.
    ip_address = ctx.related.runtime_properties['ip_address']

    ctx.logger.info("The ip address is {} ".format(ip_address))

    env_file_path = ctx.properties.get("env_file_path", "/tmp/ip")
    ctx.logger.info("Writing file {}".format(env_file_path))

    with open(env_file_path, 'a+') as env_file:
        env_file.write("{}\n".format(ip_address))

