#!/bin/bash
# Script to run configure and compile with Intel 18 on Stampede2

# Load system modules
module reset # Should include intel/18.0.2 impi/18.0.2
module load netcdf/4.6.2 pnetcdf/1.11.0 phdf5/1.10.4

export WRF_SRC_ROOT_DIR=~/WRF_Benchmarking/Docker-WRF-3.8.1-Fitch/Stampede2/Intel/WRFV3/
cd $WRF_SRC_ROOT_DIR

export DIR=${WRF_SRC_ROOT_DIR}../LIBRARIES
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

export PATH=${TACC_NETCDF_BIN}:${TACC_PNETCDF_BIN}:$PATH
export NETCDF=${TACC_NETCDF_DIR}
export PNETCDF=${TACC_PNETCDF_DIR}
export PHDF5=${TACC_HDF5_DIR} 

export WRFIO_NCD_LARGE_FILE_SUPPORT=1
export WRF_EM_CORE=1
export KMP_STACKSIZE=512m

#export LDFLAGS="-lm -lnetcdff -lnetcdf -L${TACC_NETCDF_LIB}"
export LDFLAGS="-lm -lnetcdff -lnetcdf -L${TACC_PNETCDF_LIB}"

# Copy in patches
cp ../../../patches/wrf_bug_fixes/Registry.EM_COMMON ./Registry/
cp ../../../patches/wrf_bug_fixes/module_radiation_driver.F ./phys/
cp ../../../patches/wrf_bug_fixes/module_cu_g3.F ./phys/

# Fresh config
./clean -a

# input 21 (icc/ifort) and 1 (basic nesting) to configure script
echo '20\n1\n' | ./configure

# modifications for Intel 
sed -i -e 's/-openmp/-qopenmp/' ./configure.wrf
sed -i -e 's/-lpnetcdf/-L${TACC_PNETCDF_LIB} -lnetcdff -lnetcdf /' ./configure.wrf
sed -i -e 's/gcc/icc/' ./configure.wrf

# NetCDF linking needed for Stampede2
read -r -d '' var<<"EOF"
-DNETCDF -DPNETCDF -I${WRF_SRC_ROOT_DIR}/external/io_netcdf -I${NETCDFPATH}/include -L${WRF_SRC_ROOT_DIR}external/io_netcdf -lwrfio_nf -L${TACC_NETCDF_LIB} -lnetcdff -lnetcdf -L${WRF_SRC_ROOT_DIR}external/io_pnetcdf -lwrfio_pnf -L${TACC_PNETCDF_LIB} -lpnetcdf
EOF

#sed -i -e ''95's@$@'" $var"'@' configure.wrf
awk -v mytext=" ${var}" '/^NETCDF4_DEP_LIB / {$0=$0mytext} 1' configure.wrf > temp && mv temp configure.wrf

# Compile
#time ./compile -j 2 em_real >& compile_em_real.log
time ./compile -j 8 em_real >& compile_em_real.log

