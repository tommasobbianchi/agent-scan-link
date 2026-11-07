# agent-scan-link

Small helpers for letting an LLM agent drive [ScanRuler](https://scanruler.com) (a browser-based 3D-scan measuring and reverse-engineering tool) through its MCP server, when the agent and the browser are on different machines.

**Unofficial.** This project is not affiliated with or endorsed by CNC Kitchen or Stefan Hermann. ScanRuler and `scanruler-mcp` are theirs: [github.com/CNCKitchen/scanruler](https://github.com/CNCKitchen/scanruler) (AGPL-3.0-only). Nothing from them is copied or bundled here; you install `scanruler-mcp` yourself (`npx -y scanruler-mcp@latest`).

## The problem

`scanruler-mcp` listens on `127.0.0.1:7317` of the machine that runs your agent. The ScanRuler page runs in a browser, often on another machine (your workstation), and has to reach that port. The page also has to be paired with a link of the form `https://scanruler.com/#agent=7317:<token>`.

## `scan-link.sh`

Run it on the agent's machine. For each client it opens a reverse SSH forward (`ssh -N -R 127.0.0.1:7317:127.0.0.1:7317`) as a transient `systemd --user` unit, then opens the pairing link in that client's browser over SSH. Nothing is installed on the client and nothing survives a reboot; `down` stops the tunnel.

```bash
export SCAN_LINK_HOSTS="desk=me@desk.local laptop=me@192.168.1.20"   # ssh key auth
./scan-link.sh up desk        # tunnel + pairing link
./scan-link.sh status
./scan-link.sh down desk
```

- If the client's port 7317 already answers (a tunnel you made yourself), it is reused and never stopped.
- The token is read from `~/.config/scanruler-mcp/config.json` (override with `SCAN_LINK_CONFIG`); it is not written to the client's disk, but it does appear in the URL that is opened there.
- First connection: ScanRuler shows a data-sharing warning (what the agent reads goes to the agent and its model) and Chrome asks for local-network access. Both need a person to accept once.
- Needs `systemd --user`, `ssh`, `python3` on the agent machine and `xdg-open` plus a running desktop session on the client. Tested on Ubuntu with GNOME/Wayland and Chrome.

## `skill/SKILL.md`

A generic Claude Code skill: the procedure for turning a mesh into a parametric STEP with ScanRuler (pair, read the guides ScanRuler serves, model feature by feature, verify numerically, export).

## `examples/bottom_bracket`

A worked result: a 50 x 50 x 50 mm bracket rebuilt as an 18-feature parametric model, STEP export and report. Checked against the source mesh with ScanRuler's volume comparison at 0.1 mm: no excess and no missing volume. The source was a CAD tessellation, so this shows the workflow, not scan-noise handling.

## Caveats

- ScanRuler sends what the agent reads (measurements, pictures, file names) to your LLM provider. Do not use it on confidential or personal data.
- Only the pairing and tunnel path is covered here; no part of ScanRuler's guides or tool schemas is reproduced. Read them from the server at run time.

## License

MIT for the files in this repository.
