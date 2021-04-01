#!/bin/bash

# Load system modules
module load intel/19.1.1 mvapich2/2.3.5 pnetcdf/1.8.1 phdf5/1.8.16

# Script for installing the libraries needed before WRF and WPS compile

cd ~/WRF_Benchmarking/Docker-WRF-3.8.1-Fitch/Stampede2/Intel/LIBRARIES

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

# NOTE: for each of the following libraries, the first wget pulls from the NCAR compiling WRF
#       tutorial here https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compilation_tutorial.php#STEP2
#       and the second link is a static link of the same version from the respective software 
#       source (same version)

## NetCDF 4.1.3
#wget https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/netcdf-4.1.3.tar.gz
##wget ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-4.1.3.tar.gz
#
#tar -xzvf netcdf-4.1.3.tar.gz
#cd netcdf-4.1.3
#./configure --prefix=$DIR/netcdf --disable-dap
#     --disable-netcdf-4 --disable-shared
#make
#make install
#export PATH=$DIR/netcdf/bin:$PATH
#export NETCDF=$DIR/netcdf
#cd ..

# We're using the system NetCDF module
export NETCDF=${TACC_NETCDF_DIR}

## mpich
##wget https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/mpich-3.0.4.tar.gz
#
#wget https://www.mpich.org/static/downloads/3.0.4/mpich-3.0.4.tar.gz
#
#tar -xzvf mpich-3.0.4.tar.gz
#cd mpich-3.0.4
#./configure --prefix=$DIR/mpich
#make
#make install
#export PATH=$DIR/mpich/bin:$PATH
#cd ..

# We're using the system MVAPICH2 implementation

# zlib 1.2.7
#wget https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/zlib-1.2.7.tar.gz

wget https://zlib.net/fossils/zlib-1.2.7.tar.gz

tar -xzvf zlib-1.2.7.tar.gz
cd zlib-1.2.7
./configure --prefix=$DIR/grib2
make
make install
cd ..

# libpng 1.2.50
#wget https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/libpng-1.2.50.tar.gz

wget https://sourceforge.net/projects/libpng/files/libpng12/older-releases/1.2.50/libpng-1.2.50.tar.gz

tar -xzvf libpng-1.2.50.tar.gz
cd libpng-1.2.50
./configure --prefix=$DIR/grib2
make
make install
cd ..

# Jasper 1.900.1
#wget https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/jasper-1.900.1.tar.gz
#tar xzvf jasper-1.900.1.tar.gz

wget https://www.ece.uvic.ca/~frodo/jasper/software/jasper-1.900.1.zip
unzip jasper-1.900.1.zip

cd jasper-1.900.1
./configure --prefix=$DIR/grib2
make
make install
cd ..


