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

## 2. Contexto e decisões de escopo

O PetAmigo apoia tutores de cães e gatos no acompanhamento da alimentação, atividade e evolução do peso. A persona prioritária é **Marina Oliveira**, que precisa criar o hábito sem culpa; **Bruno Santos** precisa de registros rápidos, confiáveis e disponíveis offline.

Esta especificação deriva de [estudo de caso](estudo-de-caso.md), [pesquisa](pesquisa.md), [personas](personas.md) e [benchmark](benchmark.md). 

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

O sistema deve permitir registrar tipo de atividade, duração e data/hora; consultar, corrigir e excluir os registros.

**Necessidade do usuário:** Bruno registra ao terminar o passeio; Marina precisa incluir brincadeiras com Luna.

**Justificativa:** Relaciona a atividade à rotina sem exigir GPS, coleira inteligente ou estimativa inventada de gasto calórico.

**Relação com os estudos:** Pesquisa 3; estudo de caso 2.6; benchmark 4.

**Prioridade:** Essencial.

**Requisitos associados:** RF12.

### F08 - Histórico compartilhável

O sistema deve gerar um resumo do período e abrir o compartilhamento nativo mediante ação do tutor.

**Necessidade do usuário:** Marina e Bruno precisam levar informações organizadas ao veterinário.

**Justificativa:** Facilita a comunicação, incluindo lacunas e fontes do cálculo para interpretar os registros.

**Relação com os estudos:** Personas; pesquisa 3; benchmark 6.

**Prioridade:** Importante.

**Requisitos associados:** RF13.

### F09 - Uso offline e sincronização por Wi-Fi

O sistema deve salvar as ações localmente, enfileirar alterações e sincronizar somente por Wi-Fi quando o tutor ativar a cópia remota.

**Necessidade do usuário:** Bruno precisa evitar perdas na rua; Marina precisa registrar mesmo sem rede.

**Justificativa:** O registro deve acontecer no momento do cuidado, independentemente da conectividade.

**Relação com os estudos:** Personas; estudo de caso 2.7.

**Prioridade:** Essencial.

**Requisitos associados:** RF14, RF15.

### F10 - Privacidade e exclusão dos dados

O sistema deve disponibilizar explicação de uso dos dados e exclusão integral do perfil, foto, registros e cópias sincronizadas.

**Necessidade do usuário:** Os tutores precisam controlar as informações armazenadas e compartilhadas.

**Justificativa:** Atende à restrição explícita de exclusão total e torna o estado da remoção visível.

**Relação com os estudos:** Estudo de caso 2.7.

**Prioridade:** Essencial.

**Requisitos associados:** RF16, RF17.

### F11 - Dicas de exercício e enriquecimento

O sistema deve permitir consultar conteúdo educativo adequado à espécie, disponível dentro da tela de atividades.

**Necessidade do usuário:** Marina precisa de alternativas aos petiscos para interagir com Luna.

**Justificativa:** Apoia o cuidado cotidiano e o papel educativo definido no estudo de caso.

**Relação com os estudos:** Estudo de caso 2.6; persona Marina.

**Prioridade:** Importante.

**Requisitos associados:** RF18.

### F12 - Celebrações de pequenas conquistas

O sistema deve apresentar mensagens acolhedoras de continuidade e progresso compatível com o objetivo informado.

**Necessidade do usuário:** Marina precisa de motivação sem culpa, inclusive após dias sem usar o app.

**Justificativa:** Apoia a formação do hábito; não celebra automaticamente qualquer redução de peso.

**Relação com os estudos:** Personas; estudo de caso 2.5 e 2.8.

**Prioridade:** Secundária.

**Requisitos associados:** RF19, RF20.

## 4. Requisitos não funcionais

Os valores abaixo são critérios propostos de aceitação para o projeto. As metas novas de desempenho e acessibilidade devem ser verificadas na implementação; não representam testes já realizados.

### RNF01 - Usabilidade

O acesso ao diário a partir do perfil deve exigir no máximo três interações. Com alimento e porção já configurados, abrir o atalho e confirmar a refeição deve exigir no máximo dois toques, sem digitação obrigatória.

