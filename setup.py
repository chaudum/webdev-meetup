# -*- coding: utf-8 -*-
# vim: set fileencodings=utf-8

__docformat__ = "reStructuredText"


setup(
    name = 'meetup',
    author = 'Christian Haudum',
    author_email = 'christian.haudum@crate.io',
    namespace_packages = [],
    packages = find_packages('src'),
    package_dir = {'':'src'},
    install_requires = [],
    entry_points = {
        'console_scripts': []
        },
    include_package_data = True,
    zip_safe = True,
)
