# Vibe Heist — instructions for AI agents

A photoreal open-world crime game set in Miami that runs in a browser tab: Rust/WASM simulation, Babylon.js WebGPU rendering. The bar is a current-generation open-world console game; low-poly, stylized or "good enough for web" is a defect. Read `client/PRD.md` (what and why) and `client/ROADMAP.md` (status and next work) before proposing direction.

## Repositories

The root repo only pins three submodules. Each is its own git repository — commit inside the submodule, then bump the pointer in the root.

| Path | What | Stack |
|---|---|---|
| `sim/` | Simulation: physics, vehicles, traffic, crowd, police. Source of truth for all game state. | Rust 2024, Rapier3d, wasm-bindgen |
| `client/` | Rendering, input, audio, HUD, world generation. Holds the PRD and roadmap. | TypeScript 7, Vite 8, Babylon.js 9 (WebGPU only) |
| `web/` | Launcher and marketing site that hosts the built client under `/play/`. | Next.js 16 (rules in `.agents/rules/nextjs16.md`) |

## Commands

```bash
# sim/
cargo test                                  # deterministic replay suites (native, no browser)
cargo clippy --all-targets -- -D warnings && cargo fmt --check
cargo run --bin gen_layout                  # regenerate client/src/generated/sim-layout.ts after changing constants.rs
wasm-pack build --target web                # rebuild sim/pkg — required before the client sees any sim change

# client/
npm run typecheck
npm run build
npm run test:smoke                          # Playwright, headless Chrome with real WebGPU; starts the dev server itself
/Applications/Blender.app/Contents/MacOS/Blender -b --python scripts/car-models/build_car.py -- --car sedan --out public/models/car-sedan.glb   # rebuild a car model (sedan | sports | truck); --preview <dir> renders it
/Applications/Blender.app/Contents/MacOS/Blender -b --python scripts/vegetation/build_palms.py -- --out public/models/props/palm_trees/palm_trees.gltf   # rebuild the street palms
```

The dev server is the `game-client` entry in `.claude/launch.json` (port 5199, served under `/play/`). URL switches: `?test=1` (dev console and `window.__vibe` handle), `?world=arena` (physics test arena), `?quality=ultra`.

## Rules

1. **Fidelity first.** Everything rendered is physically based. Materials come from `client/src/render/materials.ts` (`MaterialLibrary`); never create a material inside a system, never use `StandardMaterial` for lit geometry. Author at real-world scale in meters.
2. **The sim owns the game.** No gameplay state or rules in the client — it sends input and draws snapshots. Presentation-only models (camera feel, audio rev model) may live client-side and must never feed back.
3. **Determinism.** Fixed timestep, seeded RNG, sorted iteration, no wall clock in sim logic.
4. **One source of truth.** Shared constants live in `sim/src/constants.rs` and reach TypeScript through `gen_layout`; city dimensions live in `client/src/world/dimensions.ts`. Never hand-copy a number across the boundary.
5. **A bug gets a failing test first**, then the fix. Sim behavior → `sim/tests/`; boot/render regressions → `client/tests/`.
6. **Look at the frame.** A visual change is verified by capturing frames at noon, sunset and night and reading them — not by reasoning. See "Verifying renders" below.
7. **Assets.** Every asset is logged in `client/ASSETS_LICENSES.md`; CC0 or paid-with-game-license only. Ask the owner before downloading anything.
8. **Original game.** No names, characters, maps, logos, vehicles' trade dress or music from existing games or real brands (PRD §11).
9. **Docs stay current and short.** PRD = what/why, ROADMAP = status. No progress diaries in either; history goes to `client/docs/history/`.
10. **Code style** follows the owner's global instructions: intent-revealing names, small single-purpose functions, no explanatory multi-line comments, rare one-line comments only for the non-obvious.

## Verifying renders

The in-app browser pane does not present WebGPU frames while it is hidden, so screenshots from it can be blank. Use headless Chrome instead (`channel: "chrome"`, args `--enable-unsafe-webgpu --use-angle=metal`), as `client/playwright.config.ts` does:

- The game starts paused behind pointer lock; `client/tests/smoke.spec.ts` shows the shim that resumes it.
- `window.__vibe` (test mode) exposes `scene`, `camera`, `bridge`, `lighting`, `materials`, `worldStreaming` and the render systems. `bridge.sendDev({ cmd: "set-time", fraction })` pins the time of day (0.5 noon, 0.74 sunset, 0 midnight).
- Treat any `WebGPU uncaptured error` in the console as a failure: one invalid pipeline blanks the whole frame.
- Measure frame rate at the owner's screen size (viewport 1728×1117 at device scale factor 2), while driving, never at the 1280×720 capture size: the frame costs about eight times more there.

## Engine facts that cost time once

- Babylon front faces are counter-clockwise; an inverted quad is culled, not dark.
- The atmosphere must be created before any `PBRMaterial` — it attaches sky lighting to materials at creation.
- Thin instances need a `previousMatrix` buffer or the motion-vector pass invalidates the pipeline (`render/thin-instances.ts`).
- The WebGPU device is requested with maximum limits; the pre-pass needs more color-attachment bytes than the default.
- A material that samples the environment map cannot be rendered into the reflection probe.
- Ambient traffic and police are kinematic bodies: they must stop for obstacles themselves, the solver will not stop them.
- A material plugin that reads UVs on an untextured material must set `_needUVs` and `MAINUV1` in `prepareDefinesBeforeAttributes` (`render/interior-glass-plugin.ts`).
- WGSL derivatives (`fwidth`, `dpdx`) must be called before any branch on per-pixel values, or the shader fails to compile.
- Glass must cast shadows: a facade with open window holes lets sunlight through the building.
- Local lights go through `NightLights` (`render/night-lights.ts`), never straight into the scene: a loose point or spot light recompiles every material. The pool has a fixed capacity because Babylon 9.35 breaks when a clustered container grows.
- The clustered container ignores a light's enabled state; switch a lamp with `isOn`.
- Screen-space reflections skip anything whose head-on reflectance is under 6%, which is every plain dielectric; lacquer and car glass raise theirs to 8% (`MaterialLibrary.carPaint`).
- The glTF loader rejects a texture URI containing `..`: a model's textures must sit in or under its own folder.
- A post-process's `size` is the size of the texture it reads, so the pass before it renders at that size (`render/bounce-light.ts`).
