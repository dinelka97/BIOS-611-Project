FROM rocker/rstudio
ARG linux_user_pwd
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN apt update \
    && apt install -y software-properties-common \
    && echo "rstudio:$linux_user_pwd" | chpasswd
RUN Rscript --no-restore --no-save -e "install.packages(c('tidyverse', 'ggpplot2', 'magrittr'))"