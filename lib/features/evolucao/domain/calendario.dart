/// Contas de dia de calendário usadas pelos modelos (M4, M5, M6, M8). Usa UTC
/// por dentro para um horário de verão nunca fazer um dia ter 23 h. Dart puro.
library;

/// Só o dia (meia-noite local) de [data].
DateTime diaDe(DateTime data) => DateTime(data.year, data.month, data.day);

/// Dias de calendário de [de] até [ate] (negativo se [ate] vier antes).
int diasEntre(DateTime de, DateTime ate) =>
    DateTime.utc(ate.year, ate.month, ate.day).difference(DateTime.utc(de.year, de.month, de.day)).inDays;

/// [dia] + [dias] dias de calendário, à meia-noite local.
DateTime somarDias(DateTime dia, int dias) => DateTime(dia.year, dia.month, dia.day + dias);

/// Número do dia de calendário **local** de [data], contado desde
/// 01/01/1970, com uma só consulta de fuso horário.
///
/// `diasEntre(a, b) == numeroDoDia(b) - numeroDoDia(a)`. Serve de chave e de
/// conta nos laços com muitas pesagens (RNF06, P4-4.3): cada `year`, `month`
/// e `day` de uma data local consulta o fuso de novo.
int numeroDoDia(DateTime data) =>
    ((data.millisecondsSinceEpoch + data.timeZoneOffset.inMilliseconds) / Duration.millisecondsPerDay).floor();

/// O dia (meia-noite local) de número [numero] (ver [numeroDoDia]).
DateTime diaDoNumero(int numero) => DateTime(1970, 1, 1 + numero);
