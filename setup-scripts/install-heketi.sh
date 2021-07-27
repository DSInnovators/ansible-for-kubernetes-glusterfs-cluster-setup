#!/bin/sh
set -x

# Download Heketi binaries
cd /tmp/hekei-installer
wget https://github.com/heketi/heketi/releases/download/v10.1.0/heketi-v10.1.0.linux.amd64.tar.gz
tar zxf heketi-v10.1.0.linux.amd64.tar.gz
mv /tmp/hekei-installer/heketi/heketi /usr/local/bin/
mv /tmp/hekei-installer/heketi/heketi-cli /usr/local/bin/

# Set up user account for heketi
groupadd -r heketi
useradd -r -s /sbin/nologin -g heketi heketi
mkdir /var/lib/heketi
mkdir /etc/heketi
mkdir /var/log/heketi

# Create ssh passwordless access to Gluster nodes
WORKER_NODES=$1
rm -fr /etc/heketi/*
ssh-keygen -f /etc/heketi/heketi_key -t rsa -N ''
for node in $WORKER_NODES; do
  ssh-copy-id -i /etc/heketi/heketi_key.pub root@$node
done

# Configure heketi
WORKER_NODE_PASSWORD=$2
sed -i s~CHANGE_PASSWORD_HERE~$WORKER_NODE_PASSWORD~g /tmp/hekei-installer/heketi-configuration.json
cp /tmp/hekei-installer/heketi-configuration.json /etc/heketi/heketi.json

# Update permissions on heketi directories
chown -R heketi:heketi /var/lib/heketi
chown -R heketi:heketi /etc/heketi
chown -R heketi:heketi /var/log/heketi

# Create systemd unit file for heketi
cat <<EOF >/etc/systemd/system/heketi.service
[Unit]
Description=Heketi Server

[Service]
Type=simple
WorkingDirectory=/var/lib/heketi
EnvironmentFile=-/etc/heketi/heketi.env
User=heketi
ExecStart=/usr/local/bin/heketi --config=/etc/heketi/heketi.json
Restart=on-failure
StandardOutput=syslog
StandardError=syslog

[Install]
WantedBy=multi-user.target
EOF

# Enable and start heketi service
systemctl daemon-reload
systemctl enable --now heketi