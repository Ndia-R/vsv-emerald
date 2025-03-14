#!/bin/sh

# 画像ディレクトリを指定
IMAGE_DIR="/usr/share/nginx/html/images"

# jpgとpng画像をwebpに変換（すでにwebpファイルが存在する場合はスキップ）
find $IMAGE_DIR -type f \( -iname "*.jpg" -o -iname "*.png" \) -exec sh -c '
  for img; do
    # 元のファイル名を取得
    base_name=$(basename "$img")
    # 変換後のファイル名を設定
    webp_file="${img}.webp"
    if [ ! -f "$webp_file" ]; then
      cwebp "$img" -o "$webp_file"
    fi
  done
' sh {} +
