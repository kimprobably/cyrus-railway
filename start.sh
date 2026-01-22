#!/bin/bash

# Set CYRUS_HOME early so all cyrus commands use /data
export CYRUS_HOME=/data

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

# Create .env file (always overwrite to ensure correct URL)
cat > /data/.env << EOF
LINEAR_DIRECT_WEBHOOKS=true
CYRUS_BASE_URL=${CYRUS_BASE_URL}
CYRUS_SERVER_PORT=3457
LINEAR_CLIENT_ID=${LINEAR_CLIENT_ID}
LINEAR_CLIENT_SECRET=${LINEAR_CLIENT_SECRET}
LINEAR_WEBHOOK_SECRET=${LINEAR_WEBHOOK_SECRET}
CLAUDE_CODE_OAUTH_TOKEN=${CLAUDE_CODE_OAUTH_TOKEN}
GITHUB_TOKEN=${GITHUB_TOKEN}
EOF

# Only build config.json if it doesn't exist or has no tokens
# (self-auth saves tokens to $CYRUS_HOME/config.json = /data/config.json)
if [ -f /data/config.json ] && grep -q "lin_oauth_" /data/config.json; then
  echo "Using existing config with tokens from self-auth"
else
  echo "Creating config.json from environment variables"
  cat > /data/config.json << EOF
{
  "repositories": [
    {
      "id": "83fafa26-a0c4-4df6-be4d-00d11c4c69e3",
      "name": "cyrus-test-repo",
      "repositoryPath": "/data/repos/cyrus-test-repo",
      "baseBranch": "main",
      "workspaceBaseDir": "/data/worktrees",
      "linearWorkspaceId": "${LINEAR_WORKSPACE_ID}",
      "linearWorkspaceName": "Modern Agency Sales",
      "linearToken": "${LINEAR_TOKEN}",
      "linearRefreshToken": "${LINEAR_REFRESH_TOKEN}",
      "isActive": true,
      "githubUrl": "https://github.com/kimprobably/cyrus-test-repo",
      "projectKeys": ["Cyrus Test"],
      "mcpConfigPath": "/data/mcp-configs/mcp.json"
    },
    {
      "id": "a38ad131-bfae-447c-a7df-9152bd58c273",
      "name": "gc-member-portal",
      "repositoryPath": "/data/repos/gc-member-portal",
      "baseBranch": "main",
      "workspaceBaseDir": "/data/worktrees",
      "linearWorkspaceId": "${LINEAR_WORKSPACE_ID}",
      "linearWorkspaceName": "Modern Agency Sales",
      "linearToken": "${LINEAR_TOKEN}",
      "linearRefreshToken": "${LINEAR_REFRESH_TOKEN}",
      "isActive": true,
      "githubUrl": "https://github.com/kimprobably/gc-member-portal",
      "projectKeys": ["GC Member Portal"],
      "mcpConfigPath": "/data/mcp-configs/mcp.json"
    },
    {
      "id": "243a327f-4b5a-4612-8377-7adf43c9dd9a",
      "name": "gtm-system",
      "repositoryPath": "/data/repos/gtm-system",
      "baseBranch": "main",
      "workspaceBaseDir": "/data/worktrees",
      "linearWorkspaceId": "${LINEAR_WORKSPACE_ID}",
      "linearWorkspaceName": "Modern Agency Sales",
      "linearToken": "${LINEAR_TOKEN}",
      "linearRefreshToken": "${LINEAR_REFRESH_TOKEN}",
      "isActive": true,
      "githubUrl": "https://github.com/kimprobably/gtm-system",
      "projectKeys": ["GTM System"],
      "mcpConfigPath": "/data/mcp-configs/mcp.json"
    },
    {
      "id": "a77b8a10-42b5-4e9f-8c1d-ed7dc3f9ddae",
      "name": "linkedin-leadmagnet-migration",
      "repositoryPath": "/data/repos/linkedin-leadmagnet-migration",
      "baseBranch": "main",
      "workspaceBaseDir": "/data/worktrees",
      "linearWorkspaceId": "${LINEAR_WORKSPACE_ID}",
      "linearWorkspaceName": "Modern Agency Sales",
      "linearToken": "${LINEAR_TOKEN}",
      "linearRefreshToken": "${LINEAR_REFRESH_TOKEN}",
      "isActive": true,
      "githubUrl": "https://github.com/kimprobably/linkedin-leadmagnet-migration",
      "projectKeys": ["LinkedIn Leadmagnet"],
      "mcpConfigPath": "/data/mcp-configs/mcp.json"
    },
    {
      "id": "f9e0e607-ee04-4b17-914b-9448b53cb01e",
      "name": "music-creator-analyzer",
      "repositoryPath": "/data/repos/music-creator-analyzer",
      "baseBranch": "main",
      "workspaceBaseDir": "/data/worktrees",
      "linearWorkspaceId": "${LINEAR_WORKSPACE_ID}",
      "linearWorkspaceName": "Modern Agency Sales",
      "linearToken": "${LINEAR_TOKEN}",
      "linearRefreshToken": "${LINEAR_REFRESH_TOKEN}",
      "isActive": true,
      "githubUrl": "https://github.com/kimprobably/music-creator-analyzer",
      "projectKeys": ["Music Creator Analyzer"],
      "mcpConfigPath": "/data/mcp-configs/mcp.json"
    }
  ]
}
EOF

  # Copy to where Cyrus looks by default
  mkdir -p /root/.cyrus
  cp /data/config.json /root/.cyrus/config.json
