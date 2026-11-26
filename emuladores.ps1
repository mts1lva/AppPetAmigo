# Sobe o Firebase Emulator Suite (Auth e Firestore) para os testes de
# integração do grupo. Sem Storage (P-23).
$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
New-Item -ItemType Directory -Force -Path emulador-dados | Out-Null
firebase emulators:start --import ./emulador-dados --export-on-exit
