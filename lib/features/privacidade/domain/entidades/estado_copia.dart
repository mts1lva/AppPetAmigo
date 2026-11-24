/// Estado da cópia remota, mostrado no card "Seu controle" do Início e na
/// tela 16 (`pacote-5`: desligada / pendente(n) / sincronizado(hora) / falha /
/// conflito(n)). Dart puro.
///
/// Criado pelo P1 na etapa 1; o P5 é o dono e o calcula de verdade na P5-3.3.
sealed class EstadoCopia {
  const EstadoCopia();
}

/// Cópia remota desligada: "Dados salvos neste aparelho."
final class CopiaDesligada extends EstadoCopia {
  const CopiaDesligada();

  @override
  bool operator ==(Object other) => other is CopiaDesligada;

  @override
  int get hashCode => (CopiaDesligada).hashCode;
}

/// Há [itens] alterações na fila esperando o Wi-Fi.
final class CopiaPendente extends EstadoCopia {
  const CopiaPendente(this.itens);

  final int itens;

  @override
  bool operator ==(Object other) => other is CopiaPendente && other.itens == itens;

  @override
  int get hashCode => Object.hash(CopiaPendente, itens);
}

/// Tudo enviado; último envio confirmado [em].
final class CopiaSincronizada extends EstadoCopia {
  const CopiaSincronizada(this.em);

  final DateTime em;

  @override
  bool operator ==(Object other) => other is CopiaSincronizada && other.em == em;

  @override
  int get hashCode => Object.hash(CopiaSincronizada, em);
}

/// O último envio falhou; os dados locais estão preservados.
final class CopiaComFalha extends EstadoCopia {
  const CopiaComFalha();

  @override
  bool operator ==(Object other) => other is CopiaComFalha;

  @override
  int get hashCode => (CopiaComFalha).hashCode;
}

/// Há [registros] em conflito esperando decisão na tela 17.
final class CopiaComConflito extends EstadoCopia {
  const CopiaComConflito(this.registros);

  final int registros;

  @override
  bool operator ==(Object other) => other is CopiaComConflito && other.registros == registros;

  @override
  int get hashCode => Object.hash(CopiaComConflito, registros);
}
