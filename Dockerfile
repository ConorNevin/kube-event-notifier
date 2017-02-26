FROM alpine:latest

COPY bin/kube-event-notifier /app

CMD ["/app/kube-event-notifier"]