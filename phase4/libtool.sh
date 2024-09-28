# Libtool Phase 4
./configure --prefix=/usr

make

if $RUN_TESTS
then
    set +e
    make -k check
    set -e
fi

make install

rm -f /usr/lib/libltdl.a

