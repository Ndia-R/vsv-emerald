# ベースイメージとして軽量なJavaランタイムを指定
FROM openjdk:17-alpine

# アプリケーションの作業ディレクトリを設定
WORKDIR /workspace

# ビルドしたSpring BootのJARファイルをコンテナにコピー
COPY ./my-books.jar my-books.jar

# アプリケーションの実行
ENTRYPOINT ["java", "-jar", "my-books.jar"]
