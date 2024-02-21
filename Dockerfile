FROM ubuntu:22.04
LABEL Sebastian Schoenherr <sebastian.schoenherr@i-med.ac.at>

# Install compilers
RUN apt-get update && \
    apt-get install -y wget build-essential zlib1g-dev liblzma-dev libbz2-dev libxau-dev && \
    apt-get -y clean

#  Install miniconda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-py39_23.9.0-0-Linux-x86_64.sh -O ~/miniconda.sh && \
  /bin/bash ~/miniconda.sh -b -p /opt/conda
ENV PATH=/opt/conda/bin:${PATH}

COPY environment.yml .
RUN \
   conda env update -n root -f environment.yml \
&& conda clean -a



# Install mutserve
RUN mkdir /opt/mutserve
WORKDIR "/opt/mutserve"
RUN wget https://github.com/seppinho/mutserve/releases/download/v2.0.0-rc15/mutserve.zip && \
    unzip mutserve.zip
ENV PATH="/opt/mutserve:${PATH}"

# Install jbang (not as conda package available)
WORKDIR "/opt"
RUN wget https://github.com/jbangdev/jbang/releases/download/v0.92.2/jbang-0.92.2.zip && \
    unzip -q jbang-*.zip && \
    mv jbang-0.92.2 jbang  && \
    rm jbang*.zip
ENV PATH="/opt/jbang/bin:${PATH}"

COPY ./bin/PatternSearch.java ./
RUN jbang export portable -O=PatternSearch.jar PatternSearch.java

COPY ./bin/MutservePerformance.java ./
RUN jbang export portable -O=MutservePerformance.jar MutservePerformance.java

WORKDIR "/opt"
ENV GENOMIC_UTILS_VERSION="v0.3.7"
RUN wget https://github.com/genepi/genomic-utils/releases/download/${GENOMIC_UTILS_VERSION}/genomic-utils.jar