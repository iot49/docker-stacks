FROM ttmetro/minimal-notebook

LABEL maintainer="IoT49 Project <boser@berkeley.edu>"

USER root

# ffmpeg for matplotlib anim & dvipng for latex labels
# libhdf5-dev liblapack-dev gfortran for numpy
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ffmpeg dvipng \
        libhdf5-dev liblapack-dev gfortran && \
    rm -rf /var/lib/apt/lists/*

USER $NB_UID

# hadolint ignore=DL3013
RUN pip install --upgrade pip && \
    pip install \
        matplotlib \
        # numpy scipy sympy pandas \
        # ipywidgets jupyterlab-git \
    && \
    fix-permissions $HOME

# Import matplotlib to build the font cache.
ENV XDG_CACHE_HOME=$HOME/.cache/

RUN MPLBACKEND=Agg python -c "import matplotlib.pyplot" && \
    fix-permissions $HOME
