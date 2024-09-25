# Expect Phase 4
PTYOUT=$(python3 -c 'from pty import spawn; spawn(["echo", "ok"])')
if [ "$PTYOUT" != "$(echo -ne 'ok\r\n')" ]
then
    echo $PTYOUT
    exit 1
fi



patch -Np1 -i ../$(basename $PATCH_EXPECT)

./configure --prefix=/usr           \
            --with-tcl=/usr/lib     \
            --enable-shared         \
            --disable-rpath         \
            --mandir=/usr/share/man \
            --with-tclinclude=/usr/include

make

if $RUN_TESTS
then
    set +e
    make test 
    set -e
fi

make install

ln -sf expect5.45.4/libexpect5.45.4.so /usr/lib

