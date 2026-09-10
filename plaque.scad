/* [Text] */
// Lines of text to display (one string per line)
text_lines = ["Hello World"];
// Font size (mm)
text_size = 12;
// Font name — must be installed on your system
text_font = "Liberation Sans:style=Bold";
// How much the text is raised above the base surface (mm)
text_depth = 4;
// Spacing between lines as a multiplier of text_size
text_line_spacing = 1.2;

/* [Padding] */
// Extra space on left and right between text and base edge (mm)
pad_x = 15;
// Extra space on top and bottom between text and base edge (mm)
pad_y = 15;

/* [Base Size] */
// Thickness of the base (mm)
base_height = 5;

line_widths = [for (l = text_lines) textmetrics(l, size = text_size, font = text_font).size.x];
line_height  = textmetrics(text_lines[0], size = text_size, font = text_font).size.y;
base_width = max(line_widths) + 2 * pad_x;
base_depth = line_height + (len(text_lines) - 1) * text_size * text_line_spacing + 2 * pad_y;

/* [Corners] */
// 0 = concave circle, 1 = chamfer (45°)
corner_style = 0;
// Radius of the concave circle cutout (mm) — corner_style 0 only
corner_radius = 8;
// Inset from corner vertex (mm) — corner_style 0 only
corner_inset = 0;
// Length cut from each side of a corner (mm) — corner_style 1 only
chamfer_size = 8;

/* [Raised Border] */
// Distance from base edge to outer wall of the border (mm)
border_inset = 2;
// Height of the raised border above the base (mm)
border_height = 2;
// Thickness of the border walls (mm)
border_thickness = 3;

/* [Mounting] */
// 0 = none, 1 = screw holes left+right, 2 = screw holes top+bottom,
//           3 = magnet pockets left+right, 4 = magnet pockets top+bottom
mount_style = 0;
// Distance from edge to hole/pocket center (mm)
mount_edge_spacing = 10;
// Screw hole diameter (mm)
hole_diameter = 4;
// Magnet radius (mm)
magnet_radius = 5;
// Magnet thickness / pocket depth (mm) — must be less than base_height
magnet_thickness = 2;

/* [Quality] */
// Circle/sphere resolution (segments)
$fn = 64;

// 2D rectangle with concave quarter-circles at each corner.
module concave_corner_rect(w, d, cr) {
    safe_cr = min(cr, w / 2, d / 2);
    difference() {
        square([w, d]);
        for (x = [0, w])
            for (y = [0, d])
                translate([x, y])
                    circle(r = safe_cr);
    }
}

// 2D rectangle with 45° chamfers at each corner.
module chamfered_rect(w, d, cs) {
    safe_cs = min(cs, w / 2, d / 2);
    polygon([
        [safe_cs, 0],        [w - safe_cs, 0],
        [w, safe_cs],        [w, d - safe_cs],
        [w - safe_cs, d],    [safe_cs, d],
        [0, d - safe_cs],    [0, safe_cs]
    ]);
}

module plaque() {
    eff_cr = min(corner_radius,
                 (base_width  - 2 * corner_inset) / 2,
                 (base_depth  - 2 * corner_inset) / 2);
    eff_cs = min(chamfer_size, base_width / 2, base_depth / 2);

    mount_positions =
        (mount_style == 1 || mount_style == 3) ? [
            [mount_edge_spacing,              base_depth / 2],
            [base_width - mount_edge_spacing, base_depth / 2]
        ] : (mount_style == 2 || mount_style == 4) ? [
            [base_width / 2, mount_edge_spacing],
            [base_width / 2, base_depth - mount_edge_spacing]
        ] : [];

    // Base
    difference() {
        cube([base_width, base_depth, base_height]);

        // Corner cuts
        if (corner_style == 0) {
            for (x = [corner_inset, base_width  - corner_inset])
                for (y = [corner_inset, base_depth - corner_inset])
                    translate([x, y, -0.01])
                        cylinder(r = eff_cr, h = base_height + 0.02);
        } else {
            for (cx = [0, base_width])
                for (cy = [0, base_depth])
                    let(sx = (cx == 0) ? eff_cs : -eff_cs,
                        sy = (cy == 0) ? eff_cs : -eff_cs)
                    translate([cx, cy, -0.01])
                        linear_extrude(base_height + 0.02)
                            polygon([[0, 0], [sx, 0], [0, sy]]);
        }

        // Screw holes — through the full base
        if (mount_style == 1 || mount_style == 2)
            for (pos = mount_positions)
                translate([pos[0], pos[1], -0.01])
                    cylinder(d = hole_diameter, h = base_height + 0.02);
        // Magnet pockets — blind holes from the back
        if (mount_style == 3 || mount_style == 4)
            for (pos = mount_positions)
                translate([pos[0], pos[1], 0])
                    cylinder(r = magnet_radius, h = magnet_thickness);
    }

    // Raised border
    ow = base_width  - 2 * border_inset;
    od = base_depth  - 2 * border_inset;

    translate([border_inset, border_inset, base_height])
        linear_extrude(border_height)
            if (corner_style == 0) {
                difference() {
                    concave_corner_rect(ow, od, eff_cr);
                    offset(r = -border_thickness)
                        concave_corner_rect(ow, od, eff_cr);
                }
            } else {
                difference() {
                    chamfered_rect(ow, od, eff_cs);
                    offset(delta = -border_thickness)
                        chamfered_rect(ow, od, eff_cs);
                }
            }

    // Raised text, centered on the base — each line stacked top to bottom
    total_text_height = (len(text_lines) - 1) * text_size * text_line_spacing;
    for (i = [0 : len(text_lines) - 1])
        translate([base_width / 2,
                   base_depth / 2 + total_text_height / 2 - i * text_size * text_line_spacing,
                   base_height])
            linear_extrude(text_depth)
                text(text_lines[i], size = text_size, font = text_font,
                     halign = "center", valign = "center");
}

plaque();
