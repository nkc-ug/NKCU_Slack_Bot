FROM theoldmoon0602/shellgeibot

RUN apt-get update

RUN apt-get install -y ruby-dev
RUN apt-get install -y libssl-dev
ENV BUNDLE_JOBS=4 \
    APP_DIR=/app

RUN mkdir app
COPY shellgei_container/Gemfile app/
COPY shellgei_container/Gemfile.lock app/

WORKDIR /app
RUN gem install bundler && bundle install

COPY shellgei_container ./

# RUN shellgei_container app.rb