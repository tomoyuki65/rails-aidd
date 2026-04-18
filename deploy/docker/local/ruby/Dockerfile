FROM ruby:4.0.2-slim

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
      locales \
      build-essential \
      git \
      libpq-dev \
      libyaml-dev && \
    rm -rf /var/lib/apt/lists/*

# ロケール設定
RUN echo "ja_JP.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen

WORKDIR /src

COPY src/Gemfile src/Gemfile.lock .

# bundlerのバージョンは固定して実行
RUN gem install bundler -v 4.0.10
RUN bundle _4.0.10_ install

COPY ./src /src

EXPOSE 3000
