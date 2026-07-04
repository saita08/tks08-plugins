#!/usr/bin/env bash
# idea-forge: enumerate the plugins the user already has installed.
#
# Reads ~/.claude/plugins/installed_plugins.json — the manifest of what is
# actually installed — and, for each install, lists the plugin's commands and
# skills from its installPath. This is the authoritative source of "what the
# user already has", so the dig step can drop candidates that merely
# re-describe existing capability. Prints JSON.
#
# This reads only the manifest and component filenames — never any user
# content — so it needs no claude -p call and no recursion guard.

set -euo pipefail

manifest="${HOME}/.claude/plugins/installed_plugins.json"

python3 - "$manifest" <<'PY'
import json, os, sys, glob

manifest = sys.argv[1]

installs = {}
if os.path.exists(manifest):
    try:
        with open(manifest, encoding="utf-8") as f:
            installs = (json.load(f) or {}).get("plugins", {}) or {}
    except Exception:
        installs = {}

def components(install_path):
    commands, skills = [], []
    if not install_path or not os.path.isdir(install_path):
        return commands, skills
    cmd_dir = os.path.join(install_path, "commands")
    if os.path.isdir(cmd_dir):
        for cf in glob.glob(os.path.join(cmd_dir, "**", "*.md"), recursive=True):
            commands.append(os.path.splitext(os.path.basename(cf))[0])
    skill_dir = os.path.join(install_path, "skills")
    if os.path.isdir(skill_dir):
        for sd in sorted(glob.glob(os.path.join(skill_dir, "*"))):
            if os.path.isdir(sd):
                skills.append(os.path.basename(sd))
    return sorted(set(commands)), sorted(set(skills))

plugins = []
for key, entries in installs.items():
    # key is "<name>@<marketplace>"; entries is a list of installs (per scope).
    name = key.split("@", 1)[0]
    install_path = ""
    scopes = []
    if isinstance(entries, list):
        for e in entries:
            if not isinstance(e, dict):
                continue
            scopes.append(e.get("scope", ""))
            if not install_path:
                install_path = e.get("installPath", "")
    commands, skills = components(install_path)
    plugins.append({
        "name": name,
        "key": key,
        "scopes": sorted(set(s for s in scopes if s)),
        "commands": commands,
        "skills": skills,
    })

plugins.sort(key=lambda p: p["name"])
print(json.dumps({"plugins": plugins}))
PY
