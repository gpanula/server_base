#!/bin/sh

# ref: https://silvinux.wordpress.com/2015/01/04/dynamic-motd-centosredhat/

# figlet can be downloaded at https://pkgs.org/download/figlet

# drpepper is downloaded from http://www.figlet.org/fontdb_example.cgi?font=drpepper.flf
# the drpepper.flf resides in /usr/share/figlet

if [ -e /usr/share/figlet/drpepper.flf ]
then
  figlet -f drpepper $(hostname -s)
else
  figlet -f small $( hostname -s )
fi

printf "\n"

[ -e /etc/system-release ] && printf "Host is running %s \n" "$(cat /etc/system-release)" && printf "\n"

#System date
date=`date`

#System load
LOAD1=`cat /proc/loadavg | awk {'print $1'}`
LOAD5=`cat /proc/loadavg | awk {'print $2'}`
LOAD15=`cat /proc/loadavg | awk {'print $3'}`

#System uptime
uptime=`cat /proc/uptime | cut -f1 -d.`
upDays=$((uptime/60/60/24))
upHours=$((uptime/60/60%24))
upMins=$((uptime/60%60))
upSecs=$((uptime%60))

#Root fs info
root_usage=`df -h / | awk '/\// {print $4}'|grep -v "^$"`
#fsperm=$(mount | grep root | awk '{print $6}' | awk -F"," '{print $1}')

#Memory Usage
memory_usage=`free -m | awk '/Mem:/ { total=$2 } /buffers\/cache/ { used=$3 } END { printf("%3.1f%%", used/total*100)}'`
#swap_usage=`free -m | awk '/Swap/ { printf("%3.1f%%", $3/$2*100) }'`

#Users
users=`users | wc -w`
USER=`whoami`

#Processes
processes=`ps aux | wc -l`

#Interfaces
INTERFACE=$(ip -4 ad | grep 'state UP' | awk -F ":" '!/^[0-9]*: ?lo/ {print $2}')

echo "System information as of: $date"
echo
printf "System Load:\t%s %s %s\n" $LOAD1, $LOAD5, $LOAD15
printf "System Uptime:\t%s "days" %s "hours" %s "min" %s "sec"\n" $upDays $upHours $upMins $upSecs
printf "Memory Usage:\t%s\t\t\tUsage On /:\t%s\n" $memory_usage $root_usage
printf "Local Users:\t%s\t\t\tProcesses:\t%s\n" $users $processes
printf "\n"
printf "Interface\tMAC Address\t\tIP Address\t\n"

for x in $INTERFACE
do
        MAC=$(ip ad show dev $x |grep link/ether |awk '{print $2}')
        IP=$(ip ad show dev $x |grep -v inet6 | grep inet|awk '{print $2}')
        printf  $x"\t\t"$MAC"\t"$IP"\t\n"

done

# AWS info
if [ ! -e /usr/local/etc/system-location ] && [ ! -z "$(  curl -s --connect-timeout 1 http://169.254.169.254/latest/meta-data/placement/availability-zone )" ]
then
  # we are running in AWS
  az=$( curl -s --connect-timeout 1 http://169.254.169.254/latest/meta-data/placement/availability-zone )
  instancetype=$( curl -s --connect-timeout 1 http://169.254.169.254/latest/meta-data/instance-type )
  instanceid=$( curl -s --connect-timeout 1 http://169.254.169.254/latest/meta-data/instance-id )
  printf "\nInstance Type:\t%s\t\tAZ:  %s\n" $instancetype $az
  printf "Instance-ID:\t%s\n" $instanceid
else
  # we are NOT running AWS
  cat /usr/local/etc/system-location
fi

echo

if [ -e /usr/local/etc/system-announcement ]
then
  cat /usr/local/etc/system-announcement
fi

