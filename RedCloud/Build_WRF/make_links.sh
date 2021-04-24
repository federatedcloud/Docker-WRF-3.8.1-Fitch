#!/bin/bash
  
DATA_LOCATION=~/WRF_Benchmarking/data/NY_Lease_Case/WRF
WRF_RUN_LOCATION=~/WRF_Benchmarking/Docker-WRF-3.8.1-Fitch/Stampede2/Build_WRF/WRFV3/run

[ -f list_of_files ] || {
  echo "please make list of files"
  exit 1
}

for realfile in $( cat list_of_files ); do
    ## For Debugging, uncomment the next line
    #echo "ln -s ${WRF_RUN_LOCATION}/"$realfile" ${DATA_LOCATION}/$(basename $realfile)"
    
    ln -s ${WRF_RUN_LOCATION}/"$realfile" ${DATA_LOCATION}/$(basename $realfile)
done
