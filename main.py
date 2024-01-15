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
import os.path
import sqlite3
import string
from sqlite3 import Connection, Cursor
from uuid import UUID
from cryptography.fernet import Fernet, MultiFernet

# configure your setup here
storage_path = ".nomadForum"  # folder containing all saved files (database, keys, etc.)
page_path = "/page/nomadForum"  # path on your node, here {node_id}:/page/nomadforum/index.mu (nomadnet url) or ~/.nomadnetwork/storage/pages/nomadforum/index.mu (file path) would be the main page
forum_name = "nomadForum"  # name your forum

connection: Connection
cursor: Cursor


def setup_db() -> None:
    global connection, cursor
    if not os.path.isdir(storage_path):
        os.mkdir(storage_path)
    connection = sqlite3.connect(storage_path + "/database.db")
    cursor = connection.cursor()
    execute_sql("CREATE TABLE IF NOT EXISTS settings (setting_id INTEGER NOT NULL UNIQUE PRIMARY KEY AUTOINCREMENT, key TEXT NOT NULL, value TEXT)")
    execute_sql("CREATE TABLE IF NOT EXISTS users (user_id INTEGER NOT NULL UNIQUE PRIMARY KEY AUTOINCREMENT, username TEXT NOT NULL UNIQUE, display_name TEXT, enabled INTEGER DEFAULT 1 NOT NULL, password TEXT NOT NULL, link_id TEXT, remote_identity TEXT, login_time INTEGER)")
    execute_sql("CREATE TABLE IF NOT EXISTS posts (numeric_id INTEGER NOT NULL UNIQUE PRIMARY KEY AUTOINCREMENT, post_id TEXT NOT NULL UNIQUE, username TEXT NOT NULL, title TEXT NOT NULL, content TEXT NOT NULL, changed INTEGER NOT NULL, locked INTEGER DEFAULT 0 NOT NULL)")
    execute_sql("CREATE TABLE IF NOT EXISTS comments (numeric_id INTEGER NOT NULL UNIQUE PRIMARY KEY AUTOINCREMENT, comment_id TEXT NOT NULL UNIQUE, post_id TEXT NOT NULL, parent TEXT NOT NULL, username TEXT NOT NULL, content TEXT NOT NULL, changed INTEGER NOT NULL)")
    # remove old sessions
    execute_sql("UPDATE users SET link_id = '0', login_time = 0 WHERE link_id != '0' AND (login_time + 86400) < unixepoch()")


def close_database() -> None:
    # changes are only written when the database closes
    global connection, cursor
    connection.commit()
    cursor.close()
    connection.close()


def execute_sql(command: str) -> None:
    global cursor
    cursor.execute(command)


def query_database(command: str) -> [[]]:
    global cursor
    result = cursor.execute(command)
    return result.fetchall()


# return true if the username is allowed
def check_username(username: str, allow_admin=False) -> bool:
    # check if string is printable
    if not set(username).issubset(set(string.printable)):
        return False
    # don't allow SQL injections and some other characters
    if "'" in username or "\\" in username or '"' in username or "`" in username or "\n" in username or "[" in username or "]" in username:
        return False
    # don't allow double space
    if "  " in username:
        return False
    # don't allow "admin" (reserved, can be added by executing the admin/create_create_admin_account.py script)
    if username.upper() == "ADMIN" and not allow_admin:
        return False
    # don't allow "system" (reserved, used by system actions in the future)
    if username.upper() == "SYSTEM":
        return False
    # don't allow "[DELETED]" (reserved for created made by deleted users); block some other variations to avoid confusion
    if username.upper() == "[DELETED]" or username.upper() == "DELETED" or username.upper() == "(DELETED)" or username.upper() == "{DELETED}":
        return False
    return True


def check_uuid(possible_uuid: str) -> bool:
    try:
        UUID(possible_uuid, version=4)
        return True
    except ValueError:
        return False


def prepare_content(content: str) -> str:
    # replace \
    content = content.replace("\\", "\\\\")
    # don't allow SQL injections
    content = content.replace("\'", "\'\'")
    # replace unwanted micron formatting
    content = content.replace("#", "\\#")  # sorry, no hidden messages
    content = content.replace("`=", "\`=")
    return content


def prepare_title(title: str) -> str:
    # remove newline
    title = title.split("\n")[0]
    # replace \
    title = title.replace("\\", "\\\\")
    # don't allow SQL injections
    title = title.replace("\'", "\'\'")
    # replace unwanted micron formatting
    title = title.replace("`", "\\`")
    return title


