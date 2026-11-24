#!/usr/bin/env bash
# Hook UserPromptSubmit do Claude Code: quando a mensagem fala em executar
# uma entrega (código de tarefa como P2-1.3, "entrega", "tarefa", "pacote"),
# lembra o Claude de usar a skill executar-entrega. Em shell, e não em Dart,
# para funcionar mesmo antes de a pessoa instalar o Flutter e não atrasar
# cada mensagem. Nunca bloqueia a conversa.

entrada=$(cat)

if printf '%s' "$entrada" | grep -qiE 'P[1-5]-[0-9]+\.[0-9]+|entrega|tarefa|pacote'; then
  codigos=$(printf '%s' "$entrada" | grep -oiE 'P[1-5]-[0-9]+\.[0-9]+' | tr '[:lower:]' '[:upper:]' | sort -u | paste -sd ',' - | sed 's/,/, /g')
  if [ -n "$codigos" ]; then
    echo "A mensagem cita tarefa(s) do plano: $codigos."
  fi
  echo "Se o pedido é executar, começar ou continuar uma entrega ou tarefa do plano, use a skill executar-entrega antes de qualquer outra coisa (ela confere o ambiente, o pacote da pessoa e as dependências)."
fi

exit 0
