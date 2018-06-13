import os

REPO_DIR = os.path.dirname(os.path.realpath(__file__))

SKIP_MODULES_FILE = 'skip_modules.txt'
NO_FUTURES_FILE = 'no_futures.txt'
OPTIONS_FILE = 'options.txt'

CONFIGURATION_DIR = os.path.join(REPO_DIR, 'configuration')


def _file_readlines(filename):
    with open(filename, 'r') as data:
        keys = data.readlines()
        return [value.rstrip() for value in keys]


def skip_modules():
    filename = os.path.join(CONFIGURATION_DIR, SKIP_MODULES_FILE)
    keys = _file_readlines(filename)
    return keys
