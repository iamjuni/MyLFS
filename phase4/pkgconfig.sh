# Pkg-config Phase 4
./configure --prefix=/usr              \
            --disable-static           \
            --docdir=/usr/share/doc/pkgconf-2.3.0

make

if $RUN_TESTS
then
    set +e
    make check
    set -e
fi

make install

ln -s pkgconf   /usr/bin/pkg-config
ln -s pkgconf.1 /usr/share/man/man1/pkg-config.1