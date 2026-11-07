#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Link a browser on another machine to a local scanruler-mcp server, with nothing installed there.
# Run on the machine where the MCP server listens (127.0.0.1:PORT). For each client it opens a
# reverse SSH forward as a transient systemd user unit (gone on reboot) and opens the pairing link.
#
#   scan-link.sh up   [client...]   tunnel + open pairing link in that client's browser
#   scan-link.sh down [client...]   close the tunnel(s)
#   scan-link.sh status [client...]
#
# Clients come from $SCAN_LINK_HOSTS: "name=user@host name2=user@host2" (ssh key auth, BatchMode).
# Env: SCAN_LINK_PORT (default 7317), SCAN_LINK_CONFIG (default ~/.config/scanruler-mcp/config.json,
# a JSON file with a "token" field). The token is read at run time and never written to a client's disk.
set -euo pipefail

PORT=${SCAN_LINK_PORT:-7317}
CONF=${SCAN_LINK_CONFIG:-$HOME/.config/scanruler-mcp/config.json}
SSH=(ssh -o BatchMode=yes -o ConnectTimeout=6)

declare -A DEST
for kv in ${SCAN_LINK_HOSTS:-}; do DEST[${kv%%=*}]=${kv#*=}; done
[ ${#DEST[@]} -gt 0 ] || { echo 'set SCAN_LINK_HOSTS="name=user@host ..."' >&2; exit 2; }

cmd=${1:-}; shift || true
clients=("$@"); [ ${#clients[@]} -gt 0 ] || clients=("${!DEST[@]}")

for h in "${clients[@]}"; do
  [ -n "${DEST[$h]:-}" ] || { echo "unknown client $h" >&2; exit 2; }
  unit=scan-link-$h
  reach="(exec 3<>/dev/tcp/127.0.0.1/$PORT) 2>/dev/null"
  case "$cmd" in
    up)
      tok=$(python3 -c "import json,sys;print(json.load(open(sys.argv[1]))['token'])" "$CONF")
      if "${SSH[@]}" "${DEST[$h]}" "$reach"; then
        echo "$h: port $PORT already forwarded, reusing it"   # someone else's tunnel: never touched
      else
        systemd-run --user --unit "$unit" --collect --quiet -- \
          ssh -N -o BatchMode=yes -o ExitOnForwardFailure=yes -o ServerAliveInterval=15 \
              -R "127.0.0.1:$PORT:127.0.0.1:$PORT" "${DEST[$h]}"
        sleep 3
        "${SSH[@]}" "${DEST[$h]}" "$reach" || { echo "$h: tunnel not up (journalctl --user -u $unit)" >&2; continue; }
      fi
      # point xdg-open at the desktop session even from a plain ssh shell
      "${SSH[@]}" -n "${DEST[$h]}" 'export DISPLAY=${DISPLAY:-:0} XDG_RUNTIME_DIR=/run/user/$(id -u)
        [ -S $XDG_RUNTIME_DIR/wayland-0 ] && export WAYLAND_DISPLAY=wayland-0
        xdg-open "https://scanruler.com/#agent='"$PORT:$tok"'" >/dev/null 2>&1 &' >/dev/null 2>&1 ;;
    down)   systemctl --user stop "$unit.service" 2>/dev/null && echo "$h: tunnel stopped" || echo "$h: no tunnel of ours" ;;
    status) echo "$h: $(systemctl --user is-active "$unit.service" 2>/dev/null || true)" ;;
    *) sed -n '3,12p' "$0"; exit 2 ;;
  esac
done
