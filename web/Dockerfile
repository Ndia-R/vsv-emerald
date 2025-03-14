FROM nginx:alpine

# 必要なパッケージをインストール
RUN apk update && \
    apk add --no-cache libwebp-tools

# 作業ディレクトリを設定
WORKDIR /usr/share/nginx/html

# アプリを配置
COPY ./my-books/dist/ .

# 画像を変換するスクリプトを追加
COPY ./convert_images.sh /usr/local/bin/convert_images.sh
RUN chmod +x /usr/local/bin/convert_images.sh

# コンテナ起動時に画像を変換
CMD ["/bin/sh", "-c", "/usr/local/bin/convert_images.sh && nginx -g 'daemon off;'"]
