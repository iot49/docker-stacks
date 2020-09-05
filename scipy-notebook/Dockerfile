FROM ttmetro/minimal-notebook

LABEL maintainer="IoT49 Project <boser@berkeley.edu>"

USER root

# ffmpeg for matplotlib anim & dvipng for latex labels
# libhdf5-dev liblapack-dev gfortran for numpy
# scipy with apt (never managed to build from pip with qemu)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ffmpeg dvipng \
        libhdf5-dev liblapack-dev gfortran \
        python-numpy python-scipy python-matplotlib \
        python-pandas python-sympy && \
    rm -rf /var/lib/apt/lists/*

USER $NB_UID

ENV PATH=/home/$NB_USER/.local/bin:$CONDA_DIR/bin:$PATH

# Add libraries and generate a notebook server config
# hadolint ignore=DL3013
RUN pip install --upgrade pip && \
    pip install pytest

# Import matplotlib to build the font cache.
ENV XDG_CACHE_HOME="/home/${NB_USER}/.cache/"

RUN MPLBACKEND=Agg python -c "import matplotlib.pyplot" && \
    fix-permissions "/home/${NB_USER}"
