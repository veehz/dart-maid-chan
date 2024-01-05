#!/bin/bash

if [ ! -f .env ]; then
    echo "Please create a .env file in the root directory. See .env.example for an example"
    exit 1
fi

set -a
source .env
set +a

# if exists bin/out.g.dart delete
if [ -f bin/out.g.dart ]; then
    rm bin/out.g.dart
fi

# dart run

dart run nyxx_commands:compile bin/bots.dart -o bin/out.g.dart --no-compile
# if exit code is 0, run
if [ $? -eq 0 ]; then
    echo "Compilation successful"
    dart run bin/out.g.dart
else
    echo "Compilation failed"
    exit 1
fi
