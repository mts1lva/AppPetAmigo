# Pesquisa - PetAmigo

## 1. Recorte do problema

O PetAmigo parte de um problema de manejo cotidiano: o tutor precisa decidir quanto alimento oferecer ao animal, mas nem sempre consegue transformar peso, condição corporal, nível de atividade, castração e tipo de alimento em uma meta diária compreensível. O risco não está apenas no excesso de ração. Petiscos, restos de comida e outras fontes calóricas também entram no balanço energético e podem passar despercebidos.

A proposta do aplicativo, portanto, não é substituir uma consulta veterinária nem diagnosticar obesidade ou desnutrição. O objetivo é apoiar o tutor no acompanhamento da rotina, traduzindo referências veterinárias em registros simples e em informações que possam ser discutidas com um profissional.

## 2. Informações relevantes sobre o problema

### 2.1. Excesso de peso é um problema de saúde, não apenas estético

O CRMV-SP divulgou dados de um estudo realizado pela FMVZ-USP em 2018 segundo os quais **40,5% dos cães domésticos avaliados na cidade de São Paulo apresentavam sobrepeso e 14,6% apresentavam obesidade**. O mesmo material reforça que a quantidade ingerida precisa ser analisada de acordo com a necessidade individual do animal.

Esse dado não deve ser generalizado para todos os cães do Brasil, pois se refere a uma população específica da cidade de São Paulo, mas é suficiente para mostrar que o controle de peso é um problema relevante no contexto brasileiro.

### 2.2. A necessidade energética deve ser individualizada

O relatório **Nutrient Requirements of Dogs and Cats**, do National Research Council (NRC), é uma referência técnica para nutrição de cães e gatos e considera fatores como atividade física e fase de vida na definição das necessidades nutricionais. As diretrizes da AAHA também recomendam que a estimativa de energia seja ajustada conforme peso, condição corporal, estilo de vida e outros fatores do animal, e que o resultado seja reavaliado ao longo do tempo.

Na prática, isso significa que o aplicativo não deve tratar a quantidade indicada na embalagem da ração como uma verdade universal. O PetAmigo deve usar uma fórmula veterinária documentada como ponto de partida e deixar claro que o acompanhamento de peso e condição corporal é necessário para verificar se a meta está funcionando para aquele animal.

### 2.3. Petiscos precisam aparecer no cálculo e no registro

As diretrizes de prevenção da obesidade da AAHA recomendam que petiscos e outros alimentos complementares representem **no máximo 10% da ingestão calórica diária**, preservando pelo menos 90% da ingestão para uma dieta completa e balanceada. A WSAVA apresenta orientação semelhante.

Esse ponto é especialmente importante para o PetAmigo porque o estudo de caso já identifica os petiscos como um “ponto cego” do tutor. Em vez de registrar apenas a ração, o aplicativo deve separar visualmente **refeição principal** e **petiscos/extras**, mostrando quanto da meta diária já foi utilizado sem usar linguagem de culpa.

### 2.4. Peso isolado não conta toda a história

A WSAVA disponibiliza ferramentas de **Body Condition Score (BCS/ECC)** para cães e gatos. Na escala de nove pontos, os escores 4 e 5 são considerados ideais. A AAHA também recomenda o acompanhamento de peso e condição corporal para ajustar o plano alimentar ao longo do tempo.

Por isso, a evolução do PetAmigo não deve ser interpretada apenas como “perdeu peso = melhorou”. O aplicativo pode registrar peso, apresentar o gráfico de tendência e explicar visualmente o ECC, deixando a avaliação clínica definitiva para o médico-veterinário.

## 3. Necessidades e dificuldades dos usuários

A pesquisa foi cruzada com o estudo de caso do projeto para evitar criar funcionalidades desconectadas do contexto real de uso.

| Usuário/contexto | Necessidade | Dificuldade observada | Implicação para o app |
|---|---|---|---|
| Tutor dedicado | Registrar refeições, petiscos, peso e passeios com precisão | Está com as mãos ocupadas e abandona registros demorados | Fluxo principal em poucos toques, botões grandes e valores reutilizáveis |
| Tutor em fase de mudança | Entender o que fazer e perceber progresso | Motivação instável e sensação de culpa ao receber alertas | Linguagem acolhedora, metas pequenas e funcionamento mesmo com dias sem registro |
| Veterinário | Consultar histórico confiável | Pouco tempo de consulta e necessidade de saber de onde veio o cálculo | Fórmula e fonte documentadas, gráfico legível e botão de compartilhamento |
| Pet shop/clínica | Registrar peso rapidamente | Uso em pé, ruído, animal no colo e uma mão livre | Controles grandes, alto contraste e baixa exigência de digitação |
| Uso externo | Registrar passeio/atividade | Conectividade pode falhar | Persistência local e sincronização posterior por Wi-Fi |

