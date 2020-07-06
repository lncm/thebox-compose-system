FROM alpine:3.10

RUN apk add --no-cache curl jq

COPY switch.sh /bin/switch-service
RUN chmod +x /bin/switch-service

ENTRYPOINT ["switch-service"]
