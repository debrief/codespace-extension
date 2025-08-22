#!/bin/bash
echo "Downloading and installing extension from CI artifact..."

# Store current directory and repository info
ORIGINAL_DIR=$(pwd)
BRANCH=$(git branch --show-current)
echo "Current branch: $BRANCH"

# Download artifact using GitHub CLI if available, otherwise fallback to local build
if command -v gh &> /dev/null; then
    echo "Downloading artifact from GitHub..."
    
    # Get the latest successful workflow run for this branch
    RUN_ID=$(gh run list --workflow=build-extension.yml --branch="$BRANCH" --status=success --limit=1 --json databaseId --jq '.[0].databaseId')
    
    if [ -n "$RUN_ID" ] && [ "$RUN_ID" != "null" ]; then
        echo "Found workflow run: $RUN_ID"
        
        # Download the artifact to temp location
        TEMP_DIR=$(mktemp -d)
        cd "$TEMP_DIR"
        
        # Use the original directory context for gh commands
        if (cd "$ORIGINAL_DIR" && gh run download $RUN_ID --name extension-vsix --dir "$TEMP_DIR"); then            
            if [ -f "extension.vsix" ]; then
                echo "Installing extension: extension.vsix"
                code --install-extension "extension.vsix" --force
                echo "Extension installed successfully from CI artifact"
                
                # Cleanup
                cd "$ORIGINAL_DIR"
                rm -rf "$TEMP_DIR"
                
                # Open workspace folder now that extension is ready
                echo "Opening workspace folder with extension ready..."
                code workspace --add
                
                touch install-complete
                exit 0
            fi
        fi
        
        # Cleanup on failure
        cd "$ORIGINAL_DIR"
        rm -rf "$TEMP_DIR"
    fi
    
    echo "No recent CI artifact found, falling back to local build..."
fi

# Fallback: build locally
echo "Building extension locally..."
npm install
npm run compile
npx @vscode/vsce package --out extension.vsix

if [ -f "extension.vsix" ]; then
    code --install-extension extension.vsix --force
    echo "Extension installed successfully (local build)"
    
    # Open workspace folder now that extension is ready
    echo "Opening workspace folder with extension ready..."
    code workspace --add
    
    touch install-complete
else
    echo "VSIX file not found"
    exit 1
fi