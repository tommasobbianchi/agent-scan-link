---
name: scan-to-step
description: Turn a mesh or 3D scan (STL/PLY/OBJ/3MF) into a parametric STEP by reverse-engineering it in ScanRuler through its MCP server, with the user watching the browser tab. Use for "reverse engineer this scan", "scan to CAD", "mesh to STEP with scanruler".
---

# Scan to parametric STEP with ScanRuler

Unofficial. ScanRuler and `scanruler-mcp` belong to CNC Kitchen (AGPL-3.0). The user only names the object and checks the result by eye.

1. `scanruler_status`. If no page is connected, run `scan-link.sh up <client>` (reverse SSH tunnel plus pairing link), then `scanruler_wait`. Someone must accept the data-sharing warning once.
2. Read the guides the server serves (`guide_read`, list then the relevant ones) before the first step. Their text and the tool schemas are ScanRuler's: use them at run time, do not copy them elsewhere.
3. Open the scan, read `session_state` (bounding box, millimetres). Model it feature by feature with named parameters for the dimensions that matter. Add a `history_checkpoint` before risky steps.
4. Verify numerically: the volume comparison against the scan, body check, sections. Fix what it reports (a hole's hidden counterbore shows up as excess volume). Avoid picture-rendering tools if the browser machine has an unstable GPU driver; say so in the report.
5. Export STEP and save the project. Read the STEP back with an independent kernel (for example OCP/pythonocc): one valid solid, expected volume and bounding box.
6. Write a short report: features and parameters, deviation numbers, what was not verified by eye.
7. `scan-link.sh down <client>` for a tunnel this run started. Never stop one somebody else made.
