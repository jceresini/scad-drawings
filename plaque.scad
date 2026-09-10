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

/* [Corner Circles] */
// Radius of the concave spherical cutout at each corner (mm)
corner_radius = 8;
// Inset from corner vertex — 0 = centered on corner, increase to move circles inward
corner_inset = 0;

/* [Raised Border] */
// Distance from base edge to outer wall of the border (mm)
border_inset = 2;
// Height of the raised border above the base (mm)
border_height = 2;
// Thickness of the border walls (mm)
border_thickness = 3;

/* [Mounting Holes] */
// 0 = none, 1 = left + right sides (centered vertically), 2 = top + bottom (centered horizontally)
mount_style = 0;
// Screw hole diameter (mm)
hole_diameter = 4;
// Distance from edge to hole center (mm)
hole_edge_spacing = 10;

/* [Quality] */
// Circle/sphere resolution (segments)
$fn = 64;

// 2D rectangle with concave quarter-circles at each corner.
// cr is clamped so circles never overlap when the rect is small.
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

module plaque() {
    // Clamp sphere radius so opposite-corner spheres never fully overlap
    eff_cr = min(corner_radius,
                 (base_width  - 2 * corner_inset) / 2,
                 (base_depth  - 2 * corner_inset) / 2);

    hole_positions =
        mount_style == 1 ? [
            [hole_edge_spacing,              base_depth / 2],
            [base_width - hole_edge_spacing, base_depth / 2]
        ] : mount_style == 2 ? [
            [base_width / 2, hole_edge_spacing],
            [base_width / 2, base_depth - hole_edge_spacing]
        ] : [];

    // Base with cylindrical concave cutouts at each corner and optional mount holes
    difference() {
        cube([base_width, base_depth, base_height]);
        for (x = [corner_inset, base_width  - corner_inset])
            for (y = [corner_inset, base_depth - corner_inset])
                translate([x, y, -0.01])
                    cylinder(r = eff_cr, h = base_height + 0.02);
        for (pos = hole_positions)
            translate([pos[0], pos[1], -0.01])
                cylinder(d = hole_diameter, h = base_height + 0.02);
    }

    // Raised border — offset() shrinks the outer profile inward uniformly so
    // wall thickness stays consistent at the corners, not just on straight edges.
    ow = base_width  - 2 * border_inset;
    od = base_depth  - 2 * border_inset;

    translate([border_inset, border_inset, base_height])
        linear_extrude(border_height)
            difference() {
                concave_corner_rect(ow, od, eff_cr);
                offset(r = -border_thickness)
                    concave_corner_rect(ow, od, eff_cr);
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
