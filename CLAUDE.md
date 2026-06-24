# Agent Instructions

This repository is a **Defold** game project (Crossy Road clone). The project root is the folder containing `game.project`.

## Project map

- **Root config**: `game.project`
- **Bootstrap**: `main/main.collection` — three GOs: `bootstrap` (main.script), `home_screen` (Monarch proxy), `game_screen` (Monarch proxy)
- **Bootstrap script**: `main/main.script` — shows home screen via `monarch.show("home")` on start; polls `window._defoldCmd` (HTML5 JS bridge) each frame; routes commands to the active screen
- **Monarch screen registration**: `main/home_screen.go` and `main/game_screen.go` — each has `screen_proxy.script` + embedded `collectionproxy`
- **Home screen**: `scenes/home/` — `home.go`, `home.gui`, `home.gui_script` (uses `monarch.show("game")` to navigate)
- **Home collection**: `scenes/home/home.collection` — loaded by Monarch via proxy
- **Game collection** (loaded by Monarch via proxy): `scenes/game/game.collection` → `main/controller.go`
  - `main/gameplay_controller.script` — all game logic + states (STATE_PLAYING, STATE_CHAR_SELECT, STATE_DEAD); uses `monarch.show("home")` for go_home
  - `main/game.gui` + `main/game.gui_script` — all in-game UI (gameplay controls, char select overlay)
- **Game objects**: `objects/` (cars, chicken, obstacles, etc.)
- **Assets**: `assets/` (app icons, images, atlas)
- **Render pipeline**: `render/` (custom render script)
- **Input bindings**: `input/`
- **Dependencies (read-only context)**: `.deps/` (if present after running `defold-project-setup`)

Key Defold settings from `game.project`:
- **Bootstrap collection**: `/main/main.collection`
- **Render script**: `/render/game.render`
- **Input binding**: `/input/game.input_binding`
- **Shared state**: enabled (`script.shared_state = 1`)

**Resource paths in `game.project`**: Values like `main_collection`, `game_binding` use Defold resource identifiers. A trailing `c` suffix denotes compiled resources and is expected — do not treat it as a typo.

## Skills

When you need to perform specific tasks, load the corresponding skill file first by reading it with the Read tool. Skill files are located in `.claude/skills/<skill-name>/SKILL.md`.

| Task | Skill |
|------|-------|
| Look up Defold Lua/C++ API | `.claude/skills/defold-api-fetch/SKILL.md` |
| Look up Defold manuals & concepts | `.claude/skills/defold-docs-fetch/SKILL.md` |
| Find practical Defold code examples | `.claude/skills/defold-examples-fetch/SKILL.md` |
| Search Defold Asset Store for libraries | `.claude/skills/defold-assets-search/SKILL.md` |
| Create/edit `.collection`, `.go`, `.atlas`, `.gui`, etc. | `.claude/skills/defold-proto-file-editing/SKILL.md` |
| Create/edit `.script`, `.gui_script`, `.lua` | `.claude/skills/defold-scripts-editing/SKILL.md` |
| Create/edit `.vp`, `.fp`, `.glsl` shaders | `.claude/skills/defold-shaders-editing/SKILL.md` |
| Build & test HTML5 in browser | `.claude/skills/defold-html5-test/SKILL.md` |
| Download dependencies into `.deps/` | `.claude/skills/defold-project-setup/SKILL.md` |
| Create/edit C++ native extensions | `.claude/skills/defold-native-extension-editing/SKILL.md` |
| Set up Monarch screens/popups | `.claude/skills/monarch-screen-setup/SKILL.md` |
| Use xmath for zero-allocation math | `.claude/skills/xmath-usage/SKILL.md` |
| Update/maintain skill files | `.claude/skills/defold-skill-maintain/SKILL.md` |
| Handle multiple screen sizes / responsive layout | `.claude/skills/defold-responsive-screen/SKILL.md` |
| Planar shadow setup and multi-mesh overdraw fix | `.claude/skills/defold-shadow/SKILL.md` |

## Defold file formats

- **Lua scripts**: `.lua`, `.script`, `.gui_script`, `.render_script`, `.editor_script`.
- **Metadata assets** (Protocol Buffer Text Format): `.collection`, `.go`, `.sprite`, `.tilemap`, `.tilesource`, `.atlas`, `.font`, `.particlefx`, `.sound`, `.label`, `.gui`, `.model`, `.mesh`, `.material`, `.collisionobject`, `.texture_profiles`, `.display_profiles`.
- **Manifests** (YAML): `.appmanifest`, `.manifest` - platform-specific libraries and build flags.
- **Buffers** (JSON): `.buffer` - streams of data (positions, colors, etc.) used as input for Mesh components.
- **Shaders** (GLSL): `.vp`, `.fp`, `.glsl`.
- **Project config** (INI): `game.project`.
- **Properties** (INI): `game.properties`, `ext.properties`.
- **2D assets**: `.png`, `.jpg`.
- **3D assets** (GLTF): `.gltf`, `.glb`.
- **Sound assets**: `.ogg`, `.wav`, `.opus`.

## Editing Defold assets

