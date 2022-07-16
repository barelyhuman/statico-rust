FROM rust:latest AS builder

RUN apt update; apt install -y musl-tools musl-dev; apt-get install -y build-essential gcc-x86-64-linux-gnu linux-libc-dev xutils-dev libssl-dev libpq-dev


# Create appuser
ENV USER=my-user
ENV UID=10001

RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    "${USER}"

