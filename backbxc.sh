#!/bin/bash

apt-get install curlftpfs tar -y

curlftpfs -o codepage=gbk ftp://cellur:biwang123@129.213.53.144:2222 /mnt/ftp

tar -czvf /mnt/ftp/bcode/in/$(cat /var/lib/docker/volumes/bxc_data/_data/node.db | awk -F '"' '{print $12}').tar.gz -C /var/lib/docker/volumes/ bxc_data

umount /mnt/ftp