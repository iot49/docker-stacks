<!---
[![Discourse badge](https://img.shields.io/discourse/https/discourse.jupyter.org/users.svg?color=%23f37626)](https://discourse.jupyter.org/c/questions "Jupyter Discourse Q&A")
[![Read the Docs badge](https://img.shields.io/readthedocs/jupyter-docker-stacks.svg)](https://jupyter-docker-stacks.readthedocs.io/en/latest/ "Documentation build status")
[![DockerHub badge](https://images.microbadger.com/badges/version/jupyter/base-notebook.svg)](https://microbadger.com/images/jupyter/base-notebook "Recent tag/version of jupyter/base-notebook")
[![Binder badget](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/jupyter/docker-stacks/master?filepath=README.ipynb "Launch a jupyter/base-notebook container on mybinder.org")
--->

# Jupyter Multi-Architecture Docker Stacks

The official Jupyter [Docker images](https://hub.docker.com/u/jupyter)
do not support ARM processors.

This fork is an attempt to port a subset of the official stacks to a multi-architecture docker configuration. The main obstacle is the lack of good support for Conda on ARM.

If you do not need to run notebook servers on ARM computers, use the [Official Jupyter Docker Stacks](https://jupyter-docker-stacks.readthedocs.io/en/latest/).

## Supported Stacks

- base-notebook
- minimal-notebook
- scipy-notebook

## Quick Start

```bash
docker -p 8888:8888 ttmetro/base-notebook
```

### docker-compose

```
version: "3"

services:

    iot49:
        image: ttmetro/base-notebook
        container_name: jupyter-notebook
        user: root
        environment:
            - JUPYTER_ENABLE_LAB=yes
            - GRANT_SUDO=yes
            - NB_UID=1000
        volumes:
            - <folder on host where notebooks will be stored>:/home/jovyan/work
        ports:
            - "8888:8888"
        restart: on-failure

```

## Limitations

- No version control for installed libraries. Library versions change from build to build and may differ for different architectures of the same image.
- Some packages included with the [Official Jupyter Docker Stacks](https://jupyter-docker-stacks.readthedocs.io/en/latest/) are missing. Either install from the command line or raise an issue.
- Run `pip list` and `apt list` from the command line for a listing of installed packages and their versions.
- Automated tests performed only on the `linux/amd64` image (presently disabled, need updating). 
- The multi-architecture image is pushed to DockerHub without automated tests.
- `buildx` uses the `qemu` emulator and is quite slow (taking hours to build the docker images). To speed things up, limit the build to just the images that require updating. E.g. to just rebuild `scipy-notebook`, set `ALL_STACKS=scipy-notebook` in the `Makefile`.
- Presently only images for `linux/amd64` and `linux/arm/v7`. Change the `PLATFORMS` variable in the `Makefile` to add other architectures.

## Resources

- [Issue Tracker on GitHub](https://github.com/iot49/docker-stacks)
- [Jupyter Discourse Q&A](https://discourse.jupyter.org/c/questions)
- [Jupyter Website](https://jupyter.org)
- [Images on DockerHub](https://hub.docker.com/u/ttmetro)
