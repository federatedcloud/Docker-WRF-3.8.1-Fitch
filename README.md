# Docker-WRF-3.8.1-Fitch
A public Docker container for WRF 3.8.1 with Fitch patch

# Build
The Docker container can be built using the script `docker-build.sh`, which will
produce an output file named `build_output.txt`.  The build will take some time,
so it is recommended to use a terminal multiplexer, such as tmux.  One can view
the full output at any time using a text editor to open `build_output.txt`.  To
determine what step the build it is at, one can do:

    cat build_output.txt | grep Step | tail -n 1

This will print the current command Docker is executing to build the container.
To view Docker build errors, try:

    cat build_output.txt | grep ERROR

This is actually the last command in the `docker-build.sh` script, so Docker build
errors will be listed upon completion.  If there are no errors listed the container
was built successfully.  Code and dependencies should be checked independently of
a Docker build error list.

