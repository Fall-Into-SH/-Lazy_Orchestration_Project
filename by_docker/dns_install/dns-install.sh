#!/bin/bash

# Set variables for convenience
DNS_DIR=dns-config
DOMAIN=fish.com
NS1_IP=192.168.0.16
WWW_IP=133.168.0.16

# Create configuration directory
mkdir -p $DNS_DIR/var/named
mkdir -p $DNS_DIR/etc/bind

# Download root hints to the correct directory if not already downloaded
if [ ! -f "$DNS_DIR/var/named/named.ca" ]; then
    wget -O $DNS_DIR/var/named/named.ca https://www.internic.net/domain/named.root
fi

# Create Dockerfile within the script
cat <<EOF > Dockerfile
FROM alpine:latest

# Install BIND
RUN apk update && \\
    apk add bind && \\
    rm -rf /var/cache/apk/*

# Ensure necessary directories are present and permissions are set
RUN mkdir -p /var/named /etc/bind && \\
    chown -R named:named /etc/bind /var/named

# Expose DNS service ports
EXPOSE 53/udp 53/tcp

# Command to run BIND in the foreground
CMD ["named", "-g", "-c", "/etc/bind/named.conf", "-f"]
EOF

# Create named.conf
cat <<EOF > $DNS_DIR/etc/bind/named.conf
options {
    directory "/var/named";
    recursion yes;
    allow-query { any; };
};

zone "$DOMAIN" IN {
    type master;
    file "/var/named/db.$DOMAIN";
};

include "/etc/bind/named.conf.default-zones";
EOF

# Create named.conf.default-zones
cat <<EOF > $DNS_DIR/etc/bind/named.conf.default-zones
zone "." IN {
    type hint;
    file "/var/named/named.ca";
};

zone "localhost" IN {
    type master;
    file "/var/named/localhost.zone";
};

zone "127.in-addr.arpa" IN {
    type master;
    file "/var/named/named.local";
};

zone "0.in-addr.arpa" IN {
    type master;
    file "/var/named/named.zero";
};

zone "255.in-addr.arpa" IN {
    type master;
    file "/var/named/named.broadcast";
};
EOF

# Create db.fish.com
cat <<EOF > $DNS_DIR/var/named/db.$DOMAIN
\$TTL    86400
@       IN      SOA     ns1.$DOMAIN. admin.$DOMAIN. (
                        2024010101  ; Serial
                        3600        ; Refresh
                        1800        ; Retry
                        604800      ; Expire
                        86400       ; Minimum TTL
)
        IN      NS      ns1.$DOMAIN.

ns1     IN      A       $NS1_IP
www     IN      A       $WWW_IP
EOF

# Build the Docker image
docker build -t alpine-dns .

# Run the container with mounted volumes
docker run -d --name mydns \
  -p 53:53/udp -p 53:53/tcp \
  -v "$(pwd)/$DNS_DIR/etc/bind:/etc/bind" \
  -v "$(pwd)/$DNS_DIR/var/named:/var/named" \
  alpine-dns

