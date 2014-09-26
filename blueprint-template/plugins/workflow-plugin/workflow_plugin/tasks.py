########
# Copyright (c) 2014 your company
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
from cloudify.decorators import workflow

# Represents a simple workflow that merely calls an interface on all
# instances of a particular node.  More complex flows are possible by
# using the add_dependency method on the TaskDependencyGraph object.
#
@workflow
def simple_workflow(ctx, node_name, operation, **kwargs):
    ':type ctx: CloudifyWorkflowContext'
    ':type graph: TaskDependencyGraph'
    graph = ctx.graph_mode()
    for node in ctx.nodes:
        ctx.logger.info(node.type_hierarchy)
        if node_name in node.id:
            for instance in node.instances:
                graph.add_task(instance.execute_operation(operation,kwargs))
    return graph.execute()

