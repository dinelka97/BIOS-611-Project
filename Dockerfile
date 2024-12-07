FROM rocker/rstudio
ARG linux_user_pwd
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN apt update \
    && apt install -y software-properties-common
RUN Rscript --no-restore --no-save -e "install.packages(c('tidyverse', 'Rtsne', 'glue'))"
RUN Rscript --no-restore --no-save -e "install.packages(c('gt', 'readr', 'knitr', 'magrittr'))"
RUN Rscript --no-restore --no-save -e "install.packages(c('mgcv', 'pROC', 'pRROC', 'randomForest'))"
RUN Rscript --no-restore --no-save -e "install.packages(c('shiny', 'rsconnect', 'pROC', 'pRROC', 'randomForest'))"