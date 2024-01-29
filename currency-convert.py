#!/usr/bin/env -S nix develop . --command python

from datetime import datetime
from forex_python.converter import get_rate
import sys
import argparse as ap

"""
Convert currencies at certain date.
"""

__author__ = 'Boris Glavic'

def main(d,fromc,toc):
    print(get_rate(fromc, toc, d))

if __name__ == '__main__':
    parser = ap.ArgumentParser(description='Convert currencies')

    parser.add_argument("-d", '--date', default=None, help='exchange rate as of date (YEAR-MM-DD)', required=False)
    parser.add_argument("-f", '--from_currency', default="EUR", help='exchange from this currency', required=True)
    parser.add_argument("-t", '--to_currency', default="USD", help='exchange into this currency', required=True)

    args=parser.parse_args()

    # convert date
    if args.date:
        date_parts = [ int(x) for x in args.date.split("-") ]
        d = datetime(date_parts[0], date_parts[1], date_parts[2])
    else:
        d = datetime.now()

    main(d, args.from_currency,args.to_currency)
