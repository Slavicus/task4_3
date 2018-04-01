#!/bin/bash
#Скрипт создающий бекапы
function check_backups_qty () {
    backed_up_qty=$(find /tmp/backups/ -name "*$arch_name*" | wc -l);
  [[ "$backed_up_qty" -gt "$max_backup_qty" ]] && return 
}

if [ "$#" -ne 2 ]; then echo "Illegal number of parameters" >&2 exit 1
fi

target_folder="$1"
max_backup_qty="$2"

if [ ! -d "$target_folder" ]; then echo "Taget directory doesn't exist" >&2 exit 1
fi

if [[ ! $max_backup_qty =~ ^[0-9]+$ ]]; then echo "Illegal number of allowed backups" >&2 exit 1
fi

backup_path="/tmp/backups"

if [ ! -d "$backup_path" ]; then mkdir "/tmp/backups"
fi

DATE=`date +"%Y-%m-%d-%H-%M-%S"`

arch_name=$(echo $target_folder | tr "/" "-" | sed 's/^-//' | sed 's/-$//')

tar -cvzf /tmp/backups/"$arch_name"_"$DATE".tar.gz -C "$target_folder" .

while check_backups_qty; do
  oldest_filename=$(find /tmp/backups -type f -printf '%p\n' | sort | grep "$arch_name" | head -n 1)
  rm "$oldest_filename"
done
