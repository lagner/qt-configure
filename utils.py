import os
from contextlib import contextmanager


@contextmanager
def pushd(directory):
    last_dir = os.getcwd()
    os.chdir(directory)
    yield
    os.chdir(last_dir)

