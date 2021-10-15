FROM continuumio/miniconda
MAINTAINER Sebastian Schoenherr <sebastian.schoenherr@i-med.ac.at>

COPY environment.yml .
RUN \
   conda env update -n root -f environment.yml \
&& conda clean -a

# Install mutserve
RUN mkdir /opt/mutserve
WORKDIR "/opt/mutserve"
RUN wget https://github.com/seppinho/mutserve/releases/download/v2.0.0-rc12/mutserve.zip && \
    unzip mutserve.zip
ENV PATH="/opt/mutserve:${PATH}"

# Install jbang (not as conda package available)
WORKDIR "/opt"
RUN wget https://github.com/jbangdev/jbang/releases/download/v0.79.0/jbang-0.79.0.zip && \
    unzip -q jbang-*.zip && \
    mv jbang-0.79.0 jbang  && \
    rm jbang*.zip
ENV PATH="/opt/jbang/bin:${PATH}"
