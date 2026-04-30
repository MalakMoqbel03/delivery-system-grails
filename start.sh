#!/usr/bin/env bash
# ─────────────────────────────────────────────
# start.sh  –  Run Grails then open Chrome
# Usage: ./start.sh [port]   (default port: 8080)
# ─────────────────────────────────────────────

PORT=${1:-8080}
LOGIN_URL="http://localhost:${PORT}/login"

echo "▶  Starting Grails on port ${PORT}..."

# Start Grails in the background
./grailsw run-app -port=${PORT} &
GRAILS_PID=$!

echo "⏳  Waiting for server to be ready at ${LOGIN_URL} ..."

# Poll until the server responds (max 120 seconds)
TRIES=0
MAX=60
until curl -s --head "${LOGIN_URL}" | grep -q "HTTP/"; do
    sleep 2
    TRIES=$((TRIES + 1))
    if [ $TRIES -ge $MAX ]; then
        echo "❌  Server did not start in time. Check Grails output."
        exit 1
    fi
done

echo "✅  Server is up! Opening Chrome..."

# Open Chrome — works on macOS, Linux, and Windows (Git Bash / WSL)
if command -v google-chrome &>/dev/null; then
    google-chrome "${LOGIN_URL}" &
elif command -v google-chrome-stable &>/dev/null; then
    google-chrome-stable "${LOGIN_URL}" &
elif command -v chromium-browser &>/dev/null; then
    chromium-browser "${LOGIN_URL}" &
elif command -v chromium &>/dev/null; then
    chromium "${LOGIN_URL}" &
elif [[ "$OSTYPE" == "darwin"* ]]; then
    open -a "Google Chrome" "${LOGIN_URL}"
elif [[ "$OSTYPE" == "msys"* || "$OSTYPE" == "cygwin"* ]]; then
    start chrome "${LOGIN_URL}"
else
    echo "⚠️  Could not find Chrome. Please open manually: ${LOGIN_URL}"
fi

# Bring Grails back to foreground so Ctrl+C works
wait $GRAILS_PID
