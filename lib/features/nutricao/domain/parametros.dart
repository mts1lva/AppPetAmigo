/// Parâmetros do M1 (`modelos-matematicos.md`), cada um numa constante única
/// para mudar num lugar só. Os marcados com P-xx não vêm do enunciado e
/// precisam ser confirmados com o professor (`pendencias.md`).
library;

/// RER = [coeficienteRer] × peso^[expoenteRer] (NRC).
const double coeficienteRer = 70;
const double expoenteRer = 0.75;

/// Fatores de atividade do enunciado (U2-01).
const double fatorFilhote = 3.0;
const double fatorAtivo = 2.0;
const double fatorCastrado = 1.6;

/// **(P-17)** Adulto não castrado com atividade baixa ou moderada. Não
/// definido no enunciado. Os mesmos fatores valem para cães e gatos (P-17).
const double fatorAdultoNaoCastrado = 1.8;