def print_header(link_id: str, reload=False) -> None:
    if reload:
        print("#!c=0")
    print('`F222`Bddd')
    print('-')
    account_options = "ERROR"
    if len(query_database(f"SELECT user_id FROM users WHERE link_id = '{link_id}'")) != 0:
        account_options = f"`F00f`_`[Logout`:{page_path}/logout.mu]`_`f"
    else:
        account_options = f"`F00f`_`[Login`:{page_path}/login.mu]`_`f  `F00f`_`[Register`:{page_path}/register.mu]`_`f"
    if reload:
        reload_option = "`reload=5636"
    else:
        reload_option = ""
    print(f"`c`!{forum_name}`!")
    print(f"`r`F00f`_`[Home`:{page_path}/index.mu{reload_option}]`_`f  {account_options}     ")
    print("`F222")
    print("-")
    print("`a`b`f")
    print()


def handle_ids() -> [str, str]:
    link_id, remote_identity = "", ""
    for env_variable in os.environ:
        if env_variable == "link_id":
            link_id = os.environ[env_variable]
        if env_variable == "remote_identity":
            remote_identity = os.environ[env_variable]
    if len(link_id) != 32 or not link_id.isalnum():
        print("something went wrong...")
        exit(0)
    setup_db()
    if len(remote_identity) != 0:
        if len(remote_identity) != 32 or not remote_identity.isalnum():
            print("something went wrong...")
            close_database()
            exit(0)
        else:
            check_remote_identity(link_id, remote_identity)
    return link_id, remote_identity


def check_remote_identity(link_id: str, remote_identity: str) -> None:
    query_result = query_database(f"SELECT user_id FROM users WHERE remote_identity = '{remote_identity}' AND link_id != '{link_id}'")
    if len(query_result) == 1:
        execute_sql(f"UPDATE users SET link_id = '{link_id}' WHERE user_id = {query_result[0][0]} AND remote_identity = '{remote_identity}'")
    elif len(query_result) >= 1:
        # this should NOT happen, however the system might be able to repair itself
        execute_sql(f"UPDATE users SET link_id = '0', remote_identity = '0' WHERE remote_identity = '{remote_identity}'")


def get_MultiFernet() -> MultiFernet:
    key_path = storage_path + "/key.secret"
    if os.path.isfile(key_path):
        keyfile = open(key_path, 'r')
        lines = keyfile.readlines()
        keyfile.close()
        fernets = []
        for line in lines:
            if not line.strip()[0] == "#":
                fernets.append(Fernet(line.strip().encode()))
        return MultiFernet(fernets)
    else:
        key = Fernet.generate_key()
        keyfile = open(key_path, "w")
        # add warnings to keyfile
        keyfile.write("# !!! DO NOT MODIFY THIS FILE (unless you know what you're doing). It contains keys required for the encryption of user passwords. Moficatitions can cause users not being able to log in. !!!\n")
        keyfile.write("# The first key (in the third line) will be used for encryption. All lines starting with '#' will be ignored.\n")
        keyfile.write(key.decode())
        keyfile.close()
        os.system(f"chmod 400 {key_path}")  # set permissions
        fernets = []
        fernets.append(Fernet(key))
        return MultiFernet(fernets)


def encrypt(hashed_password: str) -> str:
    mf = get_MultiFernet()
    return mf.encrypt(hashed_password.encode()).decode()


def decrypt(encrypted_password: str) -> str:
    mf = get_MultiFernet()
    return mf.decrypt(encrypted_password.encode()).decode()


def add_new_key() -> None:
    key_path = storage_path + "/key.secret"
    if os.path.isfile(key_path):
        keyfile = open(key_path, 'r')
        lines = keyfile.readlines()
        keyfile.close()
        keys = []
        for line in lines:
            keys.append(line.strip().encode())
        keys.insert(0, Fernet.generate_key())
        os.remove(key_path)
        keyfile = open(key_path, "w")
        for key in keys:
            keyfile.write(key.decode() + "\n")
        keyfile.close()
        os.system(f"chmod 400 {key_path}")  # set permissions


def rotate_keys() -> None:
    add_new_key()
    mf = get_MultiFernet()
    user_data_all = query_database("SELECT username, password FROM users")
    for user_data in user_data_all:
        execute_sql(f"UPDATE users SET password = '{mf.rotate(user_data[1].encode()).decode()}' WHERE username = '{user_data[0]}' AND password = '{user_data[1]}'")
