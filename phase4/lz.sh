# Lz4 phase 4
make BUILD_STATIC=no PREFIX=/usr

if $RUN_TESTS
then
    set +e
    make -j1 check
    set -e
fi

make BUILD_STATIC=no PREFIX=/usr install
