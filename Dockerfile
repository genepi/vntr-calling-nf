FROM continuumio/miniconda
MAINTAINER Sebastian Schoenherr <sebastian.schoenherr@i-med.ac.at>

COPY environment.yml .
RUN \
   conda env update -n root -f environment.yml \
&& conda clean -a
