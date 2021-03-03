# Docker-WRF-3.8.1-Fitch
A public Docker container for WRF 3.8.1 with Fitch patches.

Docker image: [Docker Hub](https://hub.docker.com/repository/docker/cornellcac/wrf)

Singularity image: [![https://www.singularity-hub.org/static/img/hosted-singularity--hub-%23e32929.svg](https://www.singularity-hub.org/static/img/hosted-singularity--hub-%23e32929.svg)](https://singularity-hub.org/collections/5227)

# Build
The Docker container can be built using the script [`docker-build.sh`](https://github.com/federatedcloud/Docker-WRF-3.8.1-Fitch/blob/main/docker-build.sh),
which will produce an output file named `build_output.txt` (included in the 
[`.gitignore`](https://github.com/federatedcloud/Docker-WRF-3.8.1-Fitch/blob/main/.gitignore)).
The build will take some time, so it is recommended to use a terminal multiplexer, such as tmux.
One can view the full output at any time using a text editor to open `build_output.txt`.
To determine what step the build it is at, one can do:

    cat build_output.txt | grep Step | tail -n 1

This will print the current command Docker is executing to build the container.
To view Docker build errors, try:

    cat build_output.txt | grep ERROR

This is actually the last command in the `docker-build.sh` script, so Docker build
errors will be listed upon completion.  If there are no errors listed the container
was built successfully.  Code and dependencies should be checked independently of
a Docker build error list.

## Patches
Since there are some [known problems with WRF 3.8.1](https://www2.mmm.ucar.edu/wrf/users/wrfv3.8/known-prob-3.8.1.html),
we have implemented the following patches provided by the WRF Users page:
* [`module_radiation_driver.F`](https://www2.mmm.ucar.edu/wrf/src/fix/module_radiation_driver.F.fix-for-v3.8.1.tar.gz)
* [`module_cu_g3.F`](https://www2.mmm.ucar.edu/wrf/src/fix/module_cu_g3_random_seed_fix.F.gz)
* [`Registry.EM_COMMON`](https://www2.mmm.ucar.edu/wrf/src/fix/Registry.EM_COMMON.v381.tar.gz)

All of these patches, as well as our custom patches, are included in the repository.

## Compiling
WRF and WPS compilation is performed in bash.  Please see the [Dockerfile](https://github.com/federatedcloud/Docker-WRF-3.8.1-Fitch/blob/main/Dockerfile)
for full commands.

