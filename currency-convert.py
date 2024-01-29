#!/usr/bin/env -S nix develop . --command python

from datetime import datetime
from forex_python.converter import get_rate
import sys

"""
Convert currencies at certain date.
"""

__author__ = 'Boris Glavic'

def main(dstr):
    darr = [ int(x) for x in dstr.split('-') ]
    d = datetime(darr[0], darr[1], darr[2])
    print(get_rate('%s', '%s', d))

if __name__ == '__main__':
    main(sys.argv[1:])
