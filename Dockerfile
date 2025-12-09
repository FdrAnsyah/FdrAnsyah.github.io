FROM ruby:3.2
WORKDIR /app
COPY Gemfile ./
COPY *.gemspec ./
RUN bundle install
CMD ["bundle", "exec", "jekyll", "serve", "--host=0.0.0.0"]
