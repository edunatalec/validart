#!/bin/bash
set -e

TOTAL_STEPS=3
STEP=0
step() {
  STEP=$((STEP + 1))
  echo
  echo "[$STEP/$TOTAL_STEPS] $1"
}

PORT=8000

step "Cleaning previous docs"
rm -rf doc/api

step "Generating API docs"
dart doc

step "Serving on http://localhost:$PORT (Ctrl-C to stop)"

if lsof -i ":$PORT" >/dev/null 2>&1; then
  echo
  echo "❌ Port $PORT is already in use. Free it and run again."
  exit 1
fi

python3 -m http.server "$PORT" --directory doc/api >/dev/null 2>&1 &
SERVER_PID=$!
trap 'kill "$SERVER_PID" 2>/dev/null' EXIT INT TERM HUP

sleep 1
open "http://localhost:$PORT/?r=$RANDOM"
wait "$SERVER_PID"
