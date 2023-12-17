#!/bin/bash

if [ ! -f .env ]; then
    echo "Please create a .env file in the root directory. See .env.example for an example"
    exit 1
fi

set -a
source .env
set +a

dart run

# dart run nyxx_commands:compile bin/maid_chan.dart -o bin/out.g.dart
# dart run bin/out.g.dart
