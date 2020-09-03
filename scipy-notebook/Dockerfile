# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
ARG BASE_CONTAINER==ttmetro/minimal-notebook
FROM $BASE_CONTAINER

LABEL maintainer=="IoT49 Project <boser@berkeley.edu>"

USER root

# ffmpeg for matplotlib anim & dvipng for latex labels
RUN apt-get update && \
    apt-get install -y --no-install-recommends ffmpeg dvipng && \
    rm -rf /var/lib/apt/lists/*

# Install Python 3 packages
# hadolint ignore=DL3013,SC1097
RUN pip install --upgrade pip && \
    pip install --no-warn-script-location \
    'beautifulsoup4==4.9.*'
# hadolint ignore=DL3013,SC1097
RUN pip install --no-warn-script-location \
    'pythran-openblas==0.3.6' \
    'bokeh==2.1.*' \
    'bottleneck==1.3.*'
# hadolint ignore=DL3013,SC1097
RUN pip install --no-warn-script-location \
    'cloudpickle==1.5.*' \
    'cython==0.29.*' \
    'dask==2.20.*' \
    'dill==0.3.*' \
    'h5py==2.10.*' \
    'hdf5==1.10.*' \
    'ipywidgets==7.5.*'
# hadolint ignore=DL3013,SC1097
RUN pip install --no-warn-script-location \
    'ipympl==0.5.*'\
    'matplotlib-base==3.2.*' \
    # numba update to 0.49 fails resolving deps.
    'numba==0.48.*' \
    'numexpr==2.7.*' \
    'pandas==1.1.*' \
    'patsy==0.5.*'
# hadolint ignore=DL3013,SC1097
RUN pip install --no-warn-script-location \
    'protobuf==3.12.*' \
    'pytables==3.6.*' \
    'scikit-image==0.17.*' \
    'scikit-learn==0.23.*' \
    'scipy==1.5.*' \
    'seaborn==0.10.*'
# hadolint ignore=DL3013,SC1097
RUN pip install --no-warn-script-location \
    'vincent==0.4.*' \
    'widgetsnbextension==3.5.*'\
    'xlrd==1.2.*'
    # && \
    # Activate ipywidgets extension in the environment that runs the notebook server

RUN jupyter nbextension enable --py widgetsnbextension --sys-prefix && \
    # Also activate ipywidgets extension for JupyterLab
    # Check this URL for most recent compatibilities
    # https://github.com/jupyter-widgets/ipywidgets/tree/master/packages/jupyterlab-manager
    jupyter labextension install @jupyter-widgets/jupyterlab-manager@^2.0.0 --no-build && \
    jupyter labextension install @bokeh/jupyter_bokeh@^2.0.0 --no-build && \
    jupyter labextension install jupyter-matplotlib@^0.7.2 --no-build && \
    jupyter lab build -y && \
    jupyter lab clean -y && \
    npm cache clean --force && \
    rm -rf "/home/${NB_USER}/.cache/yarn" && \
    rm -rf "/home/${NB_USER}/.node-gyp" && \
    fix-permissions "/home/${NB_USER}"

USER $NB_UID

# Install facets which does not have a pip or conda package at the moment
WORKDIR /tmp
RUN git clone https://github.com/PAIR-code/facets.git && \
    jupyter nbextension install facets/facets-dist/ --sys-prefix && \
    rm -rf /tmp/facets && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

# Import matplotlib the first time to build the font cache.
ENV XDG_CACHE_HOME=="/home/${NB_USER}/.cache/"

RUN MPLBACKEND==Agg python -c "import matplotlib.pyplot" && \
    fix-permissions "/home/${NB_USER}"

USER $NB_UID

WORKDIR $HOME
