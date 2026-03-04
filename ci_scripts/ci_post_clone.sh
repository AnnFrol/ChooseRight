#!/bin/sh
# Создаёт Secrets.xcconfig для Xcode Cloud (GROQ_API_KEY, OPENROUTER_API_KEY для RU/BY).
set -e
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG_PATH="${REPO_ROOT}/ChooseRight!/SupportingFiles/Secrets.xcconfig"
{
  if [ -n "${GROQ_API_KEY}" ]; then
    echo "GROQ_API_KEY = ${GROQ_API_KEY}"
  else
    echo "GROQ_API_KEY = YOUR_GROQ_API_KEY"
  fi
  if [ -n "${OPENROUTER_API_KEY}" ]; then
    echo "OPENROUTER_API_KEY = ${OPENROUTER_API_KEY}"
  else
    echo "OPENROUTER_API_KEY = "
  fi
} > "$CONFIG_PATH"
echo "Created Secrets.xcconfig for Xcode Cloud"
