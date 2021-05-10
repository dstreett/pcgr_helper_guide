FROM python:3.9.1-slim-buster

SHELL ["/bin/bash", "-c"]

RUN mkdir -p /usr/pcgr

# set environment variables
ENV PYTHONUNBUFFERED 1

# Install python/pip
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED=1
RUN pip3 install --no-cache --upgrade pip setuptools toml


# System reqs
RUN apt-get update \
  && apt-get -y install curl axel wget git \
  && apt-get clean

RUN wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh
RUN bash miniconda.sh -b -p ./miniconda

RUN . ./miniconda/etc/profile.d/conda.sh && conda create -n pcgr -c conda-forge -c bioconda -c pcgr pcgr 
ENV PATH="/miniconda/condabin:${PATH}"


WORKDIR /usr/pcgr
VOLUME pcgr_data:/data
RUN conda init bash
RUN echo "conda activate pcgr" >> /root/.bashrc
RUN git clone https://github.com/sigven/pcgr.git

WORKDIR /usr/pcgr/pcgr
RUN mkdir /usr/pcgr/pcgr/test_out
