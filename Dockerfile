FROM alpine
MAINTAINER "Noam Ross" ross@ecohealthalliance.org

RUN apk add --update curl make bash grep sed gcc \
  && rm -rf /var/cache/apk/*

CMD ls pmcvec