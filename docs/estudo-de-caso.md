# Análise do Estudo de Caso — PetAmigo

**Disciplina:** Programação para Dispositivos Móveis
**Atividade:** 01 — Análise do Estudo de Caso
**Projeto:** PetAmigo — aplicativo de saúde animal (alimentação e peso ideal)
**Turma:** Programação para Dispositivos Móveis
**Integrantes:** Matheus Silva, Raissa Andrade, João Lopes, Paulo Emanuel, Matheus Leão

---

## 2.1. Problema

- **Qual problema o aplicativo pretende ajudar a solucionar?**

O PetAmigo enfrenta o manejo alimentar por estimativa: o tutor alimenta o pet sem parâmetro objetivo e produz os dois extremos citados, obesidade e desnutrição. O problema não é falta de cuidado, e sim falta de informação quantificada, pois o tutor não consegue traduzir a situação real do animal em gramas de ração. Soma-se a isso o ponto cego dos petiscos, que respondem por cerca de 30% das calorias e não eram contabilizados, fazendo com que mesmo o tutor atento erre.

- **Por que esse problema é relevante?**

Porque o excesso de peso está ligado a diabetes, problemas articulares e redução da expectativa de vida, o que torna a questão clínica e não estética. Além disso, o ganho de peso é silencioso e progressivo, imperceptível a quem convive diariamente com o animal, e é agravado pela castração, praticamente universal, que reduz a necessidade energética sem que a alimentação seja recalculada. Há ainda um agravante ético: quem sofre a consequência não é quem toma a decisão.

- **Qual é a principal necessidade que a solução deverá atender?**

Traduzir conhecimento veterinário técnico, expresso nas fórmulas da NRC, em uma ação diária simples e sem culpa. Essa necessidade se desdobra em três elos encadeados — saber quanto oferecer, registrar o que foi efetivamente oferecido e verificar se o plano funciona —, e a falha de qualquer um deles rompe o ciclo de mudança de comportamento.

---

## 2.2. Público e usuários

- **Tutor dedicado (engajamento diário) — usuário principal**

É o tutor já consciente do problema, que valoriza precisão e usa o app de forma ritualizada a cada refeição e passeio, geralmente na cozinha, no momento exato de servir a ração. Precisa de velocidade de registro, exatidão e histórico confiável para mostrar ao veterinário. Seu gargalo é o atrito: se o registro demorar, ele abandona — o que justifica a restrição dos dois toques.

- **Tutor em fase de mudança (engajamento semanal) — usuário crítico**

É quem acabou de descobrir o problema de peso e tem motivação instável, usando o app de forma irregular, normalmente após pesar o animal ou após uma consulta. Precisa não se sentir julgado e enxergar progresso rápido. Seu gargalo é a motivação, não a velocidade, e é por ele que existem a celebração de pequenas vitórias e o tom acolhedor. Como consequência, o app precisa funcionar bem também com dados esparsos, sem que lacunas de registro pareçam fracasso.

- **Médicos veterinários nutrólogos — usuário de validação**

Não registram no dia a dia: consultam o histórico gerado pelo tutor e julgam a confiabilidade do cálculo, normalmente durante a consulta, olhando rapidamente a tela do celular do cliente. Precisam de dados fidedignos e de embasamento explícito, o que justifica a exigência das fórmulas da NRC e das fontes documentadas de NRC e CRMV. Sem a recomendação desse público, o app perde seu principal canal de entrada, e por isso a estética fofa não pode comprometer a leitura profissional dos dados.

- **Pet shops — contexto de uso e ponto de captação**

Dispõem de balança e contato frequente com o tutor, sendo o lugar onde o registro de peso naturalmente acontece. O uso ocorre em pé no balcão, em ambiente barulhento, com o animal no colo e frequentemente com uma única mão livre. É o cenário mais hostil à interação fina e reforça diretamente a exigência de botões grandes e fluxo curto.

- **ONGs — público de volume e recursos limitados**

Acompanham muitos animais resgatados, em que o problema predominante é a desnutrição e não a obesidade, operando com orçamento apertado, aparelhos antigos e conectividade ruim. É o público que mais justifica tecnicamente o Android 8.0, os gráficos leves e o funcionamento offline. Vale registrar que o gerenciamento de múltiplos animais, necessidade real desse grupo, ficará fora do escopo por causa do limite de quatro telas centradas em um único pet.

---

## 2.3. Contexto de uso

- **Em casa, no momento da refeição**

Tutor de pé na cozinha, com pressa, animal agitado ao redor e mãos ocupadas com o pote ou o saco de ração. É o uso mais frequente e o mais atrapalhado, e justifica integralmente o fluxo de dois toques e os alvos de toque generosos, pois o registro precisa caber no intervalo entre servir e o pet começar a comer.

- **Em casa, em momento de revisão**

Tutor calmo, no sofá, com atenção plena e interesse em compreender a evolução do animal. É o momento adequado para o gráfico de peso e para as dicas de exercício, admitindo maior densidade de informação na tela.

- **Durante ou após o passeio**

