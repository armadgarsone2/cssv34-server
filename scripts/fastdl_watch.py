#!/usr/bin/env python3
# Watches fastdl tunnels; pushes best URL to game server via RCON.
# Priority: plain http (bore) because old v34 engine has no TLS.
import re, time, socket

BORE_LOG = '/root/fastdl-bore.log'
CF_LOG = '/root/fastdl-tunnel.log'
CFG = '/root/cssserver/cstrike/cfg/server.cfg'
last = ''

def rcon(cmd, timeout=5):
    try:
        s = socket.socket(); s.settimeout(timeout)
        s.connect(('127.0.0.1', 27016))
        s.sendall(cmd.encode())
        time.sleep(1.0)
        try: s.recv(65536)
        except socket.timeout: pass
        s.close()
        return True
    except Exception as e:
        print('[wd] rcon err:', e, flush=True)
        return False

def read(path):
    try: return open(path, 'r', errors='ignore').read()
    except Exception: return ''

def best_url():
    m = re.findall(r'listening at bore\.pub:(\d+)', read(BORE_LOG))
    if m:
        return 'http://bore.pub:%s/' % m[-1]
    m = re.findall(r'https://[a-z0-9\-]+\.trycloudflare\.com', read(CF_LOG))
    if m:
        return m[-1] + '/'
    return ''

def set_cfg(url):
    try:
        lines = open(CFG).readlines()
        out, done = [], False
        for ln in lines:
            if ln.strip().startswith('sv_downloadurl'):
                out.append('sv_downloadurl "%s"\n' % url); done = True
            else:
                out.append(ln)
        if not done:
            out.append('\nsv_downloadurl "%s"\n' % url)
        open(CFG, 'w').writelines(out)
    except Exception as e:
        print('[wd] cfg err:', e, flush=True)

while True:
    try:
        u = best_url()
        if u and u != last:
            print('[wd] fastdl url ->', u, flush=True)
            if rcon('sv_downloadurl "%s"' % u):
                set_cfg(u)
                last = u
    except Exception as e:
        print('[wd] err:', e, flush=True)
    time.sleep(10)
