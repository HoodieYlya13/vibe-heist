# Vibe Heist (Monorepo Root) 🕵️‍♂️

**Status:** 🚧 In Active Development

This is the public root repository for the _Vibe Heist_ open-world browser game, powered by **WebGPU** and **WebAssembly**. It orchestrates the submodules and the private game client.

## 📂 Structure

- **`sim/` (Submodule)**: Public Rust physics engine.
- **`web/` (Submodule)**: Public Next.js launcher & marketing site.
- **`client/` (Private Submodule)**: The core TypeScript game logic, assets, and netcode.
- **`vercel-build.sh`**: The master deployment script.

## 🚀 Quick Start

### 1. Initialize Submodules

```bash
git submodule update --init --recursive
```

### 2. Run the Greybox (Local Dev)

```bash
cd client
npm install && npm run dev
```

### 3. Deploy to Vercel (Production)

Pushing to `main` triggers the `vercel-build.sh` script, which compiles the Rust engine, builds the game client, and injects the artifacts into the Next.js web portal.
