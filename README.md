# ubuntu-xfce-novnc

XFCE desktop environment served over noVNC (browser access).
Default VNC password: `password`
Default resolution: `1280x800`

## Build (locally)
```bash
docker build -t ghcr.io/<your-gh-username>/ubuntu-xfce-novnc:latest .
```

## Run (locally)
```bash
docker run -d -p 6080:6080 ghcr.io/<your-gh-username>/ubuntu-xfce-novnc:latest
```
Open http://localhost:6080 in your browser.

## GitHub Actions
The included workflow pushes the image to GitHub Container Registry (GHCR).
Replace `<your-gh-username>` in workflow or ensure repository owner matches your GH account.

## Pterodactyl Egg
Use the provided `egg.json` and set the image to the GHCR path after build.