## 4. Dados que influenciam diretamente o aplicativo

1. **A meta calórica deve ser personalizada.** Peso, fase de vida, castração, condição corporal e atividade interferem na estimativa; portanto, o app precisa evitar uma recomendação única para todos.
2. **Petiscos devem ser contabilizados separadamente.** O limite recomendado de até 10% das calorias diárias cria uma regra de interface útil: o usuário precisa enxergar os extras sem misturá-los à ração.
3. **O resultado deve ser acompanhado ao longo do tempo.** Peso e ECC precisam ser reavaliados, então o gráfico não é decorativo: ele serve para verificar se a estratégia está funcionando.
4. **A confiabilidade precisa ser visível.** Como o cálculo pode influenciar a alimentação do animal, a origem da fórmula e a possibilidade de compartilhar o histórico com um veterinário devem fazer parte da experiência.
5. **Baixo atrito é requisito funcional.** O estudo de caso coloca o registro no momento da refeição, do passeio ou da pesagem. Se registrar exigir muita atenção, o dado deixa de existir e todo o restante do aplicativo perde valor.

## 5. Três descobertas importantes e impacto no projeto

### Descoberta 1 - A fórmula é apenas o ponto de partida; o acompanhamento fecha o ciclo

A literatura veterinária reforça que necessidades energéticas são individuais e precisam ser ajustadas com base na resposta do animal. Isso muda o foco do PetAmigo: ele não deve ser apenas uma “calculadora de calorias”, mas um ciclo de **calcular -> registrar -> acompanhar -> revisar**.

**Influência no projeto:** manter a calculadora ligada ao gráfico de peso/ECC e apresentar a meta como referência de acompanhamento, não como prescrição médica definitiva.

### Descoberta 2 - Petiscos são pequenos na rotina, mas grandes para o controle calórico

AAHA e WSAVA recomendam limitar petiscos e extras a aproximadamente 10% da ingestão calórica diária. Isso confirma que tratá-los como campo opcional ou escondido criaria uma visão incompleta da alimentação.

**Influência no projeto:** criar registro próprio para petiscos e um indicador simples da parcela diária de extras, com aviso educativo e não punitivo.

### Descoberta 3 - A adesão do tutor é tão importante quanto a precisão técnica

As diretrizes da AAHA destacam a importância da comunicação e da adesão do responsável ao plano nutricional. O estudo de caso mostra que o registro acontece em contextos de pressa, uma mão ocupada e conectividade variável.

**Influência no projeto:** reduzir o fluxo principal, permitir uso offline, manter linguagem acolhedora e valorizar pequenas evoluções. Um cálculo tecnicamente correto não ajuda se o tutor abandona o registro.

## 6. Fontes utilizadas

1. **National Research Council (NRC).** *Nutrient Requirements of Dogs and Cats*. National Academies Press, 2006. DOI: 10.17226/10668.  
   https://www.nationalacademies.org/publications/10668

2. **American Animal Hospital Association (AAHA).** *2021 AAHA Nutrition and Weight Management Guidelines for Dogs and Cats*. 2021.  
   https://www.aaha.org/resources/2021-aaha-nutrition-and-weight-management-guidelines/home/

3. **AAHA.** *Prevention of Obesity - 2021 Nutrition and Weight Management Guidelines*. 2021.  
   https://www.aaha.org/resources/2021-aaha-nutrition-and-weight-management-guidelines/prevention-of-obesity/

4. **World Small Animal Veterinary Association (WSAVA).** *Global Nutrition Guidelines*.  
   https://wsava.org/global-guidelines/global-nutrition-guidelines/

5. **CRMV-SP.** *Dia da Nutrição: Confira como a alimentação influencia a saúde dos animais*.  
   https://crmvsp.gov.br/dia-da-nutricao-confira-como-a-alimentacao-influencia-a-saude-dos-animais/


