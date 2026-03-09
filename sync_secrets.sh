#!/bin/bash

EXPECTED_SECRETS=(
  "REDDIT_CLIENT_ID"
  "REDDIT_CLIENT_SECRET"
  "DISCORD_WEBHOOK_ANIME"
)

# Check if .env file exists
if [ ! -f .env ]; then
  echo "No .env file found. Creating one..."
  touch .env
fi

ADDED_NEW_SECRET=false

for secret in "${EXPECTED_SECRETS[@]}"; do
  if ! grep -q "^${secret}=" .env; then
    echo "${secret}=\"YOUR_VALUE_HERE\"" >> .env
    echo "Added missing secret $secret to .env with placeholder value."
    ADDED_NEW_SECRET=true
  fi
done

if [ "$ADDED_NEW_SECRET" = true ]; then
  echo "Please fill in the new placeholder values in your .env file and run this script again."
  exit 0
fi

echo "Syncing secrets from .env to GitHub Actions..."

# Read each line in the .env file
while IFS='=' read -r key value; do
  # Skip empty lines, comments, and carriage returns
  key=$(echo "$key" | tr -d '\r')
  value=$(echo "$value" | tr -d '\r')
  
  if [[ -z "$key" || "$key" == \#* ]]; then
    continue
  fi
  
  # Remove potential surrounding quotes from the value
  value=$(echo "$value" | sed -e 's/^"//' -e 's/"$//' -e "s/^'//" -e "s/'$//")
  
  # Skip if the placeholder is still there
  if [[ "$value" == "YOUR_VALUE_HERE" ]]; then
    echo "Skipping $key: Placeholder value detected."
    continue
  fi
  
  echo "Setting secret: $key"
  echo "$value" | gh secret set "$key"
  
done < .env

echo "Sync complete!"