**Como verificar:** Contar toques no protótipo; cadastro inicial e correções são fluxos separados.

### RNF02 - Acessibilidade

Os controles acionáveis devem ter área mínima de 48 x 48 dp; os campos devem ter rótulos para leitor de tela, e gráficos e alertas não devem depender apenas de cor. O texto deve continuar utilizável com escala de fonte de 200%.

**Como verificar:** Inspecionar alvos, navegar com TalkBack e testar fonte ampliada nas quatro telas.

### RNF03 - Legibilidade

Textos comuns devem ter contraste mínimo de 4,5:1 com o fundo e textos grandes de 3:1; a paleta pastel deve preservar leitura de valores, unidades e ações.

**Como verificar:** Medir pares de cores e revisar a leitura em ambiente externo.

### RNF04 - Proteção e minimização

O aplicativo deve armazenar somente os dados necessários às funções descritas, manter o banco em área privada, proteger cópias remotas por controle de acesso e usar conexão cifrada na sincronização. Logs não devem expor fotos ou dados pessoais.

**Como verificar:** Inspecionar permissões, logs e tráfego; testar negação de acesso entre usuários de teste.

### RNF05 - Privacidade verificável

O aplicativo deve informar finalidades e controles em linguagem simples, permitir exportação e exclusão e restringir a cópia remota à ativação pelo tutor. A exclusão remota deve abranger dados ativos e ter política documentada de expiração de backups.

**Como verificar:** Testar exclusão local/remota e impedir restauração de dados excluídos; revisar política antes de disponibilização.

### RNF06 - Desempenho

Em Android 8.0, 2 GB de RAM e base de 1.000 registros, salvar localmente deve levar até 1 segundo e abrir o resumo ou gráfico até 2 segundos em pelo menos 95% de 20 execuções por ação.

**Como verificar:** Medir 20 execuções após inicialização; registrar aparelho, versão e resultados. Metas propostas, ainda não medidas.

### RNF07 - Compatibilidade

O aplicativo deve executar em celulares Android 8.0 ou superior, com gráficos leves e sem depender de GPS, sensores especiais ou acessórios externos para as funções essenciais.

**Como verificar:** Validar instalação e fluxos essenciais no Android 8.0 e em versão posterior definida pela equipe.

### RNF08 - Persistência e integridade

Registros confirmados devem sobreviver ao fechamento e reinício do aplicativo; gravações devem ser atômicas e cada registro deve possuir identificador estável. Correções devem preservar a consistência dos totais.

**Como verificar:** Salvar, fechar, reabrir, corrigir e excluir; comparar banco e totais exibidos.

### RNF09 - Conectividade

As funções essenciais devem operar em modo avião. A sincronização não deve transmitir dados pela rede móvel e deve retomar uma fila interrompida sem duplicar nem restaurar registros excluídos.

**Como verificar:** Alternar modo avião, rede móvel e Wi-Fi; interromper e repetir sincronização com a mesma fila.

### RNF10 - Escopo e navegação

A versão deve manter quatro telas principais: perfil/resumo, diário, atividades e evolução do peso. Dicas, privacidade, cálculo e compartilhamento devem usar seções, painéis ou diálogos nessas telas.

**Como verificar:** Conferir mapa de navegação, incluindo estados vazios e diálogos, sem criar quinta tela principal.

### RNF11 - Confiabilidade do cálculo

Toda fórmula ou fator nutricional deve possuir referência, versão, unidades e limites documentados e ser validado com casos de referência antes de uso. O produto não deve apresentar a estimativa como diagnóstico ou prescrição.

**Como verificar:** Revisar catálogo de fórmulas e conferir resultados com casos aprovados por profissional; validação ainda pendente.

### RNF12 - Identidade e linguagem

O perfil/resumo deve exibir a foto quando cadastrada; a interface deve usar ilustrações de pets sorrindo e mensagens acolhedoras. Ausência de dados e alertas não devem usar culpa nem classificar toda perda de peso como sucesso.

