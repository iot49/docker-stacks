# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.

# Modified for multi-architecture build (Conda --> pip).

FROM python:3.8-buster

LABEL maintainer="IoT49 Project <boser@berkeley.edu>"
ARG NB_USER="jovyan"
ARG NB_UID="1000"
ARG NB_GID="100"

# Fix DL4006
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root

# Install all OS dependencies for notebook server that starts but lacks all
# features (e.g., download as all possible file formats)
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update \
 && apt-get install -yq --no-install-recommends \
    wget \
    bzip2 \
    ca-certificates \
    sudo \
    locales \
    fonts-liberation \
    libncurses5-dev \
    libzmq3-dev \
    libfreetype6-dev \
    libpng-dev \
    cmake \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen

# Configure environment
ENV CONDA_DIR=/opt/conda \
    SHELL=/bin/bash \
    NB_USER=$NB_USER \
    NB_UID=$NB_UID \
    NB_GID=$NB_GID \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8
ENV HOME=/home/$NB_USER

# Install Tini. Tini operates as a process subreaper for jupyter. This prevents kernel crashes.
# https://github.com/kidig/rpi-jupyter-lab/blob/master/Dockerfile
ENV TINI_VERSION=0.18.0
ENV CFLAGS="-DPR_SET_CHILD_SUBREAPER=36 -DPR_GET_CHILD_SUBREAPER=37"
WORKDIR /tmp
ADD https://github.com/krallin/tini/archive/v${TINI_VERSION}.tar.gz v${TINI_VERSION}.tar.gz
RUN tar zxvf v${TINI_VERSION}.tar.gz
WORKDIR /tmp/tini-${TINI_VERSION}
RUN cmake . && make && cp tini /usr/bin/.
WORKDIR /tmp
RUN rm -rf "./tini-${TINI_VERSION}" && rm "./v${TINI_VERSION}.tar.gz"

# Copy a script that we will use to correct permissions after running certain commands
COPY fix-permissions /usr/local/bin/fix-permissions
RUN chmod a+rx /usr/local/bin/fix-permissions

# Enable prompt color in the skeleton .bashrc before creating the default NB_USER
RUN sed -i 's/^#force_color_prompt=yes/force_color_prompt=yes/' /etc/skel/.bashrc

# Create NB_USER wtih name jovyan user with UID=1000 and in the 'users' group
# and make sure these dirs are writable by the `users` group.
RUN echo "auth requisite pam_deny.so" >> /etc/pam.d/su && \
    sed -i.bak -e 's/^%admin/#%admin/' /etc/sudoers && \
    sed -i.bak -e 's/^%sudo/#%sudo/' /etc/sudoers && \
    useradd -m -s /bin/bash -N -u $NB_UID $NB_USER && \
    chmod g+w /etc/passwd && \
    fix-permissions $HOME

# Install Jupyter Notebook, Lab, and Hub
# Generate a notebook server config

# hadolint ignore=DL3013,DL3016
RUN pip install --upgrade pip && \
    pip install --no-warn-script-location nodejs readline ipywidgets jupyter jupyterlab && \
    npm install -g yarn && \
    jupyter notebook --generate-config && \
    fix-permissions /home/$NB_USER

USER $NB_UID
WORKDIR $HOME

# Setup work directory for backward-compatibility
RUN mkdir /home/$NB_USER/work && \
    fix-permissions /home/$NB_USER

EXPOSE 8888

# Configure container startup
ENTRYPOINT ["/usr/bin/tini", "-g", "--"]
CMD ["start-notebook.sh"]

# Copy local files as late as possible to avoid cache busting
COPY start.sh start-notebook.sh start-singleuser.sh /usr/local/bin/
COPY jupyter_notebook_config.py /etc/jupyter/

# Fix permissions on /etc/jupyter as root
USER root
RUN fix-permissions /etc/jupyter/

# Switch back to jovyan to avoid accidental container runs as root
USER $NB_UID

WORKDIR $HOME
