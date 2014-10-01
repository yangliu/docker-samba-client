#!/bin/bash

set -e

mounts="${@}"
targets=()
num=1
credentials_file_base="/root/smbcredentials"

for mnt in $mounts; do

  # parse smb url
  if [[ $mnt == smb://* ]]; then

    # remove smb://
    mnt=${mnt:6}

    # test if we have domain
    domain=$(echo $mnt | awk -F ';' '{print $1}')
    if [ "$domain" != "$mnt" ]; then
      domain=",domain=${domain}"
      mnt=$(echo $mnt | awk -F ';' '{print $2}')
    else
      domain=""
    fi

    # test if we need credentials
    usrpwd=$(echo $mnt | awk -F '@' '{print $1}')
    if [ "$usrpwd" != "$mnt" ]; then
      # echo "username=$(echo $usrpwd | awk -F ':' '{print $1}')" > "${credentials_file_base}${num}"
      # echo "password=$(echo $usrpwd | awk -F ':' '{print $2}')" >> "${credentials_file_base}${num}"
      credentials=",credentials=${credentials_file_base}${num}"
      mnt=$(echo $mnt | awk -F '@' '{print $2}')
    else
      credentials=""
    fi

    # extract server/path & target
    src=$(echo $mnt | awk -F ':' '{print $1}')
    target=$(echo $mnt | awk -F ':' '{print $2}')
    if [[ $target == /* ]]; then
      target=${target:1}
    fi
    target="/mnt/samba/${target}"
    targets+=("$target")

    # do mounting
    mkdir -p $target

    echo "[DEBUG] Try to mount samba share: mount -t cifs -o file_mode=0644,dir_mode=0775${credentials}${domain} //${src} ${target}"
    # mount -t cifs -o file_mode=0644,dir_mode=0775${credentials}${domain} //${src} ${target}

    num=$((num+1))
  fi
done

exec inotifywait -m "${targets[@]}"