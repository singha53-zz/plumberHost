FROM trestletech/plumber
MAINTAINER Docker User <docker@user.org>

WORKDIR /usr/app

RUN R -e "install.packages('broom')"
COPY ./ ./

CMD ["/app/plumber.R"]