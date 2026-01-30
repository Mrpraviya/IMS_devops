#!/bin/sh
# wait-for-mongo.sh

set -e

host="$1"
shift
cmd="$@"

until nc -z "$host" 27017; do
  echo "Waiting for MongoDB at $host:27017..."
  sleep 1
done

exec $cmd
