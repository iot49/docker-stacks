FROM ttmetro/minimal-notebook

LABEL maintainer="IoT49 Project <boser@berkeley.edu>"

USER root

# ffmpeg for matplotlib anim & dvipng for latex labels
# libhdf5-dev liblapack-dev gfortran for numpy
# scipy with apt (never managed to build from pip with qemu)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ffmpeg dvipng \
        libhdf5-dev liblapack-dev gfortran && \
    rm -rf /var/lib/apt/lists/*

USER $NB_UID

ENV PATH=/home/$NB_USER/.local/bin:$CONDA_DIR/bin:$PATH

# Add libraries and generate a notebook server config
# hadolint ignore=DL3013
RUN pip install --upgrade pip && \
    pip install pytest numpy

# Import matplotlib to build the font cache.
ENV XDG_CACHE_HOME="/home/${NB_USER}/.cache/"

#RUN MPLBACKEND=Agg python -c "sys.path.append('/usr/lib/python3/dist-packages/'); import matplotlib.pyplot" && \
#    fix-permissions "/home/${NB_USER}"