**Como verificar:** Revisar textos e elementos visuais com cenários de Marina, Bruno e dias sem registro.
## 5. CRUD

C = criar; R = consultar; U = atualizar; D = excluir. As operações do tutor ficam limitadas aos dados do próprio perfil.

| Informação | C | R | U | D | Requisitos / justificativa |
|---|---|---|---|---|---|
| Perfil e foto | Cadastrar pet/foto | Ver perfil | Editar dados/trocar foto | Excluir todo o perfil | RF01, RF02, RF17 |
| Alimento e porção reutilizável | Cadastrar alimento/porção | Consultar no diário | Corrigir porção/densidade | Excluir predefinição | RF04, RF05, RF06 |
| Refeição | Adicionar refeição | Consultar por data | Corrigir quantidade/data | Excluir refeição | RF05, RF06 |
| Petisco/extra | Adicionar extra | Consultar por data | Corrigir quantidade/energia | Excluir extra | RF07, RF08 |
| Pesagem | Adicionar peso/data | Consultar histórico | Corrigir peso/data | Excluir pesagem | RF09, RF11 |
| ECC e objetivo | Informar valor e origem | Consultar referência | Atualizar com data | Remover referência | RF10 |
| Atividade | Adicionar passeio/brincadeira | Consultar histórico | Corrigir duração/tipo | Excluir atividade | RF12 |
| Dicas e fórmulas | Não pelo tutor | Ler conteúdo/fonte | Não pelo tutor | Não pelo tutor | RF03, RF18; conteúdo mantido e versionado pela equipe |
| Gráfico, totais e exportação | Gerados a partir dos registros | Consultar/compartilhar | Recalculados | Sem exclusão independente | RF08, RF11, RF13; visões derivadas, sem cadastro próprio |

### Exemplo completo: refeição

1. **Criar:** Bruno registra 60 g do alimento já cadastrado para Theo, com data e hora.
2. **Consultar:** abre o diário e vê a refeição e o total do dia.
3. **Atualizar:** percebe que ofereceu 50 g, corrige o registro e o sistema recalcula a energia com a densidade salva nesse registro.
4. **Excluir:** identifica um registro duplicado e o remove; os totais são recalculados e a exclusão entra na fila de sincronização, se ativada.

Os valores de 60 g e 50 g apenas ilustram operações de dados; não são recomendação alimentar. Remover um alimento dos atalhos não apaga refeições antigas. Dicas e fórmulas não possuem CRUD pelo tutor porque são conteúdo técnico versionado pela equipe. Gráfico e totais são resultados calculados: mudam quando os registros de origem mudam. O arquivo já compartilhado fica sob controle do destinatário; excluir o app não recolhe cópias enviadas externamente.

## 6. Priorização

**Essencial:** indispensável à proposta ou a uma restrição obrigatória. **Importante:** agrega valor, mas não impede o ciclo central. **Secundária:** pode ser desenvolvida posteriormente.

| Funcionalidade | Prioridade | Motivo e dependências |
|---|---|---|
| F01 - Perfil do pet e dashboard | Essencial | Base dos dados e do vínculo com o pet. |
| F02 - Referência calórica e quantidade de alimento | Essencial | Referência para interpretar a alimentação; depende de F01 e da validação técnica. |
| F03 - Diário de refeições | Essencial | Produz o dado diário que sustenta o acompanhamento; depende de F01 e do cadastro de alimento. |
| F04 - Petiscos e extras separados | Essencial | Evita omissão dos extras; compartilha a estrutura do diário. |
| F05 - Peso, ECC e objetivo de acompanhamento | Essencial | Fornece medidas e objetivo para acompanhar o pet; depende de F01. |
| F06 - Gráfico de evolução | Essencial | Mostra a evolução; depende das pesagens de F05. |
| F07 - Passeios e atividades | Essencial | Integra a rotina e atende à tela de atividades exigida no estudo de caso. |
| F08 - Histórico compartilhável | Importante | Apoia a consulta; depende dos registros de F03 a F07. |
| F09 - Uso offline e sincronização por Wi-Fi | Essencial | Evita perda dos registros e atende à restrição offline/Wi-Fi. O uso local vem primeiro; a sincronização integra o escopo completo. |
| F10 - Privacidade e exclusão dos dados | Essencial | Controle dos dados e exclusão são condições obrigatórias desde a primeira versão. |
| F11 - Dicas de exercício e enriquecimento | Importante | Complementa a rotina; pode entrar após o registro de atividades, mas permanece no escopo completo do estudo de caso. |
| F12 - Celebrações de pequenas conquistas | Secundária | Reforça o hábito após haver dados e objetivo válidos; é etapa posterior, sem remover a exigência do escopo completo. |

