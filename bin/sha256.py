#! /usr/bin/env python3
import sys, hashlib
hasher = hashlib.sha256()
try:
    with open(sys.argv[1], 'rb') as file_to_check:
        hasher.update(file_to_check.read())
        print(hasher.hexdigest())
except:
    print('Usage: sha256 filename')
