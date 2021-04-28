#!/bin/bash
# Script for installing the libraries needed before WRF and WPS compile
# Status : development in progress

# Load system modules (copied from Stampede2)
#module load intel/19.1.1 mvapich2/2.3.5 pnetcdf/1.8.1 phdf5/1.8.16 parallel-netcdf/4.3.3.1

# todo simplify install available packages from apt

# test expected code directory exists else exit
set -e
#[-d /mnt/Docker-WRF-3.8.1-Fitch/RedCloud/Intel/LIBRARIES]
[ -d /mnt/RedCloud/Intel/LIBRARIES ]
set +e

cd /mnt/RedCloud/Intel/LIBRARIES

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

# NOTE: for each of the following libraries, the first wget pulls from the NCAR compiling WRF
#       tutorial here https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compilation_tutorial.php#STEP2
#       and the second link is a static link of the same version from the respective software 
#       source (same version)

## NetCDF 4.1.3
# todo 4.6.2 , check other library versions
# idempotent install checking if binary was compiled in expected location
[ -f netcdf-4.1.3/fortran/netcdf.inc ] || {
  echo "fetching netcdf source"
  wget https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/netcdf-4.1.3.tar.gz
  ##wget ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-4.1.3.tar.gz
  #
  tar -xzvf netcdf-4.1.3.tar.gz
  cd netcdf-4.1.3
  ./configure --prefix=$DIR/netcdf --disable-dap --disable-netcdf-4 --disable-shared
  echo "compiling netcdf"
  set -ex
  make
  make install
  set +ex
  export PATH=$DIR/netcdf/bin:$PATH
  # todo insert into bashrc and compile script
  export NETCDF=$DIR/netcdf
  cd ..
}

echo 'after netcdf'

# expect
#find netcdf-4.1.3  -name "*.inc"
#netcdf-4.1.3/nf_test/tests.inc
#netcdf-4.1.3/fortran/netcdf2.inc
#netcdf-4.1.3/fortran/nfconfig.inc
#netcdf-4.1.3/fortran/netcdf.inc
#netcdf-4.1.3/fortran/netcdf3.inc
#netcdf-4.1.3/fortran/nfconfig1.inc
#netcdf-4.1.3/fortran/netcdf4.inc
#netcdf-4.1.3/libcf/nfconfig.inc

# Intel Oneapi HPCKIT intel MPI included

# zlib 1.2.7
#wget https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/zlib-1.2.7.tar.gz

# todo idempotent
echo "fecthing zlib"
wget https://zlib.net/fossils/zlib-1.2.7.tar.gz
tar -xzvf zlib-1.2.7.tar.gz
cd zlib-1.2.7
echo "building zlib"
set -e
./configure --prefix=$DIR/grib2
make
make install
set +e
cd ..
echo "built zlib"

# libpng 1.2.50
#wget https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/libpng-1.2.50.tar.gz
echo "fetching libpng"
wget https://sourceforge.net/projects/libpng/files/libpng12/older-releases/1.2.50/libpng-1.2.50.tar.gz

tar -xzvf libpng-1.2.50.tar.gz
cd libpng-1.2.50
echo "building libpng"
./configure --prefix=$DIR/grib2
make
make install
cd ..
echo "built libpng"

# Jasper 1.900.1
#wget https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/jasper-1.900.1.tar.gz
#tar xzvf jasper-1.900.1.tar.gz

## do we need jasper for WRF?
#
##wget https://www.ece.uvic.ca/~frodo/jasper/software/jasper-1.900.1.zip
##unzip jasper-1.900.1.zip
##
##cd jasper-1.900.1
##./configure --prefix=$DIR/grib2
##make
##make install
##cd ..

echo "installed all required libraries"

exit 0