### Funcionalidade mais importante

**F03 - Diário de refeições.** Sem registros rápidos e confiáveis do que foi oferecido, a meta não pode ser comparada ao consumo e o acompanhamento perde sua base. Para Bruno, a prioridade é registrar durante a rotina sem demora; para Marina, o baixo esforço ajuda a formar o hábito. Por isso F03 deve funcionar offline (F09), reutilizar porções e somar os petiscos de F04. A calculadora orienta a meta, mas o diário permite acompanhar o que realmente foi registrado.

### Ordem de desenvolvimento proposta

1. Perfil, proteção dos dados, armazenamento local e cadastro de alimentos.
2. Cálculo validado, diário e petiscos; acesso rápido e exclusão desde o início.
3. Pesagens, ECC/objetivo, gráfico e atividades, completando as quatro telas.
4. Sincronização por Wi-Fi com exclusão remota e tratamento de conflitos.
5. Compartilhamento e dicas; depois, celebrações contextualizadas.

As prioridades orientam a sequência, não eliminam restrições do estudo de caso. Autenticação é dependência técnica da cópia remota e não um cadastro obrigatório para usar o app localmente. Múltiplos pets, rede social, localização GPS e integração com coleiras ficam fora desta versão.

## 7. Rastreabilidade e conferência da entrega

| Base do projeto | Decisão nesta atividade |
|---|---|
| Marina: orientação simples, motivação e registros esparsos | F01, F02, F04, F06, F12; RF20; RNF12 |
| Bruno: rapidez, precisão e uso sem rede | F03, F07, F09; RNF01, RNF06, RNF08, RNF09 |
| Pesquisa: cálculo individual e acompanhamento | F02, F05, F06; RF03, RF10; RNF11 |
| Pesquisa: petiscos visíveis | F04; RF07, RF08 |
| Pesquisa: adesão e comunicação | F03, F08, F12; RNF01, RNF12 |
| Benchmark: foco e independência de hardware | F03, F07, F08, F09; RNF07, RNF10 |
| Restrições do estudo de caso | RNF01 a RNF12; RF14 a RF17 |

- [x] 12 funcionalidades com descrição, necessidade e justificativa.
- [x] 20 requisitos funcionais numerados.
- [x] 12 requisitos não funcionais com verificação proposta.
- [x] CRUD e justificativa das operações não aplicáveis.
- [x] Priorização e escolha da funcionalidade mais importante.
- [x] Relação com problema, personas e pesquisa.
- [x] README e CHANGELOG preparados para a Atividade 03.
- [x] Apresentação preparada em `docs/apresentacaoRequisitos.pdf`.
- [ ] Cada integrante revisar e publicar sua contribuição identificável no GitHub.
- [ ] Grupo ensaiar e realizar a apresentação.

## 8. Fontes e decisões pendentes para implementação

As fontes bibliográficas NRC, AAHA, WSAVA e CRMV-SP já estão registradas em [pesquisa.md](pesquisa.md); os comparativos estão em [benchmark.md](benchmark.md). Esta atividade reutiliza a pesquisa existente e não apresenta nova coleta ou nova validação clínica.

Antes da implementação do cálculo, selecionar e documentar as equações aplicáveis por espécie/fase de vida, a referência de ECC, o método de peso de referência e os parâmetros aprovados. Antes da operação remota, definir provedor, autenticação, base legal, política de retenção e expiração de backups. Essas pendências não autorizam inventar resultados nutricionais ou declarar conformidade legal já validada.
