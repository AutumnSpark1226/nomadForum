#!/usr/bin/python3
from tinydb import TinyDB

import main

main.print_header()
try:
    userdb = TinyDB('~/.nomadForum/databases/users.json')
    contentdb = TinyDB('~/.nomadForum/databases/content.json')
    print("post")
except:
    print("An error occured")
