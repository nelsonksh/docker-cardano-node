#!/bin/bash
TxIn=$1

cardano-cli transaction build \
--testnet-magic 1 \
--socket-path /ipc/node.socket \
--tx-in $TxIn \
--tx-out addr_test1qqdec2f7zvq4wf0x774mj3ch5calt34w4utkeavpgrp909zpahdfyrqsfel5xvxzz4da87stkj2adclyk47r2sgduvssx3yytp+10000000  \
--change-address addr_test1qqdec2f7zvq4wf0x774mj3ch5calt34w4utkeavpgrp909zpahdfyrqsfel5xvxzz4da87stkj2adclyk47r2sgduvssx3yytp \
--out-file simple-tx.raw

cat simple-tx.raw