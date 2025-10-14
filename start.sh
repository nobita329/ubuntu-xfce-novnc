#!/bin/bash
export DISPLAY=${DISPLAY:-:1}
RES="${RESOLUTION:-1280x800}"
VNC_PORT="${VNC_PORT:-5901}"
NO_VNC_PORT="${NO_VNC_PORT:-6080}"

# kill any existing servers
vncserver -kill $DISPLAY 2>/dev/null || true
rm -f /tmp/.X*-lock || true

# start xfce VNC
vncserver $DISPLAY -geometry $RES -depth 24

# start noVNC (websockify)
# some distributions provide novnc's web files in /usr/share/novnc
if [ -d /usr/share/novnc ]; then
  WEBROOT=/usr/share/novnc
elif [ -d /usr/share/novnc/ ]; then
  WEBROOT=/usr/share/novnc
else
  WEBROOT=/usr/share/novnc
fi

# start websockify to forward noVNC -> VNC
websockify --web=$WEBROOT $NO_VNC_PORT localhost:$VNC_PORT &

# keep container running by tailing supervisord logs
tail -f /var/log/supervisor/*.log
