#!/bin/bash
# Script to configure and compile WRF v3.8.1 using Intel 2021.2.0 on CAC RedCloud

# Load system modules
# in Docker

COMPILE_DIR=/mnt/RedCloud/Intel/WRFV3
#Docker-WRF-3.8.1-Fitch/RedCloud/Intel/WRFV3

export DIR=/mnt/RedCloud/Intel/LIBRARIES
export CC=icc
export CXX=icpc
export FC=ifort
export FCFLAGS=-m64
export F77=ifort
export FFLAGS=-m64
#export JASPERLIB=$DIR/grib2/lib
#export JASPERINC=$DIR/grib2/include
export LDFLAGS=-L$DIR/grib2/lib
export CPPFLAGS=-I$DIR/grib2/include

#export PATH=$PATH:${TACC_NETCDF_BIN}:${TACC_PNETCDF_BIN}
#export PATH=$PATH:${TACC_NETCDF_BIN}
export NETCDF=$DIR/netcdf
# TODO compile pnetcdf
#export PNETCDF=${TACC_PNETCDF_DIR}
#export PHDF5=${TACC_HDF5_DIR}

export WRFIO_NCD_LARGE_FILE_SUPPORT=1
export WRF_EM_CORE=1
export OMP_STACK_SIZE=64000000

#export LDFLAGS="-lm -lnetcdff -lnetcdf -L${TACC_NETCDF_LIB}"
##export LDFLAGS="-lm -lnetcdff -lnetcdf -L${TACC_PNETCDF_LIB}"
export LDFLAGS="-lm -lnetcdff -lnetcdf" # XXX

# Copy in patches
cp ../../../patches/wrf_bug_fixes/Registry.EM_COMMON ./Registry/
cp ../../../patches/wrf_bug_fixes/module_radiation_driver.F ./phys/
cp ../../../patches/wrf_bug_fixes/module_cu_g3.F ./phys/

# Fresh config
./clean -a

# 20 intel dmpar
# input 34 (gcc/gfortran) and 1 (basic nesting) to configure script
echo '20\n1\n' | ./configure

# post configure modifications for Intel
sed -i -e 's/-openmp/-qopenmp/' ./configure.wrf
sed -i -e 's/-lpnetcdf/-L${TACC_PNETCDF_LIB} -lnetcdff -lnetcdf /' ./configure.wrf
sed -i -e 's/gcc/icc/' ./configure.wrf

# Compile
time ./compile -j 2 em_real >& compile_em_real.log

