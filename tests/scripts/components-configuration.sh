# components-configuration.sh
#
# Copyright The Mbed TLS Contributors
# SPDX-License-Identifier: Apache-2.0 OR GPL-2.0-or-later

# This file contains test components that are executed by all.sh

################################################################
#### Configuration Testing
################################################################

component_tf_psa_crypto_test_default_out_of_box () {
    msg "build: make, default config (out-of-box)" # ~1min
    cd $OUT_OF_SOURCE_DIR
    cmake -DCMAKE_BUILD_TYPE:String=Check -DGEN_FILES=ON "$TF_PSA_CRYPTO_ROOT_DIR"
    make
    # Disable fancy stuff
    unset MBEDTLS_TEST_OUTCOME_FILE

    msg "test: main suites make, default config (out-of-box)" # ~10s
    make test
}

component_tf_psa_crypto_test_default_cmake_gcc_asan () {
    msg "build: cmake, gcc, ASan" # ~ 1 min 50s
    cd $OUT_OF_SOURCE_DIR
    cmake -DCMAKE_C_COMPILER=gcc -DCMAKE_BUILD_TYPE:String=Asan -DGEN_FILES=ON "$TF_PSA_CRYPTO_ROOT_DIR"
    make

    msg "test: main suites (inc. selftests) (ASan build)" # ~ 50s
    make test
}

component_tf_psa_crypto_test_default_cmake_gcc_asan_new_bignum () {
    msg "build: cmake, gcc, ASan" # ~ 1 min 50s
    scripts/config.py set MBEDTLS_ECP_WITH_MPI_UINT
    cd $OUT_OF_SOURCE_DIR
    cmake -DCMAKE_C_COMPILER=gcc -DCMAKE_BUILD_TYPE:String=Asan -DGEN_FILES=ON "$TF_PSA_CRYPTO_ROOT_DIR"
    make

    msg "test: main suites (inc. selftests) (ASan build)" # ~ 50s
    make test
}

component_tf_psa_crypto_test_full_cmake_gcc_asan () {
    msg "build: full config, cmake, gcc, ASan"
    scripts/config.py full
    cd $OUT_OF_SOURCE_DIR
    cmake -DCMAKE_C_COMPILER=gcc -DCMAKE_BUILD_TYPE:String=Asan -DGEN_FILES=ON "$TF_PSA_CRYPTO_ROOT_DIR"
    make

    msg "test: main suites (inc. selftests) (full config, ASan build)"
    make test
}

component_tf_psa_crypto_test_full_cmake_gcc_asan_new_bignum () {
    msg "build: full config, cmake, gcc, ASan"
    scripts/config.py full
    scripts/config.py set MBEDTLS_ECP_WITH_MPI_UINT
    cd $OUT_OF_SOURCE_DIR
    cmake -DCMAKE_C_COMPILER=gcc -DCMAKE_BUILD_TYPE:String=Asan -DGEN_FILES=ON "$TF_PSA_CRYPTO_ROOT_DIR"
    make

    msg "test: main suites (inc. selftests) (full config, new bignum, ASan)"
    make test
}

component_tf_psa_crypto_test_full_cmake_clang () {
    msg "build: cmake, full config, clang" # ~ 50s
    scripts/config.py full
    cd $OUT_OF_SOURCE_DIR
    cmake -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang -DCMAKE_BUILD_TYPE:String=Release -DENABLE_TESTING=ON -DTEST_CPP=1 -DGEN_FILES=ON "$TF_PSA_CRYPTO_ROOT_DIR"
    make

    msg "test: main suites (full config, clang)" # ~ 5s
    make test
}

component_tf_psa_crypto_build_tfm () {
    # Check that the TF-M configuration can build cleanly with various
    # warning flags enabled. We don't build or run tests, since the
    # TF-M configuration needs a TF-M platform. A tweaked version of
    # the configuration that works on mainstream platforms is in
    # configs/config-tfm.h, tested via test-ref-configs.pl.
    cp configs/ext/crypto_config_profile_medium.h "$CRYPTO_CONFIG_H"

    cd $OUT_OF_SOURCE_DIR
    msg "build: TF-M config, clang, armv7-m thumb2"
    cmake -DCMAKE_C_COMPILER=clang -DCMAKE_C_FLAGS="--target=arm-linux-gnueabihf -march=armv7-m -mthumb -Os -std=c99 -Werror -Wall -Wextra -Wwrite-strings -Wpointer-arith -Wimplicit-fallthrough -Wshadow -Wvla -Wformat=2 -Wno-format-nonliteral -Wshadow -Wasm-operand-widths -Wunused -I../framework/tests/include/spe" "$TF_PSA_CRYPTO_ROOT_DIR"
    make

    cd $TF_PSA_CRYPTO_ROOT_DIR
    rm -rf $OUT_OF_SOURCE_DIR
    mkdir $OUT_OF_SOURCE_DIR
    cd $OUT_OF_SOURCE_DIR
    msg "build: TF-M config, gcc native build"
    cmake -DCMAKE_C_COMPILER=gcc -DCMAKE_C_FLAGS="-Os -std=c99 -Werror -Wall -Wextra -Wwrite-strings -Wpointer-arith -Wshadow -Wvla -Wformat=2 -Wno-format-nonliteral -Wshadow -Wformat-signedness -Wlogical-op -I../framework/tests/include/spe"
    make
}

component_tf_psa_crypto_test_malloc_0_null () {
    msg "build: malloc(0) returns NULL (ASan+UBSan build)"
    scripts/config.py full
    cd $OUT_OF_SOURCE_DIR
    cmake -DCMAKE_C_COMPILER="$ASAN_CC" -DCMAKE_C_FLAGS="'-DTF_PSA_CRYPTO_USER_CONFIG_FILE=\"$PWD/tests/configs/user-config-malloc-0-null.h\"' $ASAN_CFLAGS" -DCMAKE_EXE_LINKER_FLAGS="$ASAN_CFLAGS" "$TF_PSA_CRYPTO_ROOT_DIR"
    make

    msg "test: malloc(0) returns NULL (ASan+UBSan build)"
    make test
}

component_tf_psa_crypto_test_memory_buffer_allocator_backtrace () {
    msg "build: default config with memory buffer allocator and backtrace enabled"
    scripts/config.py set MBEDTLS_MEMORY_BUFFER_ALLOC_C
    scripts/config.py set MBEDTLS_PLATFORM_MEMORY
    scripts/config.py set MBEDTLS_MEMORY_BACKTRACE
    scripts/config.py set MBEDTLS_MEMORY_DEBUG
    cd $OUT_OF_SOURCE_DIR
    cmake -DCMAKE_BUILD_TYPE:String=Release -DGEN_FILES=ON "$TF_PSA_CRYPTO_ROOT_DIR"
    make

    msg "test: MBEDTLS_MEMORY_BUFFER_ALLOC_C and MBEDTLS_MEMORY_BACKTRACE"
    make test
}

component_tf_psa_crypto_test_memory_buffer_allocator () {
    msg "build: default config with memory buffer allocator"
    scripts/config.py set MBEDTLS_MEMORY_BUFFER_ALLOC_C
    scripts/config.py set MBEDTLS_PLATFORM_MEMORY
    cd $OUT_OF_SOURCE_DIR
    cmake -DCMAKE_BUILD_TYPE:String=Release -DGEN_FILES=ON "$TF_PSA_CRYPTO_ROOT_DIR"
    make

    msg "test: MBEDTLS_MEMORY_BUFFER_ALLOC_C"
    make test
}