Ambiente externo, luz solar forte, uma das mãos na guia e conectividade instável. Exige alto contraste, o que obriga a testar a paleta pastel sob sol, registro em toques mínimos e funcionamento pleno sem rede.

- **Pet shop e clínica veterinária**

No pet shop o uso é rápido, em pé, com ruído e com uma só mão. Na clínica a tela passa a ser mostrada a um profissional, o que exige histórico legível e uma interface que não pareça um brinquedo a ponto de comprometer a confiança técnica.

- **Condições transversais**

A conectividade não confiável define a arquitetura como offline-first, com o banco local funcionando como fonte de verdade e a nuvem como espelho, além de exigir tratamento de conflitos na sincronização por Wi-Fi. O baixo nível de atenção impede telas que exijam leitura longa. Não há urgência clínica, mas há urgência de conveniência, pois o registro adiado simplesmente não acontece. O uso com uma mão desestimula digitação e gestos precisos, e os dispositivos modestos impõem leveza acima de efeitos visuais.

---

## 2.4. Objetivo e proposta de valor

- **O que o aplicativo pretende oferecer e qual benefício deverá proporcionar?**

O PetAmigo oferece um cálculo individualizado de peso ideal e de calorias diárias, um diário que contabiliza ração e petiscos separadamente, o registro de passeios e um gráfico de evolução do peso. O benefício é substituir o achismo por um número confiável e transformar um objetivo abstrato, como emagrecer o cachorro, em uma rotina concreta e mensurável. O valor não está no cálculo isolado, que já existe em tabelas e sites, mas na combinação entre cálculo, registro contínuo e retorno positivo, que é o que sustenta a mudança de hábito. Em síntese, o app dá ao tutor comum um nível de precisão nutricional hoje restrito à consulta com nutrólogo, sem transformar o cuidado em tarefa culposa.

---

## 2.5. Personalidade, identidade e experiência

- **Palavras conceituais**

Elas se dividem em um bloco técnico-clínico, com ECC, obesidade animal, calorias, castração, metabolismo e diabetes, e um bloco cotidiano, com ração, petisco e exercício. A interface deve falar a linguagem do bloco cotidiano e sustentar-se tecnicamente no bloco clínico, de modo que o tutor toque em "Registrar refeição" enquanto o número por trás vem da NRC. Siglas como ECC só devem aparecer acompanhadas de explicação visual.

- **Personalidade da identidade**

A definição de fofa, amigável e responsável cria uma tensão entre fofura e credibilidade que precisa ser administrada: fofo demais não convence o veterinário, sério demais afasta o tutor em fase de mudança. A solução é manter a fofura na moldura, isto é, ilustrações, mascotes e celebrações, e a seriedade no conteúdo, isto é, números, unidades e fontes. As cores pastel ainda exigem atenção redobrada com contraste, dado o uso sob sol e em telas antigas.

- **Tom da interface e da experiência do usuário**

O tom educativo e acolhedor se traduz em regras concretas: não punir a ausência, tratando um dia sem registro apenas como um dia sem dado; não culpar pelo excesso, orientando em vez de acusar; celebrar variações mínimas, já que a vitória de referência é de cem gramas; e explicar as recomendações em vez de apenas ordená-las.

- **Como quer ser lembrado**

A frase que define o app como o nutricionista de bolso que cuida da barriga do seu melhor amigo reúne suas três promessas: competência técnica, disponibilidade imediata e afeto. Ela funciona como critério de escopo, pois qualquer funcionalidade que não sirva a pelo menos uma dessas promessas está fora do projeto.

- **Vínculo emocional como mecanismo, não como enfeite**

A exigência da foto do pet no dashboard e das ilustrações de pets sorrindo é o mecanismo de retenção do produto: o tutor não abre o app para consultar uma planilha, e sim para ver o próprio animal. Por isso essa decisão precisa ser documentada como escolha justificada na pasta de documentação.

---

## 2.6. Funcionalidades e características já definidas

- **Calculadora de calorias diárias — necessidade atendida:** eliminar o achismo, dando ao tutor um alvo objetivo em substituição à recomendação genérica da embalagem.

- **Cálculo baseado em fórmulas da NRC — necessidade atendida:** garantir confiabilidade técnica, que é o que permite ao veterinário recomendar o app e ao tutor confiar no número.

- **Cálculo de peso ideal e ECC — necessidade atendida:** definir o destino da jornada, informando se é preciso reduzir, manter ou aumentar a alimentação.

- **Diário de alimentação (ração) — necessidade atendida:** registrar a entrada calórica principal e comparar consumo real com a meta.

- **Registro separado de petiscos — necessidade atendida:** corrigir o ponto cego do tutor, já que os petiscos somam cerca de 30% das calorias e não eram contabilizados no mesmo campo da ração.

- **Registro de peso — necessidade atendida:** fornecer a medida objetiva de resultado que alimenta o gráfico e valida o plano.

- **Gráfico de progresso — necessidade atendida:** tornar visível uma mudança lenta e imperceptível no dia a dia, servindo de principal fonte de motivação.

