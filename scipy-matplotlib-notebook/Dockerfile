# Copyright (c) IoT49 Project.
# Distributed under the terms of the Modified BSD License.

FROM ttmetro/scipy-numpy-notebook

LABEL maintainer="IoT49 Project <boser@berkeley.edu>"

USER $NB_UID

# hadolint ignore=DL3013
RUN pip install --upgrade pip && \
    pip install matplotlib

# Import matplotlib to build the font cache.
# Note: masked if mounting (-v) to /home/${NB_USER} ... should we put the cache elsewhere?
# But fast anyway, even on rpi3
ENV XDG_CACHE_HOME="/home/${NB_USER}/.cache/"

RUN MPLBACKEND=Agg python -c "import matplotlib.pyplot" && \
    fix-permissions "/home/${NB_USER}"
