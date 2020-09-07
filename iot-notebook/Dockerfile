# Copyright (c) IoT49 Project.
# Distributed under the terms of the Modified BSD License.

FROM ttmetro/scipy-notebook

LABEL maintainer="IoT49 Project <boser@berkeley.edu>"

USER root

RUN apt-get update && apt-get install -yq --no-install-recommends \
        software-properties-common \
        gettext \
    && \
    apt-get clean && rm -rf /var/lib/apt/lists/* \
    && \
    # Typescript & javascript kernels
    npm install -f -g tslab && \
    tslab install

USER $NB_UID

# Jupyter(lab) extensions
RUN pip install --upgrade pip && \ 
    pip install \ 
        jupyter_contrib_nbextensions \
        # requirements for @krassowski/jupyterlab-lsp
        python-language-server[all] \
        jupyter-lsp

USER root

RUN jupyter labextension install jupyter-matplotlib --no-build && \
    jupyter labextension install @jupyterlab/toc --no-build && \
    jupyter labextension install @ijmbarr/jupyterlab_spellchecker --no-build && \
    jupyter labextension install @aquirdturtle/collapsible_headings --no-build && \
    jupyter labextension install @krassowski/jupyterlab-lsp --no-build && \
    jupyter lab build -y && \
    jupyter lab clean -y && \
    npm cache clean --force && \
    rm -rf "/home/${NB_USER}/.cache/yarn" && \
    rm -rf "/home/${NB_USER}/.node-gyp" && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

USER $NB_UID

# Install iot_kernel - last (frequent changes)
RUN pip install iot-kernel && \
    python -m iot_kernel.install --prefix /usr/local
