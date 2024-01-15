#!/usr/bin/python3

# nomadForum - a forum on the NomadNetwork
# Copyright (C) 2023-2024  AutumnSpark1226
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.


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
