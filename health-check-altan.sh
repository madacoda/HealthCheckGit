#!/bin/bash

#sample logging template
#logging component
#echo "test" | tee -a ../output.log



#Moving and cleaning up old conflicting files from previous runs
#Making Directory structure
mkdir old; mkdir old/stats; mkdir stats
mv stats/* old/stats/
mv output.log old/
mv allstats.txt old/

#logging component
echo "HealthCheck Script Starting.." | tee -a output.log

#logging component
echo "Moved conflicting files to OLD folder" | tee -a output.log

#logging component
echo "About to extract the following list of TGZ files : " | tee -a output.log
ls datarakes/*.tgz >> output.log


#Initial loop for extracting datarakes
#We don't want this running more than once per datarake obviously
#So the separate loops allows us to put in a condition to check for TGZ files
for i in $(ls datarakes/*.tgz);do {
	
	#logging component
	echo "Extracting datarake "$i" - Starting..." | tee -a output.log

	#extracts the datarake
	tar -xvf $i -C extracted

	#logging component
	echo "Extracted  datarake "$i" - Done!" | tee -a output.log

};done;

#logging component
echo "Finished extracting ALL datarakes - Done!" | tee -a output.log


#logging component
echo "Start parsing through datarakes for STATS..." | tee -a output.log


#Main loop statement
#This goes through each datarake
for i in $(ls extracted);do {

	#Pooling up the important files from the datarake in a single place
	mkdir poold/$i
	cp extracted/$i/var/log/syslog poold/$i/
	cp extracted/$i/var/log/user.log poold/$i/
	cp extracted/$i/var/log/commandServer.log poold/$i/
	cp extracted/$i/var/log/ntpd poold/$i/
	cp extracted/$i/tmp/datarake/HAdiagnosis.txt poold/$i/
	cp extracted/$i/tmp/datarake/df-h.txt poold/$i/
	cp extracted/$i/tmp/datarake/ifconfig.txt poold/$i/
	cp extracted/$i/tmp/datarake/proc* poold/$i/
	cp extracted/$i/tmp/datarake/rndc* poold/$i/
	cp extracted/$i/tmp/datarake/txt poold/$i/
	cp extracted/$i/tmp/datarake/top* poold/$i/
	cp extracted/$i/tmp/datarake/netstat* poold/$i/
	cp extracted/$i/etc/ntp.conf poold/$i/
	cp extracted/$i/etc/postgresql/*/main/postgresql.conf poold/$i/

	echo "Current File : ||____"$i"_____||" >> allstats.txt

	echo "Last ten errors from Syslog : " | tee -a stats/$i.txt | tee -a allstats.txt

	grep -i error extracted/$i/var/log/syslog | tail | tee -a stats/$i.txt | tee -a allstats.txt



	#Altan's 4 sections

	#1. Get DISK statistics
	echo " " | tee -a stats/$i.txt | tee -a allstats.txt
	echo "=============DISK STATS for "$i"==============" | tee -a stats/$i.txt | tee -a allstats.txt
	cat extracted/$i/tmp/datarake/df-h.txt | tee -a stats/$i.txt | tee -a allstats.txt

	#2. Get CPU statistics
	echo "==============CPU STATS for "$i"==============" | tee -a stats/$i.txt | tee -a allstats.txt
	cat extracted/$i/tmp/datarake/proc_cpuinfo.txt | grep "cpu MHz" | tee -a stats/$i.txt | tee -a allstats.txt
	cat extracted/$i/tmp/datarake/top* | grep "Cpu(s)"| tee -a stats/$i.txt | tee -a allstats.txt
	
	#3. Get Memory statistics
	echo "===========MEMORY STATS for "$i"==============" | tee -a stats/$i.txt | tee -a allstats.txt
	cat extracted/$i/tmp/datarake/proc_meminfo.txt | egrep "MemTotal|MemFree|SwapTotal|SwapFree|HighTotal|HighFree|LowTotal|LowFree" | tee -a stats/$i.txt | tee -a allstats.txt
	cat extracted/$i/tmp/datarake/top* | egrep "KiB Mem|KiB Swap" | tee -a stats/$i.txt | tee -a allstats.txt
	
	#4. Get Network statistics
	echo "==========NETWORK STATS for "$i"==============" | tee -a stats/$i.txt | tee -a allstats.txt
	cat extracted/$i/tmp/datarake/netstat-in.txt | tee -a stats/$i.txt | tee -a allstats.txt
	cat extracted/$i/tmp/datarake/netstat-rn.txt | tee -a stats/$i.txt | tee -a allstats.txt
	echo "==========================================================" | tee -a stats/$i.txt | tee -a allstats.txt
	echo " " | tee -a stats/$i.txt | tee -a allstats.txt
	echo " " | tee -a stats/$i.txt | tee -a allstats.txt
	#ADD More Stats Here Below





	
};done;

#logging component
echo "Parsing has finished! - DONE!" | tee -a output.log
