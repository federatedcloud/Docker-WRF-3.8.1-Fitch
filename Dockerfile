FROM ubuntu:20.04
# This Dockerfile is based on NCAR-WRF
# https://github.com/NCAR/container-wrf
# https://www.ral.ucar.edu/projects/ncar-docker-wrf

MAINTAINER Bennett Wineholt <bmw39@cornell.edu>
MAINTAINER Peter Vaillancourt <pzv2@cornell.edu>

## Use bash for compile
## This Dockerfile compiles WRF from source during "docker build" step
SHELL ["/bin/bash","-c"]
ENV WRF_VERSION 3.8.1

## Ensuring only root user to prepare for singularity conversion
ARG USER=root
USER root

ARG DEBIAN_FRONTEND=noninteractive
#ARG HOME=/home/${USER}
ARG HOME=/root

## create local relative directory patches with any WRF source changes
#COPY patches /wrf/patches
## copy in a couple custom scripts
RUN mkdir -p /wrf
COPY docker-clean /wrf
RUN chmod +x /wrf/docker-clean
COPY run-wrf /wrf
RUN chmod +x /wrf/run-wrf
RUN chown -R ${USER}:${USER} /wrf

RUN apt-get update -yq

## for libjasper-dev
RUN apt-get install -y software-properties-common
RUN add-apt-repository "deb http://security.ubuntu.com/ubuntu xenial-security main"

RUN apt-get install --no-install-recommends -yq libjasper-dev

RUN apt-get install --no-install-recommends -yq curl file gcc gfortran g++ \
    gcc-multilib g++-multilib libpng-dev hostname \
    m4 make ncl-ncarg perl tar tcsh time wget zlib1g-dev vim

## now get 3rd party EPEL builds of netcdf and openmpi dependencies
RUN add-apt-repository "deb http://us.archive.ubuntu.com/ubuntu xenial universe"
RUN apt-get install -y libnetcdf-dev libnetcdf11 libnetcdff-dev netcdf-bin \
    libpnetcdf-dev libpnetcdf0d pnetcdf-bin libhdf5-openmpi-dev
RUN apt-get install -y openmpi-bin libopenmpi-dev mpi-default-bin mpi-default-dev

WORKDIR /wrf

## Download original sources
## create local relative directory patches with any WRF source changes
COPY patches /wrf/patches
RUN curl -SL http://www2.mmm.ucar.edu/wrf/src/WRFV$WRF_VERSION.TAR.gz | tar zxC /wrf \
    && curl -SL http://www2.mmm.ucar.edu/wrf/src/WPSV$WRF_VERSION.TAR.gz | tar zxC /wrf
    ## !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    ## These may not be necessary in the next WRF_VERSION after 3.8.1. - need to check  !!!!!!:

RUN cp patches/wrf_bug_fixes/module_radiation_driver.F /wrf/WRFV3/phys/ && \
    cp patches/wrf_bug_fixes/Registry.EM_COMMON /wrf/WRFV3/Registry/ && \
    cp patches/wrf_bug_fixes/Registry.NMM /wrf/WRFV3/Registry/ && \
    cp patches/wrf_bug_fixes/module_pbl_driver.F /wrf/WRFV3/phys/ && \
    cp patches/wrf_bug_fixes/module_wind_fitch.F /wrf/WRFV3/phys/ && \
    cp patches/wrf_bug_fixes/module_radiation_driver.F /wrf/WRFV3/phys/ && \
    cp patches/wrf_bug_fixes/module_cu_g3.F /wrf/WRFV3/phys/ && \
    cp patches/wrf_bug_fixes/Config_new.pl /wrf/WRFV3/arch/ && \
    cp patches/wrf_bug_fixes/module_initialize_real.F /wrf/WRFV3/dyn_em/

