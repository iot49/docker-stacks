# Copyright (c) IoT49 Project.
# Distributed under the terms of the Modified BSD License.

FROM ttmetro/scipy-matplotlib-notebook

LABEL maintainer="IoT49 Project <boser@berkeley.edu>"

USER $NB_UID

# Add libraries and generate a notebook server config
# hadolint ignore=DL3013
RUN pip install --upgrade pip && \
    pip install pandas sympy
