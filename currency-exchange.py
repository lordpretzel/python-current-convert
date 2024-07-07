#!/usr/bin/env -S nix develop . --command python

from datetime import datetime
#from forex_python.converter import get_rate
import sys
import argparse as ap
import requests
# import json

"""
Convert currencies at certain date.
"""

__author__ = 'Boris Glavic'

FIXER_URL = "http://data.fixer.io/api/latest"
API_KEY = "d0bba9a8110469675c11c5a5ba833672"

def fixer_exchange_rate(hist_date, from_currency, to_currency):
    params = {
        "access_key": API_KEY,
        "symbols": from_currency + "," + to_currency
    }    
    response = requests.get(FIXER_URL, params=params, timeout=1000)
    if response.status_code == 200:
        data = response.json()
        #print(data)
        from_rate = float(data["rates"][from_currency])
        to_rate = float(data["rates"][to_currency])
        result_rate = to_rate / from_rate
        return result_rate
        
# def main(d,fromc,toc):
#     print(get_rate(fromc, toc, d))

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

    fixer_exchange_rate(d, args.from_currency,args.to_currency)
