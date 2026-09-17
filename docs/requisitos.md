# Funcionalidades e requisitos - PetAmigo

**Atividade 03 | Programação para Dispositivos Móveis**
**Equipe:** Matheus Silva, Raissa Andrade Santos, João Lopes, Paulo Emanuel e Matheus Leão.
**Situação:** especificação proposta para desenvolvimento; critérios de aceitação ainda não executados no aplicativo.

## 1. Requisitos funcionais

Requisitos descrevem comportamentos futuros do sistema, não funcionalidades já implementadas.

### RF01 - Cadastro e edição do pet

O sistema deve permitir cadastrar e editar um único pet, informando nome, espécie, idade, castração, nível de atividade e peso, além de foto opcional no cadastro, que deve poder ser adicionada posteriormente. Deve validar campos obrigatórios e valores positivos.

**Origem:** F01.

### RF02 - Consulta do perfil e resumo

O sistema deve exibir a foto cadastrada, os dados do pet, a meta vigente e os totais de ração e petiscos da data selecionada, identificando valores ausentes como não informados.

**Origem:** F01.

### RF03 - Estimativa de energia

O sistema deve calcular uma referência diária em kcal usando fórmula NRC com edição, equação, parâmetros, unidades e limites de aplicação documentados; deve mostrar a fonte e impedir o cálculo se faltarem dados ou se o perfil estiver fora dos limites validados.

**Origem:** F02.

### RF04 - Conversão para gramas

O sistema deve converter a meta de energia em gramas do alimento a partir da densidade energética e unidade informadas no rótulo; deve rejeitar densidade nula ou negativa e informar quando não for possível converter. Deve permitir cadastrar, consultar, alterar e excluir alimentos e porções reutilizáveis, preservando nos registros antigos os valores usados na ocasião.

**Origem:** F02.

### RF05 - Inclusão de refeição

O sistema deve registrar refeição com alimento, quantidade em gramas, energia calculada, data/hora e vínculo ao pet, permitindo reutilizar alimento e porção previamente configurados.

**Origem:** F03.

### RF06 - Manutenção do diário

O sistema deve permitir consultar refeições por data, editar seus dados e excluir um registro selecionado, recalculando os totais após cada alteração.

**Origem:** F03.

### RF07 - Manutenção de petiscos

O sistema deve permitir criar, consultar, editar e excluir petiscos ou extras, registrando quantidade, energia, data/hora e categoria separada da ração.

**Origem:** F04.

### RF08 - Resumo alimentar

O sistema deve somar as calorias registradas de ração e extras, comparar o total com a meta e mostrar a parcela dos petiscos; sem meta válida, deve exibir os totais e informar que a comparação está indisponível.

**Origem:** F04.

### RF09 - Pesagens

O sistema deve permitir criar, consultar, editar e excluir pesagens em kg com data/hora; deve rejeitar valores não positivos e solicitar conferência de uma variação suspeita sem descartar silenciosamente o dado.

**Origem:** F05.

### RF10 - ECC e objetivo de peso

O sistema deve permitir registrar e atualizar o ECC informado e o objetivo de peso orientado pelo veterinário, com data e origem; deve explicar o ECC e, se houver estimativa de peso de referência, identificar o método validado e seus limites, sem diagnosticar o animal. Deve permitir consultar e remover essas referências sem apagar as pesagens.

**Origem:** F05.

### RF11 - Consulta da evolução

O sistema deve gerar um gráfico das pesagens em ordem cronológica, indicar o objetivo quando existente e diferenciar ausência de dados de peso zero; com uma única pesagem, deve mostrar apenas o ponto disponível.

**Origem:** F06.

### RF12 - Manutenção de atividades

O sistema deve permitir criar, consultar, editar e excluir passeios e brincadeiras, informando tipo, duração em minutos e data/hora; não deve descontar calorias da meta sem método de gasto energético validado.

**Origem:** F07.

### RF13 - Exportação e compartilhamento

O sistema deve gerar um resumo do período escolhido com perfil, alimentação, atividades, pesagens, lacunas e fonte da estimativa; deve abrir o compartilhamento nativo apenas após solicitação do tutor, sem envio automático.

**Origem:** F08.

### RF14 - Operações locais

O sistema deve executar o cadastro, o cálculo com referências já instaladas, os registros e a consulta do histórico sem internet, persistindo os dados antes de confirmar o salvamento.

**Origem:** F09.

### RF15 - Fila de sincronização

O sistema deve, após ativação da cópia remota, enfileirar inclusões, alterações e exclusões, sincronizar apenas por Wi-Fi e mostrar os estados pendente, sincronizado e falha; deve reutilizar IDs para evitar duplicação em tentativas repetidas.

**Origem:** F09.

### RF16 - Controles de privacidade

O sistema deve apresentar no perfil as finalidades do tratamento, os dados armazenados, os controles de cópia remota e o acesso à exclusão; a ativação da cópia remota deve ser opcional e reversível.

**Origem:** F10.

### RF17 - Exclusão integral

O sistema deve, após confirmação explícita, excluir perfil, foto, metas e registros locais e solicitar a remoção das cópias remotas; se estiver offline, deve manter apenas a solicitação técnica pendente, impedir restauração e comunicar conclusão somente após confirmação remota.

**Origem:** F10.

### RF18 - Consulta de dicas

O sistema deve apresentar dicas educativas por espécie na tela de atividades, com fonte e data de revisão, acessíveis offline após instalação ou atualização do conteúdo.

**Origem:** F11.

### RF19 - Mensagens de progresso

O sistema deve apresentar mensagens positivas relacionadas à continuidade dos registros ou à aproximação do objetivo informado; variação de peso sem objetivo válido não deve ser classificada automaticamente como melhora.

**Origem:** F12.

### RF20 - Retorno após ausência

O sistema deve permitir retomar o registro após dias sem uso, sem exigir preenchimento retroativo e sem tratar dias sem informação como consumo zero ou falha do tutor.

**Origem:** F12.
