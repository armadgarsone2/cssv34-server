# v34 stack fix — 2026-10-13

Root cause of 'Function CreateInterface not found': wrong SourceMod build.
v34 (2009 engine) needs the CSS34-forked SourceMod 1.7.3, which exports plain
`CreateInterface` (SM 1.10/1.12 only export `CreateInterface_MMS`).

## Installed (from files.hl2go.com css-v34 pack, user-authorized)
- Metamod:Source 1.10.7-git966  (matched pair)
- SourceMod 1.7.3-stable+5265 CSS34 fork  (the fix)
- SMAC Ultra anticheat (all 5 modules + Ultr@Tools.ext.so)
- GunGame 1.2.16.0 + 26 custom plugins

## Result
- meta list: SourceMod + CS/SDK Tools + SDK Hooks loaded
- sm plugins list: 43 plugins, ZERO errors
- sm exts: Ultr@Tools loaded
- A2S: protocol 7, GunGame:SM, de_dust2

## Backups on server
- addons/metamod.prehl2go  (old metamod 1.12)
- addons/sourcemod.prehl2go (old sourcemod 1.12)
