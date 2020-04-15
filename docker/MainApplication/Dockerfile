FROM ruby:2.7.1

RUN mkdir app
COPY MainApplication/Gemfile app/
COPY shellgei_container/Gemfile.lock app/

WORKDIR /app
RUN gem install bundler && bundle install

COPY MainApplication app/
