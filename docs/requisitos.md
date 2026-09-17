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


## 2. Contexto e decisões de escopo

O PetAmigo apoia tutores de cães e gatos no acompanhamento da alimentação, atividade e evolução do peso. A persona prioritária é **Marina Oliveira**, que precisa criar o hábito sem culpa; **Bruno Santos** precisa de registros rápidos, confiáveis e disponíveis offline.

Esta especificação deriva de [estudo de caso](estudo-de-caso.md), [pesquisa](pesquisa.md), [personas](personas.md) e [benchmark](benchmark.md). A pesquisa é documental; não se pressupõem entrevistas ou testes com usuários que não estejam documentados.

**Escopo:** quatro telas principais e um único pet: perfil/resumo, diário, atividades e evolução do peso. Recursos complementares ficam em seções ou diálogos.

**Interações:** até três interações para acessar o diário; dois toques para concluir o registro habitual a partir do atalho, com alimento e porção previamente definidos. Configuração inicial e correções podem exigir preenchimento.

**Dados nutricionais:** a meta é uma referência, com fórmula NRC documentada e validação profissional pendente. Não são inventados fatores ou fórmulas nesta atividade. Peso de referência e ECC não constituem diagnóstico. Perfis sem método validado devem receber orientação para consulta, sem estimativa numérica automática.

**Petiscos:** a pesquisa posterior diferencia recomendação de limite e consumo observado. O valor de 30% citado no estudo de caso não será usado como regra universal nem como limite do sistema. Eventuais limiares educativos dependerão da fonte documentada e da revisão técnica.

**Atividade:** registrar duração não autoriza converter minutos em calorias ou compensar automaticamente a alimentação.

**Sincronização:** o uso local independe de conta; a cópia remota, quando ativada, exige identidade autenticada, isolamento por usuário e transmissão apenas por Wi-Fi. A autenticação será apresentada em diálogo do perfil. Dois aparelhos editando o mesmo dado devem gerar conflito visível, sem sobrescrita silenciosa; exclusão confirmada tem precedência para impedir restauração.

**Privacidade:** o projeto protegerá também dados do tutor que possam existir em identificadores, fotos e exportações. Não se presume que todo dado do pet seja automaticamente dado pessoal sensível na classificação legal; a definição da base legal e da política de retenção deve ser revisada antes da operação real.

## 3. Funcionalidades

Para cada funcionalidade, são indicados descrição, necessidade, justificativa, origem e prioridade. A classificação completa e suas dependências aparecem na seção 6.

### F01 - Perfil do pet e dashboard

O sistema deve permitir cadastrar um único cão ou gato, com foto, espécie, idade, castração, atividade, peso e dados necessários ao cálculo; consultar o resumo diário.

**Necessidade do usuário:** Marina precisa reconhecer Luna e entender a situação do dia; Bruno precisa centralizar os dados.

**Justificativa:** Os dados do perfil sustentam a personalização; a foto e o resumo favorecem o vínculo e a compreensão.

**Relação com os estudos:** Personas; estudo de caso 2.5 e 2.7.

**Prioridade:** Essencial.

**Requisitos associados:** RF01, RF02.

### F02 - Referência calórica e quantidade de alimento

O sistema deve estimar a meta diária por fórmula NRC documentada e converter a energia em gramas com a densidade energética informada no rótulo.

**Necessidade do usuário:** Marina precisa entender quanto oferecer; Bruno quer conhecer a origem da estimativa.

**Justificativa:** Transforma os dados do pet em uma referência compreensível, com limites de aplicação explícitos.

**Relação com os estudos:** Pesquisa 2.2 e descoberta 1.

**Prioridade:** Essencial.

**Requisitos associados:** RF03, RF04.

### F03 - Diário de refeições

O sistema deve permitir registrar, consultar, corrigir e excluir refeições, identificando alimento, quantidade, energia e data/hora.

**Necessidade do usuário:** Bruno precisa registrar na cozinha com uma mão; Marina precisa de um fluxo curto.

**Justificativa:** É a funcionalidade mais importante: os registros alimentam o resumo e permitem comparar a rotina com a meta.

**Relação com os estudos:** Personas; pesquisa 3 e descoberta 3; estudo de caso 2.8.

**Prioridade:** Essencial.

**Requisitos associados:** RF05, RF06.

### F04 - Petiscos e extras separados

O sistema deve permitir registrar petiscos separadamente e apresentar sua participação no consumo e na meta diária.

**Necessidade do usuário:** Marina precisa perceber as calorias dos extras; Bruno quer separar as categorias.

**Justificativa:** Evita que o acompanhamento considere somente a ração e mostre um consumo incompleto.

