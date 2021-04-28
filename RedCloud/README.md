# Build and run Intel compiled WRF v3.8.1 in Docker on CAC private Red Cloud

## Status
development in progress, really just begun


## Requirements
CAC Red Cloud account or similar public cloud host or local machine

Ubuntu 20.04 host

Docker CE 20.10.5+

Checkout this repository from public Github


## Development Usage
filling in code checkout location for development

this is the variable `CODE_CHECKOUT` below

```
docker run -v $CODE_CHECKOUT:/mnt --name diw intel/oneapi-hpckit@sha256:cd22c32dd04beab2ae21eb8f13402a79a7c2a91b2afc787905230099160c2bbe sleep infinity &

docker exec -it diw bash

sudo apt update

sudo apt install vim wget unzip

cd /mnt/RedCloud/Intel/LIBRARIES/

./install_lib.sh

#? apt install -y intel-hpckit
```
-> work in progress


## Todo
run intel oneapi docker container on single node mounting code checkout

attempt build and run, iterating with commits

add a small WRF test with public data and job config

build in dockerfile, test in container startup cmd


## References
[https://github.com/federatedcloud/Docker-WRF-3.8.1-Fitch]

[https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compilation_tutorial.php]
