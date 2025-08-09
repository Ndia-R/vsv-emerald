# ベースイメージとして軽量なJavaランタイムを指定
FROM openjdk:17-alpine

RUN apk update && \
    apk add --no-cache curl sudo bash && \
    rm -rf /var/cache/apk/*
    
# アプリケーションの作業ディレクトリを設定
WORKDIR /workspace

# ビルドしたSpring BootのJARファイルをコンテナにコピー
COPY ./my-books.jar my-books.jar

# 他のコンテナの起動を待つためのスクリプトをコピー
COPY ./wait-for-it.sh /usr/local/bin/wait-for-it.sh
RUN chmod +x /usr/local/bin/wait-for-it.sh

# アプリケーションの実行
# ENTRYPOINT ["java", "-jar", "my-books.jar"]