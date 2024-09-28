# Udev from Systemd phase 4

sed -i -e 's/GROUP="render"/GROUP="video"/' \
       -e 's/GROUP="sgx", //' rules.d/50-udev-default.rules.in

sed '/systemd-sysctl/s/^/#/' -i rules.d/99-systemd.rules.in

sed '/NETWORK_DIRS/s/systemd/udev/' -i src/basic/path-lookup.h

mkdir -p build
cd       build

meson setup ..                  \
      --prefix=/usr             \
      --buildtype=release       \
      -D mode=release           \
      -D dev-kvm-mode=0660      \
      -D link-udev-shared=false \
      -D logind=false           \
      -D vconsole=false

export udev_helpers=$(grep "'name' :" ../src/udev/meson.build | \
                      awk '{print $3}' | tr -d ",'" | grep -v 'udevadm')

ninja udevadm systemd-hwdb                                           \
      $(ninja -n | grep -Eo '(src/(lib)?udev|rules.d|hwdb.d)/[^ ]*') \
      $(realpath libudev.so --relative-to .)                         \
      $udev_helpers

install -m755 -d {/usr/lib,/etc}/udev/{hwdb.d,rules.d,network}
install -m755 -d /usr/{lib,share}/pkgconfig
install -m755 udevadm                             /usr/bin/
install -m755 systemd-hwdb                        /usr/bin/udev-hwdb
ln      -svfn  ../bin/udevadm                      /usr/sbin/udevd
cp      -av    libudev.so{,*[0-9]}                 /usr/lib/
install -m644 ../src/libudev/libudev.h            /usr/include/
install -m644 src/libudev/*.pc                    /usr/lib/pkgconfig/
install -m644 src/udev/*.pc                       /usr/share/pkgconfig/
install -m644 ../src/udev/udev.conf               /etc/udev/
install -m644 rules.d/* ../rules.d/README         /usr/lib/udev/rules.d/
install -m644 $(find ../rules.d/*.rules \
                      -not -name '*power-switch*') /usr/lib/udev/rules.d/
install -m644 hwdb.d/*  ../hwdb.d/{*.hwdb,README} /usr/lib/udev/hwdb.d/
install -m755 $udev_helpers                       /usr/lib/udev
install -m644 ../network/99-default.link          /usr/lib/udev/network

udev-hwdb update