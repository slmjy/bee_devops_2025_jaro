echo "System informations for host: `hostname`:"
echo "-------------------------------------------"
echo "Uptime: `uptime`"
DISTRONAME=`lsb_release -a | grep "Description:" | awk -F: '{print $2}' | tr -d '[:space:]'`
echo "Distribution: $DISTRONAME"
echo "Kernel version: `uname -r`"
echo "Architecture: `uname -m`"
TOTALMEM=`free -m | grep Mem | awk '{print $2}'`
FREEMEM=`free -m | grep Mem | awk '{print $4}'`
echo "Total memory: $TOTALMEM GiB"
echo "Free memory: $FREEMEM GiB"
echo "Current user: `whoami`"
