# PathFinder Postgres API

Run this backend on the PC that already has PostgreSQL and Tailscale.

## 1. Setup

```powershell
cd path\to\backend
python -m venv venv
.\venv\Scripts\Activate.ps1
python -m pip install -r requirements.txt
copy .env.example .env
notepad .env
```

Put your real Postgres password in `.env`.

## 2. Run

```powershell
python app.py
```

## 3. Open Windows firewall for API port 5000

Run PowerShell as Administrator:

```powershell
New-NetFirewallRule `
  -DisplayName "PathFinder Flask API Tailscale" `
  -Direction Inbound `
  -Protocol TCP `
  -LocalPort 5000 `
  -RemoteAddress 100.64.0.0/10 `
  -Action Allow
```

## 4. Test from Mac

```bash
curl http://100.117.157.38:5000/api/health
curl http://100.117.157.38:5000/api/schema/trail
curl "http://100.117.157.38:5000/api/trails?lat=33.4255&lon=-111.9400"
```
