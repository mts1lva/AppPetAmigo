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
