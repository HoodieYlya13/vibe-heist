#!/bin/bash
set -e

# Define directories
ROOT_DIR=$(pwd)

# ==========================================
# 0. Setup Private Submodules
# ==========================================
if [ -n "$GITHUB_TOKEN" ]; then
    echo "🔑 Configuring Git to use GITHUB_TOKEN..."
    git config --global url."https://x-access-token:${GITHUB_TOKEN}@github.com/HoodieYlya13/vibe-heist-client.git".insteadOf "https://github.com/HoodieYlya13/vibe-heist-client.git"
    
    echo "🔄 Updating submodules..."
    git submodule deinit -f .
    git submodule update --init --recursive
else
    echo "⚠️ GITHUB_TOKEN not found. Skipping authenticated submodule update."
fi

echo "🚀 Starting Vibe Heist Vercel Build..."

# ==========================================
# 1. Setup Rust & WASM Target
# ==========================================
echo "🔧 Setting up Rust toolchain..."

setup_rust() {
    echo "⬇️  Installing/Updating Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
}

if ! command -v rustup &> /dev/null; then
    setup_rust
else
    if ! rustup target add wasm32-unknown-unknown; then
        echo "⚠️ System Rust detected without WASM support. Switching to local Rust..."
        setup_rust
        rustup target add wasm32-unknown-unknown
    fi
fi

if [ -f "$HOME/.cargo/env" ]; then
    source "$HOME/.cargo/env"
fi

# ==========================================
# 2. Install wasm-pack
# ==========================================
if ! command -v wasm-pack &> /dev/null; then
    echo "⬇️  Installing wasm-pack..."
    curl https://rustwasm.github.io/wasm-pack/installer/init.sh -sSf | sh
fi

# ==========================================
# 3. Build Rust Simulation
# ==========================================
echo "🦀 Building Vibe Engine..."
cd sim
wasm-pack build --target web
cd ..

# ==========================================
# 4. Build Game Client (The Fix is Here)
# ==========================================
echo "🎮 Building Game Client..."
cd client
# 👇 FIX: Force install devDependencies (TypeScript & Vite)
npm install --include=dev 
npm run build
cd ..

# ==========================================
# 5. Move Assets to Web
# ==========================================
echo "📦 Moving Game to Website..."
rm -rf web/public/play
mkdir -p web/public/play
cp -r client/dist/* web/public/play/

# ==========================================
# 6. Build Web (Next.js)
# ==========================================
echo "🌐 Building Next.js..."
cd web
# 👇 FIX: Force install devDependencies (Tailwind, Types, etc.)
npm install --include=dev
npm run build