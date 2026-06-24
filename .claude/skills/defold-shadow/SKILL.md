---
name: defold-shadow
description: "How planar shadow works in this project, how to add it to new characters, and how to fix multi-mesh shadow fragmentation via stencil buffer."
---

# Defold Planar Shadow

## How it works in this project

Each player GO has two model components:
- `model` — the lit model (uses `model_lit.material`, tag: `model`)
- `pshadow` — the shadow projection (uses `model_planar_shadow.material`, tag: `planar_shadow`)

The `pshadow` component uses the **same mesh** as `model` but a different material that projects the mesh flat onto the ground plane.

The render script (`render/game.render_script`) draws all `planar_shadow`-tagged components in a single pass before drawing the lit models.

## Adding shadow to a new character

1. Create `objects/char_<name>_pshadow.model`:
```
mesh: "/assets/characters/<name>/<file>.gltf"
material: "/render/model_planar_shadow.material"
name: "char_<name>_pshadow"
```

2. Add `pshadow` component to the player/preview GO:
```
components {
  id: "model"
  component: "/objects/char_<name>.model"
}
components {
  id: "pshadow"
  component: "/objects/char_<name>_pshadow.model"
}
```

## Multi-mesh shadow fragmentation problem

**Symptom:** Shadow looks patchy/fragmented — darker blobs where mesh parts overlap.

**Root cause:** If a character's GLTF has multiple separate meshes (e.g. Erwin has 8: Body, Buttons, Hair, Eyes, Tie, Glasses, Mustache, Eyebrows), each mesh renders its own shadow projection. Where projections overlap, alpha accumulates → darker patches.

Characters with a single mesh (Chicken, Fox, Goose) are not affected.

## Fix: stencil buffer in render script

In `render/game.render_script`, wrap the planar shadow draw with stencil:

```lua
-- Planar shadows (stencil prevents multi-mesh overdraw)
render.set_depth_mask(false)
render.enable_state(graphics.STATE_BLEND)
render.disable_state(graphics.STATE_CULL_FACE)
render.enable_state(graphics.STATE_STENCIL_TEST)
render.set_stencil_func(graphics.COMPARE_FUNC_NOTEQUAL, 1, 0xff)
render.set_stencil_op(graphics.STENCIL_OP_KEEP, graphics.STENCIL_OP_KEEP, graphics.STENCIL_OP_REPLACE)
render.draw(self.planar_shadow_pred)
render.disable_state(graphics.STATE_STENCIL_TEST)
```

**How it works:**
- `NOTEQUAL ref=1`: only draw where stencil value ≠ 1
- `REPLACE` on pass: write 1 to stencil when drawn
- First mesh at a pixel: stencil=0 → passes → draws shadow → writes stencil=1
- Second mesh at same pixel: stencil=1 → fails → skipped
- Result: each pixel receives exactly one shadow draw regardless of mesh count

The stencil buffer is cleared to 0 at the start of every frame:
```lua
render.clear({
    [graphics.BUFFER_TYPE_COLOR0_BIT]  = self.clear_col,
    [graphics.BUFFER_TYPE_STENCIL_BIT] = 0,
})
```

**Performance:** Near zero cost — stencil test is hardware-accelerated and early-rejects subsequent fragments before the fragment shader runs. This fix applies to all characters automatically.

## Alternative approaches (not used)

- **Blob shadow**: a flat dark ellipse sprite under the character — simplest, used by Crossy Road original, no projection math needed
- **Single-mesh shadow**: merge all GLTF meshes with `npx @gltf-transform/cli join` before importing — fixes overdraw at the asset level but requires per-character processing
