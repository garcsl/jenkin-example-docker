# shell audit script for Linux type servers

# create working folder
mkdir -p temp;
exec > `hostname`.log;

###
# get server info
###
echo "Audit execution: `date`";
echo "Hostname: `hostname`";
cat /etc/issue;
echo;


###
# get network details
###
echo "Networking:"
/sbin/ifconfig -a > temp/ifconfig.txt;

while read line; do
# check for eth
    if [ "`echo $line | grep 'Link encap:'`" != "" ] && \
      [ "`echo $line`" == "`echo $line | grep 'Link encap:'`" ]; then
              strEth=`echo $line | awk -F' ' '{print $1}'`;
	      strMac=`echo $line | awk -F' ' '{print $5}'`;
	          fi;

# 
		  if [ "$strEth" != "lo" ] && \
		    [ "`echo $line | grep 'inet addr:'`" != "" ] && \
		      [ "`echo $line`" == "`echo $line | grep 'inet addr:'`" ]; then
		      strIp=`echo $line | awk -F' ' '{print $2}' | awk -F':' '{print $2}'`;
		      strMask=`echo $line | awk -F' ' '{print $4}' | awk -F':' '{print $2}'`;
		      echo "$strEth: $strIp   Mask: $strMask   MAC: $strMac";
		      fi;
		      done < temp/ifconfig.txt;
		      echo;
		      echo "Netstat ports";
		      /usr/sbin/lsof -i;
		      netstat -lptu;
		      echo;

		      echo -ne "DNS Servers: ";
		      while read line; do
		      strDns=`echo $line | grep 'nameserver' | awk -F' ' '{print $2}'`;
		      if [ "$strDns" != "" ]; then
		      echo -ne "$strDns  ";
		      fi;
done < /etc/resolv.conf;
echo;echo;

#echo "bash_history: yum / apt-get install history";
#find / -type f -name '.bash_history' -exec grep 'yum install' {} \; | sort | uniq;
#echo;

		      echo 'init.d directory';
		      ls /etc/init.d;
		      echo;

		      echo "Services:";
#		      if [ "`egrep -i '^red hat|^centos' /etc/issue`" != "" ]; then
                      if [ "`egrep -i '^red hat|^CentOS' /etc/redhat-release`" != "" ]; then
#		      /sbin/service --status-all | egrep -i 'running|stopped';
#                     systemctl list-units | egrep -i 'running|stopped' | awk '{print $1, print $4}'; 
                      systemctl list-units | egrep -i 'running|stopped' | awk '{print $1, $4}'
		      /sbin/chkconfig --list;
		      echo;echo "Websites:";
		      httpd -S | grep -i 'namevhost';
		      else
		      initctl list | egrep -i 'stop|running';
		      fi;
		      echo;

###
 # mysql
###
mysql -V | grep Ver
strMysqlDataPath=`grep datadir /etc/my.cnf | awk -F'=' '{print $2}';`
strMySQLEscapePath=`echo $strMysqlDataPath | sed 's/\//\\\\\//g'`;
for i in `find $strMysqlDataPath -maxdepth 1 -mindepth 1 -type d;`; do
strDbSize=`du -h --max-depth=0 $i | sed "s/$strMySQLEscapePath//g"`;
echo "DB: $i $strDbSize";
done;
echo;

###
   # Memory
###
		      strTotMem=`free -m | grep 'Mem:' | awk -F' ' '{print $2}'`;
		      strUsedMem=`free -m | grep 'Mem:' | awk -F' ' '{print $3}'`;
		      echo "Total Memory: $strTotMem MB";
		      echo "Used Memory: $strUsedMem MB";
		      echo;

###
   # CPU
###
		      cat /proc/cpuinfo | egrep -i 'cores|vendor_id|model name|physical|cpu MHz';
		      echo;

###
   # Disk info
###
		      df -h
		      echo;

###
# List all crons
###
echo "Cron jobs";
for user in $(cut -f1 -d: /etc/passwd); do
crontab -u $user -l | grep -v "no crontab";
done;
echo;


