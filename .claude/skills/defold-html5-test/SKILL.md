---
name: defold-html5-test
description: Build, serve, and test a Defold HTML5 game in the browser. Covers Bob CLI build, dev server, cache clearing, and interacting with the game canvas via TouchEvent/KeyboardEvent — without stealing the user's mouse.
---

# Defold HTML5 Build & Test

## 1. Build HTML5 bundle (Bob CLI)

```bash
JDK="/Applications/Defold.app/Contents/Resources/packages/jdk-25+36/bin/java"
JAR=$(ls /Applications/Defold.app/Contents/Resources/packages/defold-*.jar | head -1)

"$JDK" -Dcom.google.protobuf.use_unsafe_pre22_gencode -cp "$JAR" com.dynamo.bob.Bob \
  --root . --platform js-web --variant debug --archive \
  build bundle --bundle-output bundle/
```

Verify success by checking the archive timestamp:
```bash
ls -lh bundle/crossyDefold/archive/game0.arcd
```

A non-fatal SEVERE error about `java.io.File.exists()` is harmless — ignore it.

## 2. Start dev server

```bash
cd bundle/crossyDefold && python3 -m http.server 8888
```

Open browser at `http://localhost:8888`.

## 3. Clear browser cache (REQUIRED after every rebuild)

Defold caches the game archive in IndexedDB — the browser will load the old version unless you clear it.

Run this in the browser console or via `javascript_tool`:

```js
const dbs = await indexedDB.databases()
for (const db of dbs) indexedDB.deleteDatabase(db.name)
location.reload()
```

Wait for the game to fully reload before testing.

## 4. Interact with the game

**IMPORTANT: NEVER use `computer left_click` to interact with the game.** It steals the user's real mouse cursor. TouchEvent/MouseEvent dispatched from JS are also rejected by Defold (browser marks them `isTrusted=false`).

### Click a UI button — `window._defoldTap`

The correct approach is a JS bridge exposed by `main.script`. Set `window._defoldTap` to the GUI node name and Defold picks it up on the next frame:

```js
window._defoldTap = "btn_play"
```

To find valid node names: read the project's `.gui` files — every `id:` field is a valid node name. Example from `main/game.gui`:
- `btn_play`, `btn_characters` — home screen
- `btn_up`, `btn_down`, `btn_left`, `btn_right` — d-pad
- `btn_home`, `btn_shadow_toggle` — top bar
- `btn_char_prev`, `btn_char_next`, `btn_char_select`, `btn_char_back` — char select

The bridge is implemented in `main.script` — read it to see the full `NODE_ACTIONS` map.

### Send key input (KeyboardEvent)

First read `input/game.input_binding` to see which keys are bound to which actions. Then dispatch accordingly:

```js
// Replace 'x' and keyCode with the actual key from input bindings
document.dispatchEvent(new KeyboardEvent('keydown', { key: 'x', keyCode: 88, bubbles: true }))
document.dispatchEvent(new KeyboardEvent('keyup',   { key: 'x', keyCode: 88, bubbles: true }))
```

Common keyCode values: A=65 B=66 ... W=87 X=88 ... Space=32 ArrowUp=38 ArrowDown=40 ArrowLeft=37 ArrowRight=39

## 5. Observe results

After each interaction, take a screenshot to verify the result:

```
computer screenshot  →  full view
computer zoom [x0,y0,x1,y1]  →  inspect a specific area
```

Read game logs with:
```
read_console_messages pattern="DEBUG:SCRIPT"
```

## 6. Workflow summary

1. Build → verify `game0.arcd` timestamp
2. Clear IndexedDB → reload
3. Use `javascript_tool` + TouchEvent/KeyboardEvent to interact
4. Use `computer screenshot` / `zoom` to observe
5. Read console logs to confirm state
