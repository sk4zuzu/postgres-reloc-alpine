#!/usr/bin/env bash

PREFIX="${PREFIX:-/opt/postgres}"

if docker build --build-arg PREFIX="$PREFIX" -t postgres-reloc-alpine .; then
    docker run --rm postgres-reloc-alpine cat /tmp/postgres.tar.xz > 'postgres.tar.xz'
fi

# vim:ts=4:sw=4:et:
