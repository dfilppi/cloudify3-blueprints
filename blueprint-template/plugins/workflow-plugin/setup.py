__author__ = 'your username'
from setuptools import setup

PLUGINS_COMMON_VERSION = "3.0"
PLUGINS_COMMON_BRANCH = "develop"
PLUGINS_COMMON = "https://github.com/cloudify-cosmo/cloudify-plugins-common/tarball/{0}".format(PLUGINS_COMMON_BRANCH)

setup(
    zip_safe=True,
    name='workflow-plugin',
    version='0.1.0',
    author='your username',
    author_email='your email',
    packages=[
        'workflow_plugin'
    ],
    license='APACHE 2.0',
    description='',
    install_requires=[
        "cloudify-plugins-common"
    ],
    dependency_links=["{0}#egg=cloudify-plugins-common-{1}".format(PLUGINS_COMMON, PLUGINS_COMMON_VERSION)] 
)
