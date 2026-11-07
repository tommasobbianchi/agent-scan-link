# real_mesh_bottom_bracket - scan-to-CAD report
Source: a CAD-tessellated bracket mesh (sigma 0, not a real scan). Envelope 50x50x50 mm (x138-188, y58-108, z-69..-19).
Model (18 features, params t=4.9, back_h=25, pin_depth=5): base, back wall, two uprights with 25x25 chamfer, upright holes (2x d4 + slot 4x6 overall 6, i.e. centre-to-centre 2), base holes 2x d4, back-wall holes 2x d3 with hex nut traps (AF 5.3, 2.1 deep, found by volume compare), blind d3 corner pin hole 5 deep.
Verification: reverse_body_volume_compare tol 0.1 mm: excess 0, missing 0 (cell 0.21). reverse_body_check: valid, closed, clean.
Not verified: chamfer end at y=83 by direct measurement (volume compare covers it); only one corner pin hole found; body_check volume 33297 vs compare modelVolume 32893 differ (not explained).
Files: bottom_bracket_CAD.step, bottom_bracket_CAD.scanruler.
