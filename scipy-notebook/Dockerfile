# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
ARG BASE_CONTAINER=ttmetro/minimal-notebook
FROM $BASE_CONTAINER

LABEL maintainer="IoT49 Project <boser@berkeley.edu>"

USER root

# ffmpeg for matplotlib anim & dvipng for latex labels
# libhdf5-dev liblapack-dev gfortran for numpy
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ffmpeg dvipng \
        libhdf5-dev liblapack-dev gfortran && \
    rm -rf /var/lib/apt/lists/* && \
    # required to install extensions 
    # - since jupyter is installed as root, in /usr/local/bin/jupyter
    # - root won't find jupyter if installed as user ...
    # (either fix base-notebook or keep this ...)
    chmod -R a+w /usr/local/share/jupyter

USER $NB_UID

ENV PATH=$HOME/.local/bin:$PATH

# hadolint ignore=DL3013
RUN pip install --user --upgrade pip && \
    pip install --user \
        numpy scipy sympy pandas matplotlib \
        ipywidgets jupyterlab-git \
    && \
    # Activate ipywidgets extension in the environment that runs the notebook server
    jupyter nbextension enable --py widgetsnbextension && \
    # Also activate ipywidgets extension for JupyterLab
    # Check this URL for most recent compatibilities
    # https://github.com/jupyter-widgets/ipywidgets/tree/master/packages/jupyterlab-manager
    jupyter labextension install @jupyter-widgets/jupyterlab-manager@^2.0.0 --no-build && \
    jupyter labextension install @bokeh/jupyter_bokeh@^2.0.0 --no-build && \
    jupyter labextension install jupyter-matplotlib@^0.7.2 --no-build && \
    jupyter lab build -y && \
    jupyter lab clean -y && \
    npm cache clean --force && \
    rm -rf $HOME/.cache/yarn && \
    rm -rf $HOME/.node-gyp && \
    fix-permissions $HOME

# Install facets which does not have a pip or conda package at the moment
WORKDIR /tmp
RUN git clone https://github.com/PAIR-code/facets.git && \
    jupyter nbextension install facets/facets-dist/ --sys-prefix && \
    rm -rf /tmp/facets && \
    fix-permissions $HOME

# Import matplotlib to build the font cache.
ENV XDG_CACHE_HOME=$HOME/.cache/

RUN MPLBACKEND=Agg python -c "import matplotlib.pyplot" && \
    fix-permissions $HOME

USER $NB_UID

WORKDIR $HOME
