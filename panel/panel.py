#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""CSS v34 Admin Panel v2 — status, players, maps, gamemodes, console, admins"""
import socket, json, os, re, time, subprocess, threading
from http.server import HTTPServer, BaseHTTPRequestHandler
from socketserver import ThreadingTCPServer
from urllib.parse import parse_qs, urlparse

RCON_PASS = open('/root/cssserver/rcon_pass.txt').read().split('=')[1].strip()
PANEL_PASS = RCON_PASS + 'web'
PORT = 8081
CWD = '/root/cssserver'
ADMINS_INI = CWD + '/cstrike/addons/sourcemod/configs/admins_simple.ini'
CONSOLE_LOG = CWD + '/console_history.log'
MAPCYCLE = CWD + '/cstrike/mapcycle.txt'
BANS_FILE = CWD + '/cstrike/banned_userids.cfg'
GAGS_FILE = CWD + '/cstrike/addons/sourcemod/data/gags.txt'
RANKS_FILE = CWD + '/cstrike/addons/sourcemod/data/ranks.txt'
CHAT_FILE = CWD + '/cstrike/addons/sourcemod/data/chat_log.txt'

def get_bans():
    out = []
    try:
        for l in open(BANS_FILE):
            l = l.strip()
            if not l or l.startswith('//'): continue
            m = re.match(r'banid\s+"?(\d+)"?\s+"?([^"\s]+)"?', l)
            if m:
                mins = int(m.group(1))
                out.append({'auth': m.group(2), 'minutes': mins,
                            'perm': mins == 0, 'kind': 'بن'})
    except Exception: pass
    try:
        for l in open(GAGS_FILE):
            l = l.strip()
            if not l: continue
            p = l.split(';')
            if len(p) < 3: continue
            gtype = int(p[2])
            label = 'گگ+مت' if gtype == 3 else ('گگ' if gtype == 1 else 'مت')
            reason = p[3] if len(p) > 3 else ''
            exp = int(p[1])
            mins = 0 if exp == 0 else max(0, (exp - int(time.time())) // 60)
            out.append({'auth': p[0], 'minutes': mins, 'perm': exp == 0,
                        'kind': label, 'reason': reason})
    except Exception: pass
    return out

def get_chat(tail=80):
    try:
        lines = open(CHAT_FILE, errors='ignore').read().splitlines()
        return lines[-tail:]
    except Exception:
        return []

def get_stats():
    rows = []
    try:
        for l in open(RANKS_FILE, errors='ignore'):
            p = l.strip().split(';')
            if len(p) < 4: continue
            rows.append({'name': p[1], 'kills': int(p[2]), 'deaths': int(p[3]),
                         'hs': int(p[4]) if len(p) > 4 else 0,
                         'sniper': int(p[5]) if len(p) > 5 else 0})
    except Exception: pass
    rows.sort(key=lambda r: r['kills'], reverse=True)
    return rows[:50]

def rcon_exec(cmd, timeout=8):
    """Send console command via PTY supervisor on 127.0.0.1:27016"""
    try:
        s = socket.socket()
        s.settimeout(timeout)
        s.connect(('127.0.0.1', 27016))
        s.sendall(cmd.encode())
        out = b''
        try:
            while True:
                chunk = s.recv(8192)
                if not chunk:
                    break
                out += chunk
        except socket.timeout:
            pass
        s.close()
        return out.decode('utf-8', 'ignore')
    except Exception as e:
        return 'ERROR: %s' % e

def server_status():
    return rcon_exec('status') or '(no response)'

LOGIN_HTML = open(CWD + '/web/login.html').read()
APP_HTML = open(CWD + '/web/app.html').read()

def parse_players(st):
    players = []
    for ln in st.splitlines():
        m = re.match(r'^\#\s+(\d+)\s+"([^"]+)"', ln)
        if m and int(m.group(1)) > 0:
            players.append({'uid': m.group(1), 'name': m.group(2)})
    return players

def get_maps():
    try:
        return [l.strip() for l in open(MAPCYCLE) if l.strip() and not l.startswith('//')]
    except Exception:
        return ['de_dust2']

def get_admins():
    try:
        return [l.strip() for l in open(ADMINS_INI) if l.strip() and not l.strip().startswith('//')]
    except Exception:
        return []

class Handler(BaseHTTPRequestHandler):
    session = False
    def log_message(self, *a): pass

    def _redir(self, loc='/'):
        self.send_response(302); self.send_header('Location', loc); self.end_headers()

    def _page(self, body, code=200, ctype='text/html; charset=utf-8'):
        data = body.encode() if isinstance(body, str) else body
        self.send_response(code)
        self.send_header('Content-Type', ctype)
        self.send_header('Content-Length', str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def _json(self, obj):
        self._page(json.dumps(obj, ensure_ascii=False), 200, 'application/json')

    def _body(self):
        n = int(self.headers.get('Content-Length') or 0)
        raw = self.rfile.read(n) if n else b''
        ct = self.headers.get('Content-Type', '')
        if 'application/json' in ct:
            try: return json.loads(raw.decode() or '{}')
            except Exception: return {}
        return {k: v[0] for k, v in parse_qs(raw.decode()).items()}

    def do_GET(self):
        path = urlparse(self.path).path
        if path == '/health':
            self._page('OK'); return
        if path == '/login':
            self._page(LOGIN_HTML); return
        if path == '/logout':
            Handler.session = False
            self._redir('/login'); return
        if not Handler.session:
            self._redir('/login'); return
        if path in ('/', '/app'):
            self._page(APP_HTML); return
        if path == '/api/status':
            st = server_status()
            mp = re.search(r'map\s*:\s*(\S+)', st)
            pl = re.search(r'players\s*:\s*(\d+)\s*\((\d+)', st)
            self._json({
                'raw': st[-6000:],
                'map': mp.group(1) if mp else '?',
                'players': parse_players(st),
                'count': int(pl.group(1)) if pl else 0,
                'max': int(pl.group(2)) if pl else 0,
                'server_active': 'players' in st,
                'sm_dm': ('sm_dm 1' in st) or ('"sm_dm" "1"' in st),
                'sniper': ('sm_sniper_mode 1' in st) or ('"sm_sniper_mode" "1"' in st),
                'knifesmoke': ('sm_knife_smoke 1' in st) or ('"sm_knife_smoke" "1"' in st),
            }); return
        if path == '/api/maps':
            self._json({'maps': get_maps()}); return
        if path == '/api/admins':
            self._json({'admins': get_admins()}); return
        if path == '/api/bans':
            self._json({'bans': get_bans()}); return
        if path == '/api/chat':
            self._json({'lines': get_chat()}); return
        if path == '/api/stats':
            self._json({'rows': get_stats()}); return
        self.send_response(404); self.end_headers()

    def do_POST(self):
        path = urlparse(self.path).path
        d = self._body()
        if path == '/login':
            if d.get('pass', '') == PANEL_PASS:
                Handler.session = True
                self._redir('/')
            else:
                self._redir('/login?e=1')
            return
        if not Handler.session:
            self._redir('/login'); return
        if path == '/api/map':
            mp = re.sub(r'[^\w\-]', '', d.get('map', ''))
            if mp:
                rcon_exec('changelevel ' + mp)
            self._json({'ok': True}); return
        if path == '/api/gm':
            mode = d.get('mode', 'public')
            if mode not in ('public', 'comp', 'dm', 'gungame', 'sniper', 'knifesmoke'):
                self._json({'error': 'bad mode'}, 400); return
            if mode != 'gungame':
                rcon_exec('sm plugins unload gungame')
            rcon_exec('exec gamemodes/%s.cfg' % mode)
            self._json({'ok': True, 'mode': mode}); return
        if path == '/api/kick':
            uid = re.sub(r'\D', '', d.get('uid', ''))
            if uid:
                rcon_exec('kick ' + uid)
            self._json({'ok': True}); return
        if path == '/api/ban':
            uid = re.sub(r'\D', '', d.get('uid', ''))
            mins = re.sub(r'\D', '', str(d.get('minutes', '30'))) or '30'
            if uid:
                rcon_exec('banid %s %s kick' % (mins, uid))
                rcon_exec('writeid')
            self._json({'ok': True}); return
        if path == '/api/admin/add':
            auth = d.get('auth', '').strip().strip('"')[:64]
            flags = d.get('flags', '99:z').strip().strip('"')[:32]
            if not auth:
                self._json({'error': 'empty'}, 400); return
            with open(ADMINS_INI, 'a') as f:
                f.write('\n// added via panel %s\n"%s" "%s"\n' % (time.strftime('%Y-%m-%d'), auth, flags))
            rcon_exec('sm_reloadadmins')
            self._json({'ok': True}); return
        if path == '/api/admin/del':
            target = d.get('auth', '').strip().strip('"')
            if target and os.path.exists(ADMINS_INI):
                out = [l for l in open(ADMINS_INI)
                       if not (target in l and l.strip().startswith('"'))]
                open(ADMINS_INI, 'w').writelines(out)
                rcon_exec('sm_reloadadmins')
            self._json({'ok': True}); return
        if path == '/api/unban':
            auth = d.get('auth', '').strip().strip('"')
            kind = d.get('kind', 'بن')
            if auth and kind == 'بن' and os.path.exists(BANS_FILE):
                out = [l for l in open(BANS_FILE) if auth not in l]
                open(BANS_FILE, 'w').writelines(out)
                rcon_exec('removeid ' + auth)
            elif auth and kind != 'بن' and os.path.exists(GAGS_FILE):
                out = [l for l in open(GAGS_FILE) if not l.strip().startswith(auth + ';')]
                open(GAGS_FILE, 'w').writelines(out)
            self._json({'ok': True}); return
        if path == '/api/restart':
            subprocess.Popen(['systemctl', 'restart', 'css34'])
            self._json({'ok': True}); return
        self.send_response(404); self.end_headers()

class TS(ThreadingTCPServer):
    allow_reuse_address = True

if __name__ == '__main__':
    print('PANEL v2 on %d' % PORT, flush=True)
    TS(('0.0.0.0', PORT), Handler).serve_forever()
