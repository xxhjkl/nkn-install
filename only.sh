#!/bin/bash

cat <<\EOF > /opt/nkn/checkID.sh
#!/bin/bash
UPTIME=$(nknc info -s | grep uptime |awk '{print $2}' |awk -F "," '{print $1}')
MONEY=$(nknc info -s | grep proposalSubmitted | awk '{print $2}'|awk -F "," '{print $1}')
PSWD=$(cat /opt/nkn/PSWD)
TIME=$(expr $UPTIME / 345600)
if [[ $MONEY -ge $TIME ]]
then
echo "$(date +%F" "%T) Node revenue is normal"
exit 0
else
kill `ps aux | grep Monitor | awk '{print $2}'`
killall -9 nknd
rm -rf /opt/nkn/wallet.json
nknc wallet -n /opt/nkn/wallet.json -c <<EOF
$PSWD
$PSWD
tag123
nohup bash /opt/nkn/Monitor.sh > /opt/nkn/monitor.log 2>&1 &
echo "$(date +%F" "%T) ID Reset Successful"
fi
exit 0
EOF
sed -i s/tag123/EOF/ /opt/nkn/checkID.sh
echo "30 * * * * nohup bash /opt/nkn/checkID.sh > /opt/nkn/checkID.log 2>&1 &" >> crontab.conf
echo "@reboot nohup bash /opt/nkn/Monitor.sh > /opt/nkn/monitor.log 2>&1 &" >> crontab.conf
echo "30 * * * * nohup bash /opt/nkn/checkID.sh > /opt/nkn/checkID.log 2>&1 &" >> crontab.conf
crontab crontab.conf
rm crontab.conf