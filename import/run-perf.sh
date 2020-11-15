#!/bin/bash

LINK_DELAY_MAX=301
LINK_DELAY_MIN=1
LINK_DELAY_STEP=5
BANDWIDTH_MAX=1026
BANDWIDTH_MIN=1
BANDWIDTH_STEP=5


# Parsing arguments
for i in "$@"
do
case $i in
    --link-delay-max=*)
    LINK_DELAY_MAX="${i#*=}"
    shift # past argument=value
    ;;
    --link-delay-min=*)
    LINK_DELAY_MIN="${i#*=}"
    shift # past argument=value
    ;;	
	--link-delay-step=*)
    LINK_DELAY_STEP="${i#*=}"
    shift # past argument=value
    ;;
    --window-size-max=*)
    WINDOW_SIZE_MAX="${i#*=}"
    shift # past argument=value
    ;;
    --window-size-min=*)
    WINDOW_SIZE_MIN="${i#*=}"
    shift # past argument=value
    ;;	
	--window-size-step=*)
    WINDOW_SIZE_STEP="${i#*=}"
    shift # past argument=value
    ;;
	--help)
	echo "Usage: ./run-perf.sh [OPTION]..."
	echo "Possible options:"
	echo "	--link-delay-max=VALUE"
	echo ""
	echo "	--link-delay-min=VALUE"
	echo ""
	echo "	--link-delay-step=VALUE"
	echo ""
	echo "	--window-size-max=VALUE"
	echo ""
	echo "	--window-size-min=VALUE"
	echo ""
	echo "	--window-size-step=VALUE"
	echo ""
	exit
	;;
    *)
          # unknown option
    ;;
esac
done


out_file='/home/vagrant/share/data.csv'

echo 'Link delay,Window size,Bandwidth' > data.csv

status_path='/home/vagrant/dce/source/ns-3-dce/files-1/var/log/*/status'
stdout_path='/home/vagrant/dce/source/ns-3-dce/files-1/var/log/*/stdout'

max_progress=$(( ( ($LINK_DELAY_MAX - $LINK_DELAY_MIN) / $LINK_DELAY_STEP + 1) * ( ($WINDOW_SIZE_MAX - $WINDOW_SIZE_MIN) / $WINDOW_SIZE_STEP + 1)  ))
progress=0

echo "Perfomance test started. Progress:"
for ld in $(seq $LINK_DELAY_MIN $LINK_DELAY_STEP $LINK_DELAY_MAX)
do
	for ws in $(seq $WINDOW_SIZE_MIN $WINDOW_SIZE_STEP $WINDOW_SIZE_MAX)
	do
		(cd /home/vagrant/dce/source/ns-3-dce; ./waf --run "dce-iperf --window-size=${ws}K --link-delay=${ld}ms") > /dev/null 2>/dev/null
		status=`cat $status_path | tail -n1 | awk -F "--> " '{print $2}'`
		bw="Nan"
		case $status in
			"Exit (0)"*)
				bw=`cat $stdout_path | tail -n1 | awk '{print $7}'`
				;;
			"Never ended."*) 
				;;
			*) 
				echo "Unknown exit status on data ld=$ld ws=$ws" >> error.log
				;;
		esac
		echo "${ld},${ws},${bw}" >> data.csv
		
		(( ++progress ))
		percent=$(( (100 * $progress) / $max_progress ))
		count_hash=$(($percent / 2))
		count_space=$((50 - $count_hash))
		count_dots=$((progress % 4))
		count_dot_space=$((3 - count_dots))
		hashes=`printf %${count_hash}s |tr ' ' '#'`
		space=`printf %${count_space}s`
		dots=`printf %${count_dots}s |tr ' ' '.'`
		dot_space=`printf %${count_space}s`
		
		echo -ne "[${hashes}${space}] (${percent}%) ${dots}${dot_space}\r"
		
	done
done

echo "[${hashes}${space}] (${percent}%) ${dots}${dot_space}"

echo "Test done. Aborting."

mv data.csv $out_file
