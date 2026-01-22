#!/bin/bash
set -e

# Create MCP config
mkdir -p /data/mcp-configs
cat > /data/mcp-configs/mcp.json << 'EOF'
{
  "mcpServers": {
    "n8n-mcp": {
      "type": "http",
      "url": "https://api.n8n-mcp.com/mcp"
    },
    "supabase": {
      "type": "http",
      "url": "https://mcp.supabase.com/mcp?project_ref=qvawbxpijxlwdkolmjrs&features=storage%2Cbranching%2Cfunctions%2Cdevelopment%2Cdebugging%2Cdatabase%2Caccount%2Cdocs"
    },
    "railway": {
      "command": "npx",
      "args": ["@railway/mcp-server"]
    }
  }
}
EOF

# Create .env file
cat > /data/.env << EOF
LINEAR_DIRECT_WEBHOOKS=true
CYRUS_BASE_URL=${CYRUS_BASE_URL}
CYRUS_SERVER_PORT=${CYRUS_SERVER_PORT:-3456}
LINEAR_CLIENT_ID=${LINEAR_CLIENT_ID}
LINEAR_CLIENT_SECRET=${LINEAR_CLIENT_SECRET}
LINEAR_WEBHOOK_SECRET=${LINEAR_WEBHOOK_SECRET}
CLAUDE_CODE_OAUTH_TOKEN=${CLAUDE_CODE_OAUTH_TOKEN}
GITHUB_TOKEN=${GITHUB_TOKEN}
EOF

# Create config.json if it doesn't exist (will be populated by self-auth)
if [ ! -f /data/config.json ]; then
  echo '{"repositories":[]}' > /data/config.json
fi

# Configure git
git config --global user.email "cyrus@railway.app"
git config --global user.name "Cyrus"

# Authenticate GitHub CLI
echo "${GITHUB_TOKEN}" | gh auth login --with-token

# Start Cyrus
exec cyrus --env-file=/data/.env
