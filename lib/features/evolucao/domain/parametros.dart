/// Parâmetros dos modelos M2 a M8 (`modelos-matematicos.md`), cada um numa
/// constante única para mudar num lugar só. Os marcados com P-xx não vêm do
/// enunciado e precisam ser confirmados com o professor (`pendencias.md`).
library;

/// Aviso fixo em toda tela ou PDF que mostre estes números.
const avisoEstimativa = 'Estimativa educativa. Não substitui a avaliação do veterinário.';

// ------------------------------------------------------------------ M2

/// **(P-18)** Diferença de peso por ponto de ECC fora de 4–5 (escala de 9).
const double variacaoPorPontoEcc = 0.10;

/// Escala do ECC (P-03, WSAVA).
const int eccMinimo = 1;
const int eccMaximo = 9;

// ------------------------------------------------------------------ M3

/// **(P-19)** Ritmo da curva ideal: 1% do peso por semana.
const double ritmoSemanalCurvaIdeal = 0.01;

/// Horizonte das curvas (M3, M4) e do eixo X futuro (M6), em dias.
const int horizonteDias = 90;

/// |P − Pi| ≤ 1% de Pi conta como "no peso ideal" (M3 manutenção, M5).
const double toleranciaPesoIdeal = 0.01;

// ------------------------------------------------------------------ M4 (P-20, P-22)

/// **(P-22)** Janela da tendência observada (pesagens), em dias.
const int janelaPesagensDias = 30;

/// **(P-22)** Janela da tendência energética (alimentação e atividade), em dias.
const int janelaEnergiaDias = 14;

/// Mínimo de dias com registro alimentar para a parte energética.
const int minimoDiasComRegistro = 3;

/// **(P-20)** Energia por kg de peso corporal.
const double kcalPorKg = 7700;

/// **(P-22)** `w = min(1, nPesagens30d ÷ 4)`.
const double pesagensParaPesoTotal = 4;

/// **(P-22)** Limite de segurança: 2% do peso por semana.
const double ritmoSemanalMaximo = 0.02;

/// Piso da curva de projeção, em kg.
const double pesoMinimoProjecao = 0.1;

// ------------------------------------------------------------------ M5

/// Abaixo disso o ritmo conta como zero.
const double ritmoMinimo = 0.000001;

/// Acima disso: "Mais de 1 ano com o ritmo atual."
const int diasMaximoPrevisao = 365;

// ------------------------------------------------------------------ M6

/// Eixo X começa em `hoje − 30` (ou na primeira pesagem, se mais recente).
const int diasPassadosGrafico = 30;

/// Margem do eixo Y: 10% da faixa; ±0,5 kg se `max == min`.
const double margemEixoY = 0.10;
const double margemEixoYPlano = 0.5;

// ------------------------------------------------------------------ M8

/// S3 (a): |Patual − Pi| ≤ 2% de Pi.
const double toleranciaPertoDoIdeal = 0.02;

/// S3 (b): previsão acima disso conta como "distante".
const int diasObjetivoDistante = 180;

/// S3 (b): exige pelo menos 14 dias de dados (desde a primeira pesagem).
const int diasMinimosDeDadosS3 = 14;

/// Celebração: a distância até Pi diminuiu pelo menos 100 g.
const int gramasMinimosCelebracao = 100;
