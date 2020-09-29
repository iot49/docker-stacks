<!---
[![Discourse badge](https://img.shields.io/discourse/https/discourse.jupyter.org/users.svg?color=%23f37626)](https://discourse.jupyter.org/c/questions "Jupyter Discourse Q&A")
[![Read the Docs badge](https://img.shields.io/readthedocs/jupyter-docker-stacks.svg)](https://jupyter-docker-stacks.readthedocs.io/en/latest/ "Documentation build status")
[![DockerHub badge](https://images.microbadger.com/badges/version/jupyter/base-notebook.svg)](https://microbadger.com/images/jupyter/base-notebook "Recent tag/version of jupyter/base-notebook")
[![Binder badge](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/jupyter/docker-stacks/master?filepath=README.ipynb "Launch a jupyter/base-notebook container on mybinder.org")
--->

# Jupyter Multi-Architecture Docker Stacks

The official Jupyter [Docker images](https://hub.docker.com/u/jupyter)
do not support ARM processors.

This fork is an attempt to port a subset of the official stacks to a multi-architecture docker configuration. The main obstacle is the lack of good support for Conda on ARM.

If you do not need to run notebook servers on ARM computers, use the [Official Jupyter Docker Stacks](https://jupyter-docker-stacks.readthedocs.io/en/latest/).

## Supported Stacks

- base-notebook *(build time: 20m)*
- minimal-notebook  *(build time: 15m)*
- *scipy-numpy-notebook (build time: 2h 20m)*
    - minimal-notebook plus `numpy, scipy`
- *scipy-matplotlib-notebook (build time: 30m)*
    - scipy-numpy-notebook plus `matplotlib`
- scipy-notebook *(build time: 2h)*
    - scipy-matplotlib-notebook plus `pandas, sympy`
- iot-notebook *(build time: 30m):* scipy-notebook plus
    - [iot-kernel](https://github.com/iot49/iot-kernel)
    - [javascript and typescript kernels](https://github.com/yunabe/tslab)

Some libraries that are included in the "official stacks" are missing. Run `pip list -v` and `apt list` from the command line for a listing of installed packages and their versions.

## Quick Start

From the console:

```bash
docker -p 8888:8888 -e JUPYTER_ENABLE_LAB=yes -v <...>:/home/jovyan ttmetro/scipy-notebook
```

Replace `<...>` with the path to the directory where notebooks and the jupyter customizations (e.g. additional kernels and libraries) will be stored.

**Note:** `/home/jovyan` is also used to store system files (e.g. custom `pip` installs in `.local`, cache files in `.cache`, etc). Issues may arise if these files are shared between different systems (e.g. the same host folders is mounted into different Jupyter Notebook Servers). If this is a concern, mount the host volume to `/home/jovyan/work` instead.

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
            - <...>:/home/jovyan
        ports:
            - "8888:8888"
        restart: on-failure
```

The combination of the `user: root` and `GRANT_SUDO=yes` grant password less `sudo` from the console. Remove if not required.

## Customizations

It is possible to install additional features from within a running docker container (using e.g. the Terminal).

### Pip

The additional content can be either installed into the container or on the host (if a volume is mounted on `/home/jovyan`). For the latter case, specify the `--user` option with `pip`.

```
pip install [--user] <package>
```

- with `--user`, installs to `/home/jovyan/.local`
- without the `--user` flag, installed packages go to `/usr/local`
- `pip list -v` shows package folder locations

### Kernels

Check the kernel documentation for installation instructions. E.g.

```
pip install --user iot-kernel
python -m iot_kernel.install --user`
jupyter kernelspec list
```

A browser page refresh may be needed before new kernels are shown in the Launcher.

### Jupyter Lab Extensions

These can be installed/removed from the Jupyter Lab Extension Manager.

## Limitations

- No version control for installed libraries. Library versions change from build to build and may differ for different architectures of the same image.
- Some packages included with the [Official Jupyter Docker Stacks](https://jupyter-docker-stacks.readthedocs.io/en/latest/) are missing. Additional content can be installed with `pip` or `apt`, or in a derived Dockerfile.
- No pre-installed jupyter extensions (arm build fails). Install from UI.
- Automated tests are disabled pending rewite of the testing harness.
- The multi-architecture image is pushed to DockerHub without automated tests.
- `buildx` uses the `qemu` emulator and is very slow (taking hours to build the docker images). To speed things up, limit the build to just the images that require updating. E.g. to just rebuild `scipy-notebook`, set `ALL_STACKS=scipy-notebook` in the `Makefile`. The `scipy-notebook` has been split into several images to reduce the build time for each stage.
- Presently only images are built for `linux/amd64` and `linux/arm/v7`. Change the `PLATFORMS` variable in the `Makefile` to add other architectures.
- Wiki manifest for `amd64` architecture only (since it's necessary to run the container on the appropriate machine)

## Resources

- [Issue Tracker on GitHub](https://github.com/iot49/docker-stacks)
- [Images on DockerHub](https://hub.docker.com/u/ttmetro)
- [Jupyter Website](https://jupyter.org)
- [JupyterLab Server on Raspberry Pi](https://github.com/kidig/rpi-jupyter-lab)