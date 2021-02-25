from distutils.core import setup

NAME = "pyml_example"

setup(
    name=NAME,
    version="0.0.1",
    author="Jonathan Laurent",
    author_email="Jonathan.laurent@cs.cmu.edu",
    description="A small example package",
    packages=[NAME],
    package_data={NAME: ['pywrap.so']})
