FROM alpine:3.19

RUN apk add --no-cache iputils ca-certificates

# Create non-root group and user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Create log volume directory with write access
RUN mkdir -p /app/logs && chown -R appuser:appgroup /app

COPY app/ /app/
RUN chmod +x /app/*.sh && chown -R appuser:appgroup /app

USER appuser

ENTRYPOINT ["/app/diagnostic.sh"]
CMD ["help"]