#!/bin/bash
#sudo crontab -e
# * * * * * /home/ex3.sh >> /var/log/ex3.log 2>&1 # ex3-user-creation
# inotifywait -m -e modify,attrib --timefmt '%Y-%m-%d %H:%M:%S' --format '%T %e %w%f' /etc/nginx/nginx.conf


set -euo pipefail

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
max_accounts=5
state_directory="/var/lib/ex3"
accounts_file="$state_directory/created-users.log"
mkdir -p "$state_directory"
touch "$accounts_file"

do_nothing() {
    # crontab -l | sed '/# ex3.log$/d' | crontab -
    echo "Nothing to do"
}

update_nginx() {
    echo "Updating nginx conf /etc/nginx/nginx.conf"
    su -s /bin/sh "$username" -c 'echo "# Hello from $USER" >> /etc/nginx/nginx.conf'
    echo "Added '# Hello from $username' to /etc/nginx/nginx.conf."
}

create_random_user() {
    username="user_$(openssl rand -hex 8)"
    useradd --no-create-home "$username"
    echo "Created user: $username"
    echo "$username" >> "$accounts_file"
}

create_user_and_update_nginx() {
    create_random_user
    update_nginx
}

do_nothing_or_create_user() {
    created_accounts="$(wc -l <"$accounts_file")"
    if [[ "$created_accounts" -ge "$max_accounts" ]]; then
        do_nothing
    else
        create_user_and_update_nginx
    fi
}

do_nothing_or_create_user