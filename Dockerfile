FROM python:3.10.7
FROM openjdk:17
USER root

# ディレクトリ ./appに移動
WORKDIR /app

# パッケージ管理コマンドをapt-getからapkに変更
RUN apk update && apk add --no-cache locales && apk upgrade && \
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
WORKDIR /root/src


# Docker内で扱うffmpegをインストール
RUN apt-get install -y ffmpeg

# pipのアップグレード、requirements.txtから必要なライブラリをインストール
RUN pip install --upgrade pip
RUN pip install --upgrade setuptools
RUN pip install -r requirements.txt
# discord.pyをpy-cordにアップグレード
RUN pip install git+https://github.com/Pycord-Development/pycord

# start.shをコンテナ内にコピー
COPY start.sh /root/src/start.sh

# スクリプト実行権限を付与
RUN chmod +x /root/src/start.sh

# 以下はKoyebで運用する際に必要
# ポート番号8080解放
EXPOSE 8080
  
# DiscordBotとFastAPIのサーバ起動
CMD ["/bin/sh", "/root/src/start.sh"]
