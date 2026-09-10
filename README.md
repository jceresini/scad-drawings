# Plaque

> Requires OpenSCAD nightly for `textmetrics()` support.

### Text

| Parameter | Default | Description |
|---|---|---|
| `text_lines` | `["Hello World"]` | Lines of text. Each string is one line, stacked top to bottom. Example: `["123", "Main St"]` |
| `text_size` | `12` | Font size in mm |
| `text_font` | `"Liberation Sans:style=Bold"` | Any font installed on your system. Format: `"Font Name:style=Style"` |
| `text_depth` | `4` | How much the text is raised above the base surface (mm) |
| `text_line_spacing` | `1.2` | Gap between lines, as a multiplier of `text_size` |

### Padding

The base width and depth are computed automatically:

```
base_width = widest_line + 2 × pad_x
base_depth = text_block_height + 2 × pad_y
```

| Parameter | Default | Description |
|---|---|---|
| `pad_x` | `15` | Space on the left and right (mm) |
| `pad_y` | `15` | Space on the top and bottom (mm) |

### Base

| Parameter | Default | Description |
|---|---|---|
| `base_height` | `5` | Thickness of the flat base (mm) |

### Corners

| Parameter | Default | Description |
|---|---|---|
| `corner_style` | `0` | `0` = concave circle, `1` = chamfer (45°) |
| `corner_radius` | `8` | Radius of the circular cutout at each corner (mm). Used when `corner_style = 0` |
| `corner_inset` | `0` | Moves the circle center inward from the corner vertex. `0` = centered on corner. Used when `corner_style = 0` |
| `chamfer_size` | `8` | Length cut from each side of a corner (mm). Used when `corner_style = 1` |

### Raised border

A frame that sits on top of the base, slightly inset from the edges. Its corners follow the same style as the base corners.

| Parameter | Default | Description |
|---|---|---|
| `border_inset` | `2` | Distance from base edge to outer wall of the border (mm) |
| `border_height` | `2` | Height of the border above the base surface (mm) |
| `border_thickness` | `3` | Wall thickness of the border (mm) |

### Mounting

| Parameter | Default | Description |
|---|---|---|
| `mount_style` | `0` | See table below |
| `mount_edge_spacing` | `10` | Distance from the edge to the hole/pocket center (mm) |
| `hole_diameter` | `4` | Screw hole diameter (mm) |
| `magnet_radius` | `5` | Magnet pocket radius (mm) |
| `magnet_thickness` | `2` | Magnet pocket depth (mm) — must be less than `base_height` |

| `mount_style` | Description |
|---|---|
| `0` | No mounting features |
| `1` | Through-holes on left and right sides, centered vertically |
| `2` | Through-holes on top and bottom, centered horizontally |
| `3` | Magnet pockets on left and right sides, centered vertically |
| `4` | Magnet pockets on top and bottom, centered horizontally |

Magnet pockets are blind holes in the back of the base — glue a disc magnet into each one.

### Quality

| Parameter | Default | Description |
|---|---|---|
| `$fn` | `64` | Circle/sphere resolution. Increase for smoother curves, decrease to speed up preview |
