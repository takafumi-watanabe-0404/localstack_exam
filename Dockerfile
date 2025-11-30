FROM ruby:3.2-alpine

RUN apk add --no-cache build-base nodejs yarn tzdata yaml-dev git

WORKDIR /app

COPY Gemfile* ./
RUN bundle install

COPY . .

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
