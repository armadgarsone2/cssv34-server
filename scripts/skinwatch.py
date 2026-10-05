#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""skinwatch: applies server-wide gun skins requested by shop_simple plugin.
Watches: cstrike/addons/sourcemod/data/skins_request/*.request
On request: restore vanilla for that weapon slot, copy skin files, update
/root/cssserver/skins_active.txt, then changelevel to reload models."""
import os, sys, json, time, shutil, socket, glob

CS = '/root/cssserver/cstrike'
LIB = '/root/cssserver/skins_lib'
REQ_DIR = CS + '/addons/sourcemod/data/skins_request'
ACTIVE_FILE = '/root/cssserver/skins_active.txt'
RCON = ('127.0.0.1', 27016)

def rcon(cmd, wait=1.5):
    try:
        s = socket.socket()
        s.settimeout(5)
        s.connect(RCON)
        s.sendall(cmd.encode())
        time.sleep(wait)
        try:
            s.recv(65536)
        except socket.timeout:
            pass
        s.close()
    except Exception as e:
        print('[skinwatch] rcon error:', e, flush=True)

def current_map():
    try:
        st = open('/root/cssserver/console_history.log', 'rb').read()[-4000:].decode('utf-8', 'ignore')
        import re
        m = re.search(r'map\s*:\s*(\S+)', st)
        return m.group(1) if m else 'de_dust2'
    except Exception:
        return 'de_dust2'

def copy_file(src, dst):
    os.makedirs(os.path.dirname(dst), exist_ok=True)
    shutil.copy2(src, dst)

def restore_weapon(weapon):
    """Copy vanilla files for a weapon slot back into cstrike."""
    vm = json.load(open(LIB + '/vanilla_manifest.json'))
    files = vm.get(weapon, [])
    for rel in files:
        src = os.path.join(LIB, 'vanilla', 'cstrike', rel)
        dst = os.path.join(CS, rel)
        if os.path.exists(src):
            copy_file(src, dst)
    # remove custom knife anims if restoring knife
    if weapon == 'knife':
        for f in glob.glob(CS + '/models/weapons/anims/v_knife*'):
            try:
                os.remove(f)
            except OSError:
                pass
    print('[skinwatch] restored vanilla for', weapon, flush=True)

def apply_skin(skin):
    mpath = os.path.join(LIB, skin, 'manifest.json')
    if not os.path.exists(mpath):
        print('[skinwatch] no manifest for', skin, flush=True)
        return False
    m = json.load(open(mpath))
    weapon = m['weapon']
    # 1) restore vanilla first (clears previous skin leftovers)
    restore_weapon(weapon)
    # 2) copy skin files
    ok = 0
    for rel in m.get('files', []):
        src = os.path.join(LIB, skin, rel)
        dst = os.path.join(CS, rel)
        if os.path.exists(src):
            copy_file(src, dst)
            ok += 1
    # 3) knife anims cleanup: keep only this skin's anims (they were copied above)
    print('[skinwatch] applied %s (%s): %d files' % (skin, weapon, ok), flush=True)
    # 4) update active file (one skin per weapon slot)
    active = {}
    if os.path.exists(ACTIVE_FILE):
        for line in open(ACTIVE_FILE):
            line = line.strip()
            if not line:
                continue
            parts = line.split('=', 1)
            if len(parts) == 2:
                active[parts[0]] = parts[1]
    active[weapon] = skin
    with open(ACTIVE_FILE, 'w') as f:
        for w, s in sorted(active.items()):
            f.write('%s=%s\n' % (w, s))
    # mirror to SM data dir
    try:
        shutil.copy2(ACTIVE_FILE, CS + '/addons/sourcemod/data/skins_active.txt')
    except Exception:
        pass
    return True

def main():
    os.makedirs(REQ_DIR, exist_ok=True)
    print('[skinwatch] watching', REQ_DIR, flush=True)
    while True:
        try:
            for req in glob.glob(REQ_DIR + '/*.request'):
                skin = os.path.basename(req)[:-8]  # strip .request
                print('[skinwatch] request:', skin, flush=True)
                if apply_skin(skin):
                    mp = current_map()
                    print('[skinwatch] changelevel', mp, flush=True)
                    rcon('changelevel ' + mp)
                try:
                    os.remove(req)
                except OSError:
                    pass
        except Exception as e:
            print('[skinwatch] loop error:', e, flush=True)
        time.sleep(2)

if __name__ == '__main__':
    main()
