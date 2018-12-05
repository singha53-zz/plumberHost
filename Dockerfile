FROM trestletech/plumber
MAINTAINER Docker User <docker@user.org>

WORKDIR /usr/app

RUN R -e "install.packages('broom')"
COPY ./ ./

ENV PORT=8000

CMD ["/app/plumber.R"]