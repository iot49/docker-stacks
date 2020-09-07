# Copyright (c) IoT49 Project.
# Distributed under the terms of the Modified BSD License.

FROM ttmetro/scipy-numpy-notebook

LABEL maintainer="IoT49 Project <boser@berkeley.edu>"

USER $NB_UID

# hadolint ignore=DL3013
RUN pip install --upgrade pip && \
    pip matplotlib

# Import matplotlib to build the font cache.
ENV XDG_CACHE_HOME="/home/${NB_USER}/.cache/"

RUN MPLBACKEND=Agg python -c "import matplotlib.pyplot" && \
    fix-permissions "/home/${NB_USER}"
