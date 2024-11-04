# ベースイメージとして軽量なJavaランタイムを指定
FROM eclipse-temurin:17-jdk-alpine

# アプリケーションの作業ディレクトリを設定
WORKDIR /app

# ビルドしたSpring BootのJARファイルをコンテナにコピー
COPY ./app/my-books.jar app.jar

# アプリケーションの実行
ENTRYPOINT ["java", "-jar", "app.jar"]
