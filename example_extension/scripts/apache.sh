groupadd -g 25 apache &&
useradd -c "Apache Server" -d /srv/www -g apache \
        -s /bin/false -u 25 apache

patch -Np1 -i ../httpd-2.4.62-blfs_layout-1.patch             &&

sed '/dir.*CFG_PREFIX/s@^@#@' -i support/apxs.in              &&

sed -e '/HTTPD_ROOT/s:${ap_prefix}:/etc/httpd:'       \
    -e '/SERVER_CONFIG_FILE/s:${rel_sysconfdir}/::'   \
    -e '/AP_TYPES_CONFIG_FILE/s:${rel_sysconfdir}/::' \
    -i configure  &&

sed -e '/encoding.h/a # include <libxml/xmlstring.h>' \
    -i modules/filters/mod_xml2enc.c  &&

./configure --enable-authnz-fcgi                              \
            --enable-layout=BLFS                              \
            --enable-mods-shared="all cgi"                    \
            --enable-mpms-shared=all                          \
            --enable-suexec=shared                            \
            --with-apr=/usr/bin/apr-1-config                  \
            --with-apr-util=/usr/bin/apu-1-config             \
            --with-suexec-bin=/usr/lib/httpd/suexec           \
            --with-suexec-caller=apache                       \
            --with-suexec-docroot=/srv/www                    \
            --with-suexec-logfile=/var/log/httpd/suexec.log   \
            --with-suexec-uidmin=100                          \
            --with-suexec-userdir=public_html                 &&
make




make install  &&

mv -v /usr/sbin/suexec /usr/lib/httpd/suexec &&
chgrp apache           /usr/lib/httpd/suexec &&
chmod 4754             /usr/lib/httpd/suexec &&

chown -v -R apache:apache /srv/www
