FROM ttmetro/scipy-notebook
LABEL maintainer="IoT49 Project <boser@berkeley.edu>"

USER root

# hadolint ignore=DL3013
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir --no-warn-script-location \
    twine \
    tox \
    huffman \
    influxdb \
    # kernels
    iot-kernel \
    # extensions
    jupyter_contrib_nbextensions \
    jupyterlab-git \
    jupyter-lsp \
    python-language-server[all] \
    && \
    jupyter labextension install @jupyterlab/toc --no-build && \
    jupyter labextension install @ijmbarr/jupyterlab_spellchecker --no-build && \
    jupyter labextension install @aquirdturtle/collapsible_headings --no-build && \
    jupyter labextension install @krassowski/jupyterlab_go_to_definition --no-build && \
    jupyter labextension install @krassowski/jupyterlab-lsp --no-build \
    && \
    fix-permissions /home/$NB_USER

RUN apt update && \
    apt install -y --no-install-recommends \
    software-properties-common \
    gettext \
    openssh-client && \
    rm -rf /varf/lib/apt/lists/* \
    && \
    # install kernels
    python -m iot-kernel install

RUN jupyter lab build -y && \
    jupyter lab clean -y && \
    npm cache clean --force && \
    rm -rf "/home/${NB_USER}/.cache/yarn" && \
    rm -rf "/home/${NB_USER}/.node-gyp" && \
    fix-permissions "/home/${NB_USER}"
    
USER $NB_UID

WORKDIR $HOME