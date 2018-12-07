FROM rocker/tidyverse

RUN apt-get update -qq && apt-get install -y \ 
    git-core \ 
    libssl-dev \ 
    libcurl4-gnutls-dev \
    python \
    python-pip

COPY ./api/ /usr/local/src/omicshub-api
WORKDIR /usr/local/src/omicshub-api

RUN chmod 700 start.sh

# Install R packages / setup omicshubR.
RUN R -e "install.packages('plumber')"
RUN R -e "install.packages('jsonlite')"
RUN R -e "install.packages('caret')"
RUN R -e "install.packages('e1071')"
RUN R -e "install.packages('glmnet')"

# Port 8000 for local usage, not used on Heroku.
EXPOSE 8000

ENTRYPOINT ["/usr/local/src/omicshub-api/start.sh"]
CMD ["routes.R"]