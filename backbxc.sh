#!/bin/bash
apt-get install curlftpfs tar -y
curlftpfs -o codepage=gbk ftp://root:biwang123@47.88.220.107 /mnt
tar -czvf /mnt/biwang/bcode/$(cat /var/lib/docker/volumes/bxc_data/_data/node.db | awk -F '"' '{print $12}').tar.gz -C /var/lib/docker/volumes/ bxc_data
umount /mnt
