#!/bin/bash
# Script to compile WRF on Stampede2 with loaded modules:

# Load system modules
module purge
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

export PATH=$PATH:${TACC_NETCDF_BIN}:${TACC_PNETCDF_BIN}:$IFC_BIN
export NETCDF=${TACC_NETCDF_DIR}
export PNETCDF=${TACC_PNETCDF_DIR}
export PHDF5=${TACC_HDF5_DIR} 

export WRFIO_NCD_LARGE_FILE_SUPPORT=1
export WRF_EM_CORE=1

#export LDFLAGS="-lm -lnetcdff -lnetcdf -L${TACC_NETCDF_LIB}"
export LDFLAGS="-lm -lnetcdff -lnetcdf -L${TACC_PNETCDF_LIB}"

cd ~/WRF_Benchmarking/Docker-WRF-3.8.1-Fitch/Stampede2/Intel/WRFV3

# Clean compile
./clean

# Compile
time ./compile -j 8 em_real >& compile_em_real.log

# Run the following command on Stampede2 to submit a job to run this compilation on 20 cores
# Will need to add the -A flag with allocation number 
# sbatch -p development -n 2 -N 1 -t 02:00:00 ./my_compile.sh

