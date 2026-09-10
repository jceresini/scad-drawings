/* [Text] */
// Text to display on the plaque
text_content = "Hello World";
// Font size (mm)
text_size = 12;
// Font name — must be installed on your system
text_font = "Liberation Sans:style=Bold";
// How much the text is raised above the base surface (mm)
text_depth = 4;

/* [Base Size] */
// Width of the plaque (mm)
base_width = 130;
// Depth of the plaque (mm)
base_depth = 50;
// Thickness of the base (mm)
base_height = 5;

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

    // Base with spherical concave cutouts at each corner
    difference() {
        cube([base_width, base_depth, base_height]);
        for (x = [corner_inset, base_width  - corner_inset])
            for (y = [corner_inset, base_depth - corner_inset])
                translate([x, y, base_height])
                    sphere(r = eff_cr);
    }

    // Raised border — follows the concave-corner shape of the base
    ow = base_width  - 2 * border_inset;
    od = base_depth  - 2 * border_inset;
    inner_cr = max(0, eff_cr - border_thickness);

    translate([border_inset, border_inset, base_height])
        linear_extrude(border_height)
            difference() {
                concave_corner_rect(ow, od, eff_cr);
                translate([border_thickness, border_thickness])
                    concave_corner_rect(
                        ow - 2 * border_thickness,
                        od - 2 * border_thickness,
                        inner_cr
                    );
            }

    // Raised text, centered on the base
    translate([base_width / 2, base_depth / 2, base_height])
        linear_extrude(text_depth)
            text(text_content, size = text_size, font = text_font,
                 halign = "center", valign = "center");
}

plaque();
