import os
from six import StringIO
from conans import ConanFile
from utils import pushd
from config import skip_modules
from pprint import pprint


class QtConan(ConanFile):
    name = 'Qt'
    version = '5.11'
    settings = 'os', 'compiler', 'build_type', 'arch'
    options = {}
    default_options = ''

    branch = '5.11'

    def get_all_submodules(self):
        res = []
        with pushd('qt5'):
            buf = StringIO()
            self.run('git config --file .gitmodules --get-regexp path', output=buf)
            output = buf.getvalue()
            for line in output.split('\n'):
                columns = line.split(' ')
                if columns and len(columns) > 1:
                    res.append(columns[1])
        return res

    def source(self):
        args = {
            'branch': self.branch,
            'url': 'https://github.com/qt/qt5.git'
        }
        if not os.path.isdir('qt5'):
            self.run("git clone --branch {branch} --single-branch --depth 1 {url}".format(**args))

        extra_modules = set(skip_modules())
        pprint(extra_modules)

        all_submodules = self.get_all_submodules()
        pprint(all_submodules)

        with pushd('qt5'):
            for submodule in all_submodules:
                if submodule not in extra_modules:
                    self.run('git submodule update --init --recursive --depth 1 ' + submodule)
                else:
                    print('skip ' + submodule)

    def build(self):
        with pushd('qt5'):
            self.run('./configure -h')

    def package(self):
        pass
