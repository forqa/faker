FROM ruby:2.3

RUN bundle config --global frozen 1
RUN mkdir -p /usr/src/app

WORKDIR /usr/src/app

COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/
COPY public /usr/src/app/public
COPY responses /usr/src/app/responses
COPY views /usr/src/app/views

RUN gem install colorize
RUN bundle install

EXPOSE 9494

COPY app.rb /usr/src/app
COPY params_manager.rb /usr/src/app
COPY response_logic.rb /usr/src/app

CMD ["ruby", "./app.rb"]
