FROM theoldmoon0602/shellgeibot

RUN apt-get update

ENV BUNDLE_JOBS=4 \
    APP_DIR=/app

RUN mkdir app
COPY application/Gemfile app/
COPY application/Gemfile.lock app/

WORKDIR /app
RUN gem install bundler
RUN gem install unf_ext -v '0.0.7.6'
RUN bundle install

COPY application ./

# RUN ruby app.rb