#!/usr/bin/env sh
set -eu

# The hosted app avoids requiring a local Python or HTTP server.
APP_URL="https://suvvarimohit.github.io/PuppetShow_ProtoType_SE_IITTP/"

case "$(uname -s)" in
  Darwin) open "$APP_URL" ;;
  Linux)
    if command -v xdg-open >/dev/null 2>&1; then
      xdg-open "$APP_URL"
    elif command -v gio >/dev/null 2>&1; then
      gio open "$APP_URL"
    else
      printf 'Open this link in your browser:\n%s\n' "$APP_URL"
    fi
    ;;
  *)
    printf 'Open this link in your browser:\n%s\n' "$APP_URL"
    ;;
esac
