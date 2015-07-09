#########
# Copyright (c) 2015 GigaSpaces Technologies Ltd. All rights reserved

from setuptools import setup

setup(
    zip_safe=False,
    name='servicebouncer',
    version='0.1.3',
    description='Cloudify Windows service bouncer.',
    author='Mykhailo Troianovskyi',
    author_email='mykhailo@gigaspaces.com',
    packages=[
        'bounce',
    ],
    license='LICENSE',
    install_requires=[
        'cloudify-plugins-common>=3.2',
    ]
)
