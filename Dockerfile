# syntax = docker/dockerfile:1

ARG RUBY_VERSION=3.2.2
FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim as base

WORKDIR /rails

ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development test"

FROM base as build

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libpq-dev libvips pkg-config shared-mime-info && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/man/* /usr/share/doc/*

COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

COPY . .

RUN echo "SECRET_KEY_BASE is: $SECRET_KEY_BASE"

ENV SECRET_KEY_BASE d9513581e16cfee27e41695d6c8c5f7c79ee12249d33cd8afd7a7278d23db90725f77a16c999f7c2e6bfe7fc46b2fc102ff5ac6031f3deb3bfd738ca87a67b0f


RUN bundle exec bootsnap precompile app/ lib/


RUN SECRET_KEY_BASE=${SECRET_KEY_BASE} bundle exec rails assets:precompile --trace


FROM base

# Copie o script wait-for-it
COPY wait-for-it.sh /usr/local/bin/wait-for-it.sh

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libvips postgresql-client redis-tools shared-mime-info && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

RUN useradd rails --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER rails:rails

ENTRYPOINT ["/rails/bin/docker-entrypoint"]

EXPOSE 1000

CMD ["./bin/rails", "server"]