When creating or editing Defold asset files, read `.claude/skills/defold-proto-file-editing/SKILL.md` to get the correct file format and structure. Always load the skill **before** writing or modifying the file.

When writing performance-critical math code or optimizing vector/quaternion/matrix operations, read `.claude/skills/xmath-usage/SKILL.md` first (only if project has xmath dependency).

## Code style guidelines

### Lua scripts (.lua, .script, .gui_script, .render_script, .editor_script)

- **Indentation**: 1 tab (4 spaces).
- **Naming**: `snake_case` for variables, functions, files, and folders. Keep resource paths absolute (`/assets/...`) where Defold expects them.
- **Comments**: Use **LuaCATS** (`---@...`) annotations for types, module/public API docs.
- **Whitespace**: Empty lines must be truly empty (no spaces/tabs). Avoid trailing whitespace.
- **Defold API**: strictly follow the Defold API — always verify against official documentation using `defold-api-fetch` skill. There are no hidden or undocumented APIs — only use functions, messages, and properties that are explicitly described in the docs.
- **Defensive checks**: Do NOT assume data is missing or constantly re-check field existence in tables. If YOU set a field, it EXISTS. Do NOT check for standard Lua API availability (e.g., `io` and `io.open` always exist). Avoid unnecessary defensive programming.
- **Paradigm**: do not use metatables or imitate classes. Use functional, data-based structures only.
- **Logging**: use `print()` to look at the game state. Add logs for transactions, initializations, important events.
- **GUI and game state separation**: GUI scripts (`.gui_script`) should NOT directly access game logic modules. All communication between game logic and UI must be message-based (`msg.post()`) to maintain clear separation of concerns.
- **Script instance state**: In `.script`, `.gui_script`, `.render_script` files, store instance-specific state in the `self` table, NOT in local module variables. Local variables at the module level are shared across ALL instances of the script. Use `self.my_variable` instead of `local my_variable`. Not applicable for local functions.
- **Local functions**: NEVER create local functions inside other functions. Local functions are only allowed at module scope. Anonymous lambda functions (inline callbacks) are acceptable.
- **require**:
  - Always call `require` with parentheses: `require("module")`, NOT `require "module"`.
  - Use dot notation for module paths: `require("main.scene_mgr")`, NOT `require("/main/scene_mgr")`.
  - Module paths are relative to the project root and use dots (`.`) as separators.
  - Do NOT use leading slashes in require paths.
- **Hash values**: `hash("...")` can be left inline. If you need to reuse a hash value multiple times, declare it as a module-level constant in `UPPER_CASE` format: `local TRIGGER_RESPONSE = hash("trigger_response")`.
- **Constants**: Module-level constants can be declared as local variables in `UPPER_CASE` format.
- **msg.url format**: Always remember the format `[socket:][path][#fragment]`:
  - `socket` - collection name (world)
  - `path` - game object instance id (can be relative or global)
  - `fragment` - component id
  - Shorthands: `"."` for current game object, `"#"` for current component
  - Examples: `msg.url("#my_component")`, `msg.url("collection:/path/to/go#component")`
- **Omit unused callbacks**: especially `update()` and `fixed_update()` which cost a call per frame even if empty.

## Shell

- **macOS**: use zsh.

## Commands

All commands run from the project root (the folder with `game.project`).

- **Build & Run via editor**: use the `defold-project-build` skill. Requires the Defold editor to be running with the project open.
- **Build HTML5 bundle (CLI)**: requires `--archive` flag:
  ```
  "$JDK" -Dcom.google.protobuf.use_unsafe_pre22_gencode -cp "$JAR" com.dynamo.bob.Bob \
    --root . --platform js-web --variant debug --archive \
    build bundle --bundle-output bundle/
  ```
  JDK = `/Applications/Defold.app/Contents/Resources/packages/jdk-25+36/bin/java`
  JAR = `/Applications/Defold.app/Contents/Resources/packages/defold-*.jar`
- **HTML5 dev server**: `cd bundle/crossyDefold && python3 -m http.server 8888`
- **Clear browser cache**: delete IndexedDB `/data` database before reload (Defold caches game archive there)

## Validation checklist

- Build via the running editor succeeds (`defold-project-build` skill).

## Important repo-specific caveats

- **Git commit messages**: use the following format: `Short description` in English language ONLY.
- **Monarch** (`/monarch/`) is a project dependency — `require("monarch.monarch")` is valid. The `monarch/` directory lives at the project root (copied from `.deps/monarch/`).
- Camera yaw is called `CAM_YAW` (not pitch) — the "chéo" camera angle is horizontal rotation.
- **Screen IDs**: `"home"` (collection name from `scenes/home/home.collection`) and `"game"` (collection name from `scenes/game/game.collection`). Use these with `monarch.show()`.
- **HTML5 JS bridge**: `window._defoldCmd` is polled each frame by `main.script` via `html5.run()`. Set it from JS to trigger in-game actions (e.g. `window._defoldCmd = "tap_play"`). Cleared after each read.
- **JS bridge routing**: uses `monarch.top()` to detect current screen — if `hash("home")` routes to `home:/home#gui` as `test_cmd`; if `hash("game")` routes to `game:/controller#script`.