- **Registro de passeios — necessidade atendida:** contabilizar o gasto energético, que é a outra metade do balanço calórico.

- **Dicas de exercício e enriquecimento ambiental — necessidade atendida:** cumprir o papel educativo e oferecer alternativas ao petisco como forma de interação afetiva, algo especialmente relevante para gatos.

- **Celebração de pequenas vitórias — necessidade atendida:** sustentar a motivação do tutor em fase de mudança, que abandonaria o app sem retorno positivo visível.

- **Foto do pet no dashboard — necessidade atendida:** criar o vínculo emocional que motiva a abertura recorrente e a adesão às recomendações.

- **Funcionamento offline com sincronização por Wi-Fi — necessidade atendida:** garantir o registro no momento exato do consumo, independentemente de conectividade.

- **Exclusão total dos dados — necessidade atendida:** respeitar a sensibilidade das informações de saúde e o direito do usuário sobre seus dados.

- **Fluxo principal em até três interações — necessidade atendida:** reduzir o atrito da ação mais repetida do app, viabilizando o uso diário sustentado.

- **Botões grandes — necessidade atendida:** permitir o uso em pé, com uma única mão e com o animal no colo, em pet shops e durante passeios.

---

## 2.7. Restrições e condições

- **Quantidade de telas e navegação**

O protótipo está limitado a quatro telas principais, correspondentes ao perfil com foto e peso, ao diário de refeições, ao registro de passeios e ao gráfico de peso, o que exclui telas de configuração, onboarding extenso e gerenciamento de múltiplos animais nesta versão.

- **Número de interações**

A funcionalidade principal deve ocorrer em até três interações, com o registro concluído em dois toques, o que proíbe digitação obrigatória, múltiplas confirmações e navegação profunda.

- **Dispositivos e sistema operacional**

O app deve rodar em Android 8.0 ou superior e usar gráficos leves, o que descarta bibliotecas pesadas de visualização e exige renderização rápida em aparelhos modestos.

- **Conectividade e armazenamento**

O diário precisa funcionar offline, com persistência local obrigatória, e a sincronização deve ocorrer apenas por Wi-Fi, para não consumir dados móveis, o que exige fila de sincronização e tratamento de conflitos.

- **Privacidade**

Os dados de saúde do pet são sensíveis e exigem cuidado no armazenamento e na transmissão, além de ser obrigatória a exclusão total dos dados, alcançando também o que já foi sincronizado.

- **Ambiente de utilização e acessibilidade**

O uso em casa, pet shops e clínicas impõe botões grandes, e as ilustrações de pets sorrindo e a foto real do pet no dashboard são obrigatórias, constituindo restrição de identidade e não sugestão.

- **Precisão do cálculo**

O resultado não pode ser aproximação própria e deve seguir fórmula veterinária documentada da NRC.

- **Documentação e processo no GitHub**

A pasta de documentação deve manter o Documento de Requisitos com Personas e Pesquisas, citando as fontes da NRC e do CRMV, a justificativa das decisões visuais ligadas ao vínculo emocional e o CHANGELOG.md no formato de mudança, motivo e resultado observado, além de exigir contribuição identificável de cada integrante.

- **Tom como requisito**

A interface não pode culpabilizar o tutor, o que restringe diretamente a escrita das mensagens de erro, dos alertas de excesso calórico e do tratamento dado aos dias sem registro.

---

## 2.8. Pontos de atenção

- **Fluxo de registro em dois toques, funcionando offline**

Todo o restante do app depende da existência do dado, pois calculadora, gráfico e celebrações são inúteis sem o registro das refeições. Esse registro ocorre no pior contexto possível, com pressa, animal agitado, mãos ocupadas e às vezes sem rede, de modo que qualquer atrito significa registro não feito e, em poucos dias, abandono. Não é preferência de usabilidade, é condição de sobrevivência do produto, e deve ser testada no protótipo com cronômetro.

- **Credibilidade técnica: cálculo NRC e petiscos contabilizados à parte**

Como o app se apresenta como nutricionista de bolso, um número errado não gera má experiência, e sim um animal alimentado incorretamente. A adoção também depende da recomendação de veterinários, que só indicam ferramentas com base científica declarada. O registro separado dos petiscos integra essa lógica, já que um diário que subestima 30% das calorias produz um número confiável apenas na aparência, o que é pior do que não ter número, porque o tutor confia nele.

- **Tom acolhedor e vínculo emocional como estratégia de retenção**

O público que o app mais precisa alcançar é o tutor em fase de mudança, justamente aquele que tem o pet com problema de peso e ainda não construiu rotina de cuidado, e que abandona a solução ao primeiro sinal de julgamento. A foto do pet, as ilustrações afetuosas e a celebração de vitórias de cem gramas são o mecanismo que o faz voltar enquanto não há hábito para sustentá-lo. Em um produto cujo resultado leva meses e cujo beneficiário não pode agradecer, o reforço positivo precisa vir da interface.

---

_Documento produzido para a Atividade 01 — Análise do Estudo de Caso._
