import sys
import os
from os.path import join, realpath, split, basename, dirname
import re

opt2_re = re.compile(r'.*\.opt-2\.pyc$')

framework_path = sys.argv[1]
version_dir = realpath(join(framework_path, 'Versions', 'Current'))
py_version = split(version_dir)[1]
py_lib = join(version_dir, 'lib', f'python{py_version}')

for dirpath, dirnames, filenames in os.walk(py_lib):
    if basename(dirpath) == '__pycache__':
        parent = dirname(dirpath)
        for filename in filenames:
            file_path = os.path.join(dirpath, filename)
            if opt2_re.match(filename):
                base = filename.split('.')[0]
                py_file = os.path.join(parent, base + '.py')
                pyc_file = os.path.join(parent, base + '.pyc')
                os.rename(file_path, pyc_file)
                try:
                    os.unlink(py_file)
                except FileDoesNotExist:
                    pass
            else:
                try:
                    os.unlink(file_path)
                except FileDoesNotExist:
                    print(f'{file_path} does not exist!')
        try:
            os.rmdir(dirpath) # __pycache__ should be empty now
        except:
            print(f'{dirpath} is not empty!')
