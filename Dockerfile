FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV HOME=/root
ENV DISPLAY=:1
ENV VNC_PORT=5901
ENV NO_VNC_PORT=6080
ENV RESOLUTION=1280x800
ENV VNC_PASS=password

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y xfce4 xfce4-goodies tightvncserver websockify novnc supervisor curl wget python3 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Setup VNC password
RUN mkdir -p /root/.vnc && \
    echo "$VNC_PASS" | vncpasswd -f > /root/.vnc/passwd && \
    chmod 600 /root/.vnc/passwd

# startup script
RUN mkdir -p /opt/startup
COPY start.sh /opt/startup/start.sh
RUN chmod +x /opt/startup/start.sh

# Supervisor config
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE ${NO_VNC_PORT}

CMD ["/usr/bin/supervisord", "-n"]
