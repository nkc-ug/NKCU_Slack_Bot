FROM ruby:2.6.5

RUN apt-get update

ENV BUNDLE_JOBS=4 \
    BUNDLE_PATH=/bundle \
    APP_DIR=/app

RUN mkdir app
COPY application/Gemfile app/
COPY application/Gemfile.lock app/

RUN bundle