FROM golang:1.23.0 AS build

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN mkdir build
RUN go build -o ./build ./...

FROM gcr.io/google.com/cloudsdktool/cloud-sdk:slim AS runtime

COPY --from=build /app/build /usr/local/bin

RUN apt-get update && apt-get install -y libsecret-1-0 gnome-keyring

RUN mkdir -p /secrets

ENV PORT=8080
ENV TESLA_HTTP_PROXY_TLS_CERT=/config/tls-cert.pem
ENV TESLA_HTTP_PROXY_TLS_KEY=/config/tls-key.pem
ENV TESLA_HTTP_PROXY_HOST=0.0.0.0
ENV TESLA_HTTP_PROXY_PORT=8080
ENV TESLA_HTTP_PROXY_TIMEOUT=10s
ENV TESLA_KEYRING_TYPE=file
ENV TESLA_KEY_FILE=/secrets/tesla-private-key.pem
# ENV TESLA_VERBOSE=true

ENTRYPOINT ["/bin/sh", "-c", \
  "gcloud secrets versions access latest --secret tesla-private-key > /secrets/tesla-private-key.pem && \
   exec tesla-http-proxy -port 8080"]
