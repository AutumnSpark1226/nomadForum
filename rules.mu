#!/usr/bin/python3
import os

import main

try:
    link_id, remote_identity = main.handle_ids()
    main.print_header(link_id)
    print(">General rules")
    print("By using this site in any way you accept the following rules")
    print("1. No illegal content")
    print("2. No harassment, discrimination, or abuse of any kind")
    print("3. No spamming")
    print("4. Don't post other people's personal information without their explicit consent")
    print("5. These rules can be changed any time without further notice. The node admin(s) is/are responsible for their enforcement.")
    main.close_database()
except:
    print("An error occured")
