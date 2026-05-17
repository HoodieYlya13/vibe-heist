# Vibe Heist (Monorepo Root) 🕵️‍♂️

**Status:** 🚧 In Active Development

This is the public root repository for the _Vibe Heist_ open-world browser game, powered by **WebGPU** and **WebAssembly**. It orchestrates the submodules and the private game client.

## ✨ About Vibe Heist

_Vibe Heist_ is an ambitious project to create a high-fidelity, open-world driving and action game that runs entirely in the browser. We are rejecting standard web game patterns in favor of a native-performance architecture.

### 🏎️ Tech Highlights
- **Native Performance:** The core game simulation is written in Rust and compiled to WebAssembly (WASM) for high-speed execution.
- **Next-Gen Web Graphics:** Rendering is powered by Babylon.js running on the new **WebGPU** standard for console-quality visuals in a browser tab.
- **Extreme Decoupling (Shared Memory):** The simulation "brain" (Rust) and the visual "eyes" (JS/Babylon) are strictly separated. JavaScript is kept minimal and acts merely as the "glue". To avoid slow message passing, both layers read from the same shared memory buffer (RAM), allowing zero-copy communication at native speeds.

## 📂 Structure

- **`sim/` (Submodule)**: Public Rust physics engine.
- **`web/` (Submodule)**: Public Next.js launcher & marketing site.
- **`client/` (Private Submodule)**: The core TypeScript game logic, assets, and netcode.
- **`vercel-build.sh`**: The master deployment script.

## 🚀 Quick Start

> [!NOTE]
> **Collaborator Access Only:** Because the `client` directory is a private submodule, only invited collaborators with access to that repository can pull the code and run this project locally. However, the public can still play the live version!

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
