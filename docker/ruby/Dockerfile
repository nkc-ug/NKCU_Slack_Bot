FROM ruby:2.6.5

RUN apt-get update

ENV BUNDLE_JOBS=4 \
    APP_DIR=/app

RUN mkdir app
COPY application/Gemfile app/
COPY application/Gemfile.lock app/

WORKDIR /app
RUN gem install bundler && bundle install

COPY application ./

# RUN ruby app.rb