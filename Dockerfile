FROM python:3.10.7-slim

# Makeコマンドをインストール
RUN apt-get update && apt-get install -y make

# Mavenをインストール
RUN apt-get update && apt-get install -y maven

# gitをインストール
RUN apt-get update && apt-get install -y git

# Javaのインストール
RUN apt-get install -y --no-install-recommends openjdk-17-jdk

# Pythonのコマンドを使えるようにするために、pythonのイメージでUSERを再設定
USER root

# プロジェクトファイルをコピー
COPY Makefile /root/src/Makefile
WORKDIR /root/src
# Makeコマンドを実行してjarをビルド
RUN make jar

# Python用の設定
RUN apt-get -y update && apt-get -y install locales && apt-get -y upgrade && \
    localedef -f UTF-8 -i ja_JP ja_JP.UTF-8
ENV LANG ja_JP.UTF-8
ENV LANGUAGE ja_JP:ja
ENV LC_ALL ja_JP.UTF-8
ENV TZ JST-9
ENV TERM xterm

# ./root/src ディレクトリを作成 ホームのファイルをコピーして、移動
RUN mkdir -p /root/src
COPY . /root/src
COPY . /root
WORKDIR /root

# Docker内で扱うffmpegをインストール
RUN apt-get install -y ffmpeg

# pipのアップグレード、requirements.txtから必要なライブラリをインストール
RUN pip install --upgrade pip
RUN pip install --upgrade setuptools
# RUN pip install -r requirements.txt
# discord.pyをpy-cordにアップグレード
RUN pip install git+https://github.com/Pycord-Development/pycord

# 以下はKoyebで運用する際に必要
# ポート番号8080解放
EXPOSE 8080

# ディレクトリ /root/src/appに移動

# DiscordBotとFastAPIのサーバ起動
CMD ["java", "-jar", "discord-bcdicebot.jar", "$DISCORD_BOT_TOKEN", "$BCDICE_API_URL", "$IGNORE_ERROR"]
