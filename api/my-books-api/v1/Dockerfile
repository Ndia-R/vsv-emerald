# ベースイメージとして軽量なJavaランタイムを指定
FROM eclipse-temurin:17-jre-alpine AS production

# healthcheck用にcurlをインストール
RUN apk add --update curl

# セキュリティ: 非rootユーザーで実行
RUN addgroup -S appuser && adduser -S -G appuser appuser

WORKDIR /app

# JARファイルをコピー
COPY ./*.jar app.jar

# 所有権を変更
RUN chown appuser:appuser /app/app.jar

USER appuser

ENTRYPOINT ["java", "-jar", "/app/app.jar"]