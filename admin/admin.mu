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
import sys


try:
    sys.path.extend([os.path.abspath(os.path.join(os.path.dirname(__file__), os.pardir))])
    import main
    link_id, remote_identity = main.handle_ids()
    main.print_header(link_id)
    print("Admin page")
    main.close_database()
except:
    print("An error occured")
