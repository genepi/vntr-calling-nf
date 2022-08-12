FROM continuumio/miniconda
MAINTAINER Sebastian Schoenherr <sebastian.schoenherr@i-med.ac.at>

COPY environment.yml .
RUN \
   conda env update -n root -f environment.yml \
&& conda clean -a

# Install mutserve
RUN mkdir /opt/mutserve
WORKDIR "/opt/mutserve"
RUN wget https://github.com/seppinho/mutserve/releases/download/v2.0.0-rc14/mutserve.zip && \
    unzip mutserve.zip
ENV PATH="/opt/mutserve:${PATH}"

# Install jbang (not as conda package available)
WORKDIR "/opt"
RUN wget https://github.com/jbangdev/jbang/releases/download/v0.92.2/jbang-0.92.2.zip && \
    unzip -q jbang-*.zip && \
    mv jbang-0.92.2 jbang  && \
    rm jbang*.zip
ENV PATH="/opt/jbang/bin:${PATH}"


# Install freebayes
RUN mkdir /opt/freebayes
WORKDIR "/opt/freebayes"
RUN wget https://github.com/freebayes/freebayes/releases/download/v1.3.4/freebayes-1.3.4-linux-static-AMD64.gz && \
    gunzip freebayes-*-linux-static-AMD64.gz && \
    chmod +x ./freebayes-*-linux-static-AMD64
ENV PATH="/opt/freebayes:${PATH}"
