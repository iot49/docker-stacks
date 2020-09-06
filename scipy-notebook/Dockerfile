FROM ttmetro/minimal-notebook

LABEL maintainer="IoT49 Project <boser@berkeley.edu>"

USER root

# ffmpeg for matplotlib anim & dvipng for latex labels
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ffmpeg dvipng && \
        # numpy for ARM does not include these
        gfortran libopenblas-dev liblapack-dev && \
    rm -rf /var/lib/apt/lists/*

USER $NB_UID

# ENV PATH=/home/$NB_USER/.local/bin:$CONDA_DIR/bin:$PATH

# Add libraries and generate a notebook server config
# hadolint ignore=DL3013
RUN pip install --upgrade pip && \
    pip install \
        pytest hypothesis \
        numpy scipy matplotlib
        # pandas sympy

# Import matplotlib to build the font cache.
ENV XDG_CACHE_HOME="/home/${NB_USER}/.cache/"

RUN MPLBACKEND=Agg python -c "import matplotlib.pyplot" && \
    fix-permissions "/home/${NB_USER}"
