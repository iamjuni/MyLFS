# Man-DB Phase 4
rm  man3/crypt*

make prefix=/usr install

if $RUN_TESTS
then
    set +e
    make check
    set -e
fi

make install

