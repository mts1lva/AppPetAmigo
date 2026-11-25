/// Parâmetros da aderência (M7) e da sugestão S1 (`modelos-matematicos.md`).
/// Cada um numa constante única para mudar num lugar só.
library;

/// Janela da aderência ao plano alimentar (M7): últimos 14 dias.
const int janelaAderenciaDias = 14;

/// Faixa de um dia aderente: ±10% da meta (M7).
const double faixaAderencia = 0.10;

/// Janela da sugestão S1: últimos 7 dias com registro.
const int janelaSugestaoPetiscosDias = 7;

/// Limite da parcela de petiscos no total do dia (S1, AAHA/WSAVA).
const double parcelaExtrasLimite = 0.10;

/// Mínimo de dias acima do limite, na janela, para sugerir (S1).
const int diasMinimosSugestaoPetiscos = 3;
