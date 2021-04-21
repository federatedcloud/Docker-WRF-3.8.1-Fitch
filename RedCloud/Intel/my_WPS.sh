#!/bin/bash
# Script to configure and compile WPS on Stampede2

# Load system modules
module load intel/19.1.1 mvapich2/2.3.5 pnetcdf/1.8.1 phdf5/1.8.16 parallel-netcdf/4.3.3.1

cd ~/WRF_Benchmarking/Docker-WRF-3.8.1-Fitch/Stampede2/Intel/WRFV3

export DIR=~/WRF_Benchmarking/Docker-WRF-3.8.1-Fitch/Stampede2/Intel/LIBRARIES
export CC=icc
export CXX=icpc
export FC=ifort
export FCFLAGS=-m64
export F77=ifort
export FFLAGS=-m64
export JASPERLIB=$DIR/grib2/lib
export JASPERINC=$DIR/grib2/include
export LDFLAGS=-L$DIR/grib2/lib
export CPPFLAGS=-I$DIR/grib2/include

export PATH=$PATH:${TACC_NETCDF_BIN}
export NETCDF=${TACC_NETCDF_DIR}
export PNETCDF=${TACC_PNETCDF_DIR}
export PHDF5=${TACC_HDF5_DIR} 

export WRFIO_NCD_LARGE_FILE_SUPPORT=1
export WRF_EM_CORE=1

export LDFLAGS="-lm -lnetcdff -lnetcdf -L${TACC_NETCDF_LIB}"

cd ~/WRF_Benchmarking/Docker-WRF-3.8.1-Fitch/Stampede2/Intel/WPS

# Fresh config
./clean -a

# input 34 (gcc/gfortran) and 1 (basic nesting) to configure script
echo '1\n' | ./configure -d 
sed -i -e 's/-L$(NETCDF)\/lib/-L$(NETCDF)\/lib -lnetcdff -lnetcdf -L$(PNETCDF)\/lib -lpnetcdf /' ./configure.wps
#sed -i -e 's/-L$(NETCDF)\/lib/-L$(NETCDF)\/lib -lnetcdff -lnetcdf /' ./configure.wps

./compile >& log.compile

