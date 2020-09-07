# Copyright (c) IoT49 Project.
# Distributed under the terms of the Modified BSD License.

FROM ttmetro/minimal-notebook

LABEL maintainer="IoT49 Project <boser@berkeley.edu>"

USER root

# ffmpeg for matplotlib anim & dvipng for latex labels
# libhdf5-dev liblapack-dev gfortran for numpy on ARM
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ffmpeg dvipng \
        libhdf5-dev liblapack-dev gfortran && \
    rm -rf /var/lib/apt/lists/*

USER $NB_UID

# hadolint ignore=DL3013
RUN pip install --upgrade pip && \
    pip install \
        pytest hypothesis \
        numpy scipy