fi

# Configure git with user info and credentials
git config --global user.email "cyrus@railway.app"
git config --global user.name "Cyrus"

# Configure git to use GITHUB_TOKEN for authentication
git config --global url."https://${GITHUB_TOKEN}@github.com/".insteadOf "https://github.com/"

# Clone repos if they don't exist
mkdir -p /data/repos
cd /data/repos

clone_if_missing() {
  local repo_name=$1
  local repo_url=$2
  if [ ! -d "$repo_name" ]; then
    echo "Cloning $repo_name..."
    git clone "$repo_url" "$repo_name" || echo "Failed to clone $repo_name"
  else
    echo "Repo $repo_name already exists"
  fi
}

clone_if_missing "cyrus-test-repo" "https://github.com/kimprobably/cyrus-test-repo.git"
clone_if_missing "gc-member-portal" "https://github.com/kimprobably/gc-member-portal.git"
clone_if_missing "gtm-system" "https://github.com/kimprobably/gtm-system.git"
clone_if_missing "linkedin-leadmagnet-migration" "https://github.com/kimprobably/linkedin-leadmagnet-migration.git"
clone_if_missing "music-creator-analyzer" "https://github.com/kimprobably/music-creator-analyzer.git"

cd /data

echo "GitHub CLI will use GITHUB_TOKEN from environment"

export CYRUS_HOME=/data

# Check if we need to run self-auth (RUN_SELF_AUTH env var)
if [ "$RUN_SELF_AUTH" = "true" ]; then
  echo "Running self-auth mode..."
  echo "============================================"
  echo "After deployment, check logs for OAuth URL"
  echo "Visit the URL to authorize, callback will hit Railway"
  echo "============================================"
  # self-auth uses CYRUS_SERVER_PORT for callback server
  # Forward Railway port 3456 -> self-auth on 3457
  export CYRUS_SERVER_PORT=3457
  socat TCP-LISTEN:3456,fork,reuseaddr,bind=0.0.0.0 TCP:127.0.0.1:3457 &
  sleep 1
  exec cyrus self-auth --env-file=/data/.env
else
  # Normal mode - start socat proxy and cyrus
  echo "Starting port proxy..."
  socat TCP-LISTEN:3456,fork,reuseaddr,bind=0.0.0.0 TCP:localhost:3457 &

  # Copy config to where Cyrus looks for it
  mkdir -p /root/.cyrus
  cp /data/config.json /root/.cyrus/config.json
  echo "Copied config.json to /root/.cyrus/"

  echo "Starting Cyrus..."
  export CYRUS_SERVER_PORT=3457
  exec cyrus --env-file=/data/.env
fi