## Set environment for interactive container shells
RUN echo export LDFLAGS="-lm -lnetcdff -lnetcdf -lpnetcdf" >> /etc/bashrc && \
    echo export PHDF5=/usr/include/hdf5/openmpi >> /etc/bashrc && \
    echo export NETCDF=/wrf/netcdf_links >> /etc/bashrc && \
    echo export PNETCDF=/wrf/pnetcdf_links >> /etc/bashrc && \
    echo export JASPERINC=/usr/include/jasper/ >> /etc/bashrc && \
    echo export JASPERLIB=/usr/lib/ >> /etc/bashrc && \
    echo export WRFIO_NCD_LARGE_FILE_SUPPORT=1 >> /etc/bashrc && \
    echo export WRF_EM_CORE=1 >> /etc/bashrc && \
    echo export OMP_STACK_SIZE=64000000 >> /etc/bashrc && \
    echo export LD_LIBRARY_PATH="/usr/lib/openmpi/lib" >> /etc/bashrc && \
    echo 'setenv LDFLAGS "-lm -lnetcdff -lnetcdf -lpnetcdf"' >> /etc/csh.cshrc && \
    echo setenv PHDF5 "/usr/include/hdf5/openmpi" >> /etc/csh.cshrc && \
    echo setenv NETCDF "/wrf/netcdf_links" >> /etc/csh.cshrc && \
    echo setenv PNETCDF "/wrf/pnetcdf_links" >> /etc/csh.cshrc && \
    echo setenv JASPERINC "/usr/include/jasper/" >> /etc/csh.cshrc && \
    echo setenv JASPERLIB "/usr/lib/" >> /etc/csh.cshrc && \
    echo setenv WRFIO_NCD_LARGE_FILE_SUPPORT 1 >> /etc/csh.cshrc && \
    echo setenv WRF_EM_CORE 1 >> /etc/csh.cshrc && \
    echo setenv OMP_STACK_SIZE 64000000 >> /etc/csh.cshrc && \
    echo setenv LD_LIBRARY_PATH "/usr/lib/openmpi/lib" >> /etc/csh.cshrc

## test tcsh env loading
RUN /bin/tcsh -c "env"
RUN /bin/tcsh -c "cat /etc/csh.cshrc"
RUN /bin/bash -c "echo 'bash env :' ;  env"
RUN /bin/bash -c "cat /etc/bashrc"

## Build WRF first
RUN mkdir -p netcdf_links/include && mkdir -p pnetcdf_links/include && \
    ln -sf /usr/include/pnetcdf* pnetcdf_links/include/ && \
    ln -sf /usr/include/netcdf* netcdf_links/include/ && \
    ln -sf /usr/include/openmpi/ netcdf_links/include && \
    ln -sf /usr/lib/openmpi/lib netcdf_links/lib

RUN export LDFLAGS="-lm -lnetcdff -lnetcdf -lpnetcdf" && \
    export PHDF5=/usr/include/hdf5/openmpi && \
    export NETCDF=/wrf/netcdf_links && \
    export PNETCDF=/wrf/pnetcdf_links && \
    export JASPERINC=/usr/include/jasper/ && \
    export JASPERLIB=/usr/lib/ && \
    export WRFIO_NCD_LARGE_FILE_SUPPORT=1 && \
    export WRF_EM_CORE=1 && \
    export OMP_STACK_SIZE=64000000 && \
    cd /wrf/WRFV3  && \
    ./clean -a && \
# input 34 (gcc/gfortran) and 1 (basic nesting) to configure script
    echo '34\n1\n' | ./configure && \
# # input 34 (gcc/gfortran) and 3 (vortex following) to configure script
#     echo '34\n3\n' | ./configure && \
    sed -i -e '/^DM_CC/ s/$/ -DMPI2_SUPPORT/' ./configure.wrf && \
    sed -i -e 's/-lpnetcdf/-lpnetcdf -lnetcdff -lnetcdf /' ./configure.wrf && \
    ./compile em_real >& compile_em_real.log

## Build WPS second
RUN export LDFLAGS="-lm -lnetcdff -lnetcdf -lpnetcdf" && \
    export PHDF5=/usr/include/hdf5/openmpi && \
    export NETCDF=/wrf/netcdf_links && \
    export PNETCDF=/wrf/pnetcdf_links && \
    export JASPERINC=/usr/include/jasper/ && \
    export JASPERLIB=/usr/lib/ && \
    export WRFIO_NCD_LARGE_FILE_SUPPORT=1 && \
    export WRF_EM_CORE=1 && \
    export OMP_STACK_SIZE=64000000 && \
    cd /wrf/WPS && \
# input 1 to configure script
    echo '1\n' | ./configure -d && \
    sed -i -e 's/-L$(NETCDF)\/lib/-L$(NETCDF)\/lib -lnetcdff -lnetcdf -L$(PNETCDF)\/lib -lpnetcdf /' ./configure.wps && \
    ./compile >& compile_wps.log

ENV LD_LIBRARY_PATH /usr/lib/openmpi/lib

## copy in a couple custom scripts
#COPY docker-clean /wrf
#RUN chmod +x /wrf/docker-clean
#RUN ./docker-clean
#COPY run-wrf /wrf
#RUN chmod +x /wrf/run-wrf && 

RUN chown -R ${USER}:${USER} /wrf

## confirm compilation success through executable presence TODO add other exe checks
RUN ls -al /wrf/WRFV3/main/real.exe || true
RUN ls -al /wrf/WRFV3/main/wrf.exe || true
RUN ls -al /wrf/WRFV3/main/ndown.exe || true
RUN ls -al /wrf/WRFV3/main/tc.exe || true

#EXPOSE 22
#CMD ["/usr/sbin/sshd", "-D"]

