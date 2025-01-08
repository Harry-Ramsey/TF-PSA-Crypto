# components-basic-checks.sh
#
# Copyright The Mbed TLS Contributors
# SPDX-License-Identifier: Apache-2.0 OR GPL-2.0-or-later

# This file contains test components that are executed by all.sh

################################################################
#### Basic checks
################################################################

component_tf_psa_crypto_check_doxy_blocks () {
    msg "Check: doxygen markup outside doxygen blocks" # < 1s
    $FRAMEWORK/scripts/check-doxy-blocks.pl
}
component_tf_psa_crypto_check_doxygen_warnings () {
    msg "Check: doxygen warnings (builds the documentation)" # ~ 3s
    cmake -DGEN_FILES=ON .
    make
    $FRAMEWORK/scripts/doxygen.sh
}
