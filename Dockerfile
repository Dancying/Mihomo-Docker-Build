FROM docker.io/library/alpine:latest

RUN apk add --no-cache bash curl tzdata yq

ENV TZ=Asia/Shanghai

WORKDIR /app

COPY ./app /app

RUN chmod +x /app/*.sh /app/mihomo

EXPOSE 7890
EXPOSE 9090

VOLUME [ "/config" ]

ENTRYPOINT ["bash", "/app/entrypoint.sh"]
