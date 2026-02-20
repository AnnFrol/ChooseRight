#!/bin/sh
# Создаёт Secrets.xcconfig для Xcode Cloud (ключ из переменной GROQ_API_KEY).
set -e
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG_PATH="${REPO_ROOT}/ChooseRight!/SupportingFiles/Secrets.xcconfig"
if [ -n "${GROQ_API_KEY}" ]; then
  echo "GROQ_API_KEY = ${GROQ_API_KEY}" > "$CONFIG_PATH"
else
  echo "GROQ_API_KEY = YOUR_GROQ_API_KEY" > "$CONFIG_PATH"
fi
echo "Created Secrets.xcconfig for Xcode Cloud"
