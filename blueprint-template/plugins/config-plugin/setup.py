__author__ = 'your username'
from setuptools import setup

setup(
    zip_safe=True,
    name='config-plugin',
    version='0.1.0',
    author='your username',
    author_email='your email',
    packages=[
        'config_plugin'
    ],
    license='APACHE 2.0',
    description='',
    install_requires=[
        "cloudify-plugins-common==3.0"
    ],
)
