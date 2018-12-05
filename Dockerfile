FROM trestletech/plumber
MAINTAINER Docker User <docker@user.org>

RUN R -e "install.packages('plumber')"

CMD ["/app/plumber.R"]