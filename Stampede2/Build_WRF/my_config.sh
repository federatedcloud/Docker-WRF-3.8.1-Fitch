#!/bin/bash

# Script to run ./configure on Stampede2 with loaded modules:
module load gcc/7.1.0
module load impi/18.0.2
module load parallel-netcdf/4.6.2
module load phdf5/1.10.4

export DIR=~$USER/WRF_Benchmarking/Docker-WRF-3.8.1-Fitch/Stampede2/Build_WRF/LIBRARIES
export CC=gcc
export CXX=g++
export FC=gfortran
export FCFLAGS=-m64
export F77=gfortran
export FFLAGS=-m64
export JASPERLIB=$DIR/grib2/lib
export JASPERINC=$DIR/grib2/include
export LDFLAGS=-L$DIR/grib2/lib
export CPPFLAGS=-I$DIR/grib2/include

export PATH=$PATH:${TACC_NETCDF_BIN}:$DIR/mpich/bin
export NETCDF=${TACC_NETCDF_DIR}
#export PNETCDF=${TACC_NETCDF_DIR}
export PHDF5=${TACC_HDF5_DIR} 

cd ~/WRF_Benchmarking/Docker-WRF-3.8.1-Fitch/Stampede2/Build_WRF/WRFV3

# Copy in patches
cp ../../../patches/wrf_bug_fixes/Registry.EM_COMMON ./Registry/
cp ../../../patches/wrf_bug_fixes/module_radiation_driver.F ./phys/
cp ../../../patches/wrf_bug_fixes/module_cu_g3.F ./phys/

# Fresh config
./clean -a

# input 34 (gcc/gfortran) and 1 (basic nesting) to configure script
echo '34\n1\n' | ./configure

# modifications for GNU
sed -i -e '/^DM_CC/ s/$/ -DMPI2_SUPPORT/' ./configure.wrf
sed -i -e 's/-lpnetcdf/-L${TACC_NETCDF_LIB} -lnetcdff -lnetcdf /' ./configure.wrf

