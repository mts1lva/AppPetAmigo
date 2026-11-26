#!/usr/bin/env bash
# Sobe o Firebase Emulator Suite (Auth e Firestore) para os testes de
# integração do grupo. Sem Storage (P-23).
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p emulador-dados
exec firebase emulators:start --import ./emulador-dados --export-on-exit
