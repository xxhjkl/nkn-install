#!/bin/bash
FTP="ftp://biwang:biwang123@ramiko.me"
umount /mnt/ftp
rm -rf /mnt/ftp
if [[ "$(netstat -an | grep 30002)" ]]
then
echo "NKN is running, skip"
exit 0
else
mkdir /mnt/ftp
curlftpfs -o codepage=gbk $FTP /mnt/ftp
wallet=$(cat `find / -name wallet.json` |awk -F '"' '{print $18}')
mkdir /mnt/ftp/nkn/wallet/$wallet
umount /mnt/ftp
fi