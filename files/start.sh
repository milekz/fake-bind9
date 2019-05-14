#!/bin/bash

if [ ! -z "$FAKEIP" ]
then

wget -O - http://data.iana.org/TLD/tlds-alpha-by-domain.txt | awk '{print "zone \""  $1"\" { type master; file \"/etc/bind/db.fake-redirect\"; };     "    }' > /etc/bind/named.conf.fake-redirect

cat <<EOF > /etc/bind/db.fake-redirect 
\$TTL    30
@       IN      SOA     localhost. root.localhost. (
                              1         ; Serial
                            800         ; Refresh
                            400         ; Retry
                            600         ; Expire
                            600 )       ; Negative Cache TTL
@       IN      NS      localhost.
@       IN      A       $FAKEIP
*       IN      A       $FAKEIP
EOF

echo "include \"/etc/bind/named.conf.fake-redirect\";" >> /etc/bind/named.conf

fi

/bin/s6-svscan /etc/s6



