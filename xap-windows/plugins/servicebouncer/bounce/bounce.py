from cloudify import ctx
from cloudify.decorators import workflow

@workflow
def bounce_gridservice(ctx, **kwargs):
    graph = ctx.graph_mode()

    for node in ctx.nodes:
        for instance in node.instances:
            if node.type == 'gridservice_type':
                sequence = graph.sequence()
                sequence.add(
                    instance.execute_operation(
                        'cloudify.interfaces.lifecycle.stop'),
                    instance.execute_operation(
                        'cloudify.interfaces.lifecycle.start'),
                )

    return graph.execute()


@workflow
def deploy_datagrid(ctx, **kwargs):
    graph = ctx.graph_mode()

    for node in ctx.nodes:
        for instance in node.instances:
            if node.type == 'datagrid_type':
                graph.add_task(instance.execute_operation(
                    'cloudify.interfaces.lifecycle.start'))

    return graph.execute()


@workflow
def deploy_alternate(ctx, **kwargs):
    graph = ctx.graph_mode()

    for node in ctx.nodes:
        for instance in node.instances:
            if node.type == 'datagrid_type':
                graph.add_task(instance.execute_operation(
                    'cloudify.interfaces.lifecycle.deploy_alternate'))

    return graph.execute()