**Relação com os estudos:** Pesquisa 2.3 e descoberta 2.

**Prioridade:** Essencial.

**Requisitos associados:** RF07, RF08.

### F05 - Peso, ECC e objetivo de acompanhamento

O sistema deve permitir registrar pesagens e ECC informado, explicar o conceito e acompanhar um objetivo de peso definido com orientação profissional.

**Necessidade do usuário:** Marina precisa compreender a condição corporal; Bruno precisa de medidas confiáveis.

**Justificativa:** Relaciona o acompanhamento à condição do animal sem transformar peso isolado em diagnóstico.

**Relação com os estudos:** Pesquisa 2.4; estudo de caso 2.6.

**Prioridade:** Essencial.

**Requisitos associados:** RF09, RF10.

### F06 - Gráfico de evolução

O sistema deve exibir as pesagens por data e o objetivo informado, destacando períodos sem dados.

**Necessidade do usuário:** Marina precisa perceber evolução; Bruno revisa tendências semanalmente.

**Justificativa:** Torna visíveis as mudanças ao longo do tempo e ajuda a discutir a rotina na consulta.

**Relação com os estudos:** Personas; pesquisa descoberta 1.

**Prioridade:** Essencial.

**Requisitos associados:** RF11.

### F07 - Passeios e atividades

- **Descrição:** Registrar tipo de atividade, duração e data/hora; consultar, corrigir e excluir os registros.
- **Necessidade do usuário:** Bruno registra ao terminar o passeio; Marina precisa incluir brincadeiras com Luna.
- **Justificativa:** Relaciona a atividade à rotina sem exigir GPS, coleira inteligente ou estimativa inventada de gasto calórico.
- **Relação com os estudos:** Pesquisa 3; estudo de caso 2.6; benchmark 4.
- **Prioridade:** Essencial.
- **Requisitos associados:** RF12.

### F08 - Histórico compartilhável

- **Descrição:** Gerar um resumo do período e abrir o compartilhamento nativo mediante ação do tutor.
- **Necessidade do usuário:** Marina e Bruno precisam levar informações organizadas ao veterinário.
- **Justificativa:** Facilita a comunicação, incluindo lacunas e fontes do cálculo para interpretar os registros.
- **Relação com os estudos:** Personas; pesquisa 3; benchmark 6.
- **Prioridade:** Importante.
- **Requisitos associados:** RF13.

### F09 - Uso offline e sincronização por Wi-Fi

- **Descrição:** Salvar as ações localmente, enfileirar alterações e sincronizar somente por Wi-Fi quando o tutor ativar a cópia remota.
- **Necessidade do usuário:** Bruno precisa evitar perdas na rua; Marina precisa registrar mesmo sem rede.
- **Justificativa:** O registro deve acontecer no momento do cuidado, independentemente da conectividade.
- **Relação com os estudos:** Personas; estudo de caso 2.7.
- **Prioridade:** Essencial.
- **Requisitos associados:** RF14, RF15.

### F10 - Privacidade e exclusão dos dados

- **Descrição:** Disponibilizar explicação de uso dos dados e exclusão integral do perfil, foto, registros e cópias sincronizadas.
- **Necessidade do usuário:** Os tutores precisam controlar as informações armazenadas e compartilhadas.
- **Justificativa:** Atende à restrição explícita de exclusão total e torna o estado da remoção visível.
- **Relação com os estudos:** Estudo de caso 2.7.
- **Prioridade:** Essencial.
- **Requisitos associados:** RF16, RF17.

### F11 - Dicas de exercício e enriquecimento

- **Descrição:** Consultar conteúdo educativo adequado à espécie, disponível dentro da tela de atividades.
- **Necessidade do usuário:** Marina precisa de alternativas aos petiscos para interagir com Luna.
- **Justificativa:** Apoia o cuidado cotidiano e o papel educativo definido no estudo de caso.
- **Relação com os estudos:** Estudo de caso 2.6; persona Marina.
- **Prioridade:** Importante.
- **Requisitos associados:** RF18.

### F12 - Celebrações de pequenas conquistas

- **Descrição:** Apresentar mensagens acolhedoras de continuidade e progresso compatível com o objetivo informado.
- **Necessidade do usuário:** Marina precisa de motivação sem culpa, inclusive após dias sem usar o app.
- **Justificativa:** Apoia a formação do hábito; não celebra automaticamente qualquer redução de peso.
- **Relação com os estudos:** Personas; estudo de caso 2.5 e 2.8.
- **Prioridade:** Secundária.
- **Requisitos associados:** RF19, RF20.
