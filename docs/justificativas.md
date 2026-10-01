# Justificativas de prototipação - PetAmigo

Atividade 04 | 30/09/2026 | Proposta para implementação na Unidade II.

[Arquivo Figma](https://www.figma.com/design/KMFuEzPGv0SJTS7L8c3DMV) - baixa e alta fidelidade no mesmo arquivo. Visualização pública confirmada em uma sessão do navegador sem login em 30/09/2026; edição e comentários continuam sujeitos às permissões da equipe.

## Contexto e fontes

Foram lidos README, estudo de caso, pesquisa, benchmark, personas, requisitos e o enunciado da Atividade 04. `docs/requisitos.md` prevalece sobre os estudos anteriores para comportamento. A pesquisa é documental; não foram realizados testes com usuários nem revisão clínica nesta etapa.

Marina Oliveira é a persona prioritária: precisa de orientação clara e retorno sem culpa ao acompanhar Luna. Bruno Santos precisa registrar na cozinha ou na rua com uma mão ocupada, sem depender da rede. Os dados de Luna são demonstrativos: gata castrada, 6 anos, atividade moderada; pesagens de 5,6 kg em 16/09, 5,5 kg em 23/09 e 5,4 kg em 30/09/2026. Foto ilustrativa não identifica um pet real da equipe.

## Identidade e legibilidade

Verde `#236447` identifica ações primárias; fundo `#F6F8F4`, superfície branca e acento `#E4EEE5` deixam os números em primeiro plano. Texto `#1F3029`, borda `#CBD7CC` e erro `#8F342D` completam a paleta. Borda suave delimita componentes; os rótulos garantem identificação sem depender de cor. Ícones e pet sorrindo são vetores editáveis com desenho simples e traço consistente.

Inter é a única família proposta, com títulos de 26, seções de 18, corpo de 16 e legendas de 14; navegação usa 12 para manter os quatro rótulos em uma linha. A implementação deve distribuir os quatro destinos em larguras iguais e permitir adaptação com fonte ampliada. A família está disponível no arquivo; sua inclusão no aplicativo deve preservar a licença correspondente.

Contraste relativo calculado pela linearização sRGB:

| Texto | Fundo | Razão |
|---|---|---|
| #1F3029 | #FFFFFF | 13.88:1 |
| #1F3029 | #F6F8F4 | 12.99:1 |
| #1F3029 | #E4EEE5 | 11.67:1 |
| #FFFFFF | #236447 | 7.03:1 |

Os pares acima superam 4,5:1. Isso verifica apenas esses pares, não certifica toda a acessibilidade nem leitura ao sol.

## Organização e navegação

Há quatro destinos principais: Início, Diário, Atividades e Evolução. A navegação inferior permanece fixa enquanto o conteúdo rola. No Início, foto e identificação precedem o resumo; o registro habitual aparece no card diário. Cálculo, privacidade e cópia remota ficam acessíveis no próprio perfil. Diário distingue refeições e petiscos; atividades incluem dicas; evolução reúne gráfico, histórico, ECC, objetivo e compartilhamento. Não há quinta área principal nem configurações com recursos fora do escopo.

Os wireframes exploram blocos em cinza, resumo antes do atalho e uma lista alimentar conjunta. A alta fidelidade prioriza o atalho, separa categorias e informa explicitamente a ausência da referência. São decisões de design, sem atribuição a resultados de teste.

O fluxo habitual é Início → abrir Registrar refeição → Confirmar refeição. Com alimento e porção configurados, são dois toques até a confirmação de salvamento. Cadastro, ajustes e correções são fluxos separados. Os formulários compartilham campos e estrutura; refeições usam energia calculada do rótulo, petiscos permitem energia informada. A exclusão usa confirmação reutilizável. O gráfico apresenta também datas e pesos em texto.

## Componentes e acessibilidade

A biblioteca contém sete famílias pequenas: botão, campo, card, mensagem, diálogo, navegação e histórico. Possui variantes efetivamente necessárias e propriedades de texto. Cores, espaçamento e raio usam variáveis; há estilos tipográficos e instâncias reutilizadas nas telas. Não há imagem da interface completa substituindo seus elementos editáveis. A foto é o único conteúdo raster da interface.

O viewport de projeto é 390 × 844 unidades. Para a proposta Android, uma unidade corresponde a 1 dp e medidas tipográficas serão expressas em sp; isso não equivale aos pixels físicos de todos os aparelhos. Botões têm altura 52, campos 64 e destinos da navegação 87 × 56, acima da área mínima de 48 × 48 dp. No aplicativo, conteúdo deve expandir em altura, quebrar linhas e rolar com fonte a 200%; listas não devem limitar linhas e os rótulos dos campos precisam continuar presentes. A navegação deve crescer em altura se necessário. As pranchas PDF das telas principais mostram o conteúdo rolável completo, por isso sua altura pode exceder o viewport.

TalkBack, foco, ordem de leitura, seleção dos campos, teclado, barra do sistema e escalonamento a 200% ainda precisam ser testados no Android. O protótipo visual não comprova esses comportamentos.

## Dados, cálculo e comunicação responsável

O rótulo demonstrativo contém 360 kcal/100 g: 30 g equivalem a 108 kcal. O petisco demonstrativo tem 3 g e 12 kcal. Os registros iniciais somam 120 kcal; os extras representam 10% desse total registrado, sem constituir limite ou recomendação. Uma segunda refeição de 108 kcal leva o total a 228 kcal. Nenhuma porção ilustrativa é prescrita para Luna.

Não há equação NRC validada no repositório. A referência alimentar e sua conversão em quantidade recomendada ficam indisponíveis. RF03 e RNF11 exigem edição, equação, unidades, fatores, limites e casos validados antes de habilitar cálculo. O valor de 30% nos estudos antigos não se torna regra universal. Atividade não desconta calorias. ECC e objetivo dependem de informação profissional e não geram diagnóstico automático. Dias sem registros indicam ausência de dados, sem consumo zero nem julgamento.

Os controles de ECC e objetivo permitem salvar e remover referências, preservando as pesagens. O formulário prevê data e origem; estimativas de peso ficam indisponíveis sem método validado. A pesagem exige valor positivo; alterações suspeitas oferecem corrigir ou manter, sem descartar silenciosamente o dado. O painel de conferência usa o exemplo de 54 kg versus 5,4 kg e está conectado ao formulário; a validação automática ainda depende de implementação. Há também um estado específico de densidade alimentar inválida.

## Arquitetura proposta

O repositório atual contém documentação; não há aplicativo já implementado nesta entrega. Propõe-se uma aplicação Android simples: quatro telas de apresentação, formulários reutilizados, camada de regras e um repositório de dados. O banco local em área privada será a fonte de verdade, com transações atômicas e IDs estáveis para pet, alimentos, porções, refeições, extras, atividades, pesagens e referências. Registros alimentares preservarão uma cópia dos valores de alimento, densidade e porção usados na ocasião, evitando que uma edição futura altere o histórico.

A confirmação de salvamento deverá aparecer somente após persistência. O módulo de cálculo ficará isolado e desabilitado enquanto seu catálogo de métodos não estiver validado. Um gerador local criará o resumo do período, incluindo lacunas, perfil, alimentação, atividades, pesagens e fonte/situação do cálculo; o compartilhamento usará o seletor nativo somente após ação do tutor.

Cópia remota opcional terá autenticação apenas após ativação no perfil. Uma fila local transmitirá inclusões, alterações e exclusões exclusivamente por Wi-Fi, reutilizando IDs para evitar duplicação. Um serviço simples de autenticação e armazenamento, ainda a escolher pela equipe, deverá aplicar isolamento por usuário e TLS. Conflitos exibirão versões para decisão explícita; exclusões confirmadas terão precedência. Desativação da cópia não bloqueia funções locais.

Exclusão integral removerá dados locais e solicitará remoção remota. Offline, apenas a solicitação técnica permanecerá; restauração ficará bloqueada e a conclusão remota só será comunicada após confirmação do serviço. Política de retenção/expiração dos backups e base legal precisam de revisão antes de disponibilização. Logs não devem expor fotos, credenciais ou dados pessoais.

RNF06 mantém os critérios propostos no requisito: salvar até 1 s e abrir resumo/gráfico até 2 s em 95% de 20 execuções, Android 8.0, 2 GB, 1.000 registros. Essas medições, instalação, testes de modo avião, transações, exclusão e sincronização ainda não foram executados.

## Cobertura e simulações

Os destinos e botões principais da alta fidelidade têm transições definidas. Campos são representações editáveis de interface no arquivo, sem digitação funcional. Seleção de foto e compartilhamento nativo usam um painel de representação. A conta de exemplo usa domínio reservado `.invalid`; não há credenciais reais. Os estados pendente, sincronizado e falha são variantes demonstradas juntas, sem tráfego de rede.

Exclusão de um item retorna ao contexto para representar a conclusão; exclusão integral compartilha a confirmação. A alteração real dos totais, lista vazia após exclusão, bloqueio de restauração e confirmação remota não são executados pelo protótipo. Esse limite impede tratar o Figma como implementação completa. A lista inicial e o diário após uma refeição ilustram dois conjuntos consistentes de dados; operações adicionais exigirão lógica no aplicativo.

| Requisito | Elemento / decisão | Situação e limite |
|---|---|---|
| RF01 | Início / Dados de Luna | Cadastro e edição conectados; entrada de campos simulada |
| RF02 | Início | Perfil, foto e totais demonstrativos |
| RF03 | Referência indisponível | Bloqueado até método NRC validado |
| RF04 | Alimentos e porções | Formulário e exclusão; conversão ilustrativa do rótulo |
| RF05 | Atalho / Refeição salva | Abrir e confirmar: dois toques |
| RF06 | Diário / Refeição / Excluir | Manutenção conectada; recálculo dinâmico simulado |
| RF07 | Diário / Petisco | Categoria separada; CRUD representado |
| RF08 | Resumo do dia | Totais, parcela dos extras e meta indisponível |
| RF09 | Evolução / Pesagem | CRUD e conferência conectados; validação automática a implementar |
| RF10 | ECC e objetivo | Campos, explicação e remoção sem apagar pesagens |
| RF11 | Evolução | Gráfico cronológico e alternativa textual; ponto único especificado |
| RF12 | Atividades / Formulário | Duração, tipo e data; sem compensação calórica |
| RF13 | Resumo / Recurso do aparelho | Período e compartilhamento solicitado; seletor simulado |
| RF14 | Mensagem salvo | Persistência local proposta; não implementada |
| RF15 | Cópia remota / Conflito | Estados visíveis; Wi-Fi, fila e IDs a implementar |
| RF16 | Seus dados | Finalidades, exportação, ativação reversível |
| RF17 | Confirmar exclusão | Confirmação; remoção remota e bloqueio de restauração a implementar |
| RF18 | Atividades / Dica | Conteúdo por espécie em revisão; não validado |
| RF19 | Refeição salva | Continuidade acolhedora; sem celebrar perda isolada |
| RF20 | Consultar outra data | Ausência de dados e retomada sem retroativo |
| RNF01 | Atalho e navegação | Dois toques no habitual; diário pela navegação |
| RNF02 | Componentes / reflow | Alvos 48 dp; fonte 200% e TalkBack a testar no Android |
| RNF03 | Identidade / contraste | Pares principais medidos; leitura ao sol a validar |
| RNF04 | Arquitetura | Banco privado, acesso isolado, TLS e logs a implementar |
| RNF05 | Privacidade | Exclusão e exportação propostas; retenção remota pendente |
| RNF06 | Arquitetura | Metas de desempenho do requisito; medições pendentes |
| RNF07 | Arquitetura | Android 8.0+, sem GPS; instalação a verificar |
| RNF08 | Arquitetura | Transações e IDs estáveis; testes de integridade pendentes |
| RNF09 | Cópia remota | Local independente da conta; rede e fila a implementar |
| RNF10 | Quatro destinos | Início, Diário, Atividades e Evolução |
| RNF11 | Referência indisponível | Nenhuma fórmula clínica inventada; validação pendente |
| RNF12 | Início / mensagens | Foto, pet sorrindo e tom acolhedor |

## Verificação e pendências

- Duas fidelidades no mesmo arquivo; quatro destinos principais.
- Textos e componentes editáveis; Inter confirmada na estrutura das telas.
- Caminho habitual e navegação conectados; formulários complementares disponíveis nas duas fidelidades.
- PDFs exportados do Figma, uma tela/prancha por página, com estados em contexto na alta fidelidade e link público verificado.
- Seis slides editáveis na página de evolução/apresentação; não se atribuem testes ou decisões aos colegas sem sua revisão.
- Pendências: validação NRC; revisão profissional de dicas/ECC; testes de acessibilidade e implementação; revisão e publicação individual dos colegas.

## Fontes e recursos

Fontes de contexto: [estudo de caso](estudo-de-caso.md), [pesquisa](pesquisa.md), [benchmark](benchmark.md), [personas](personas.md) e [requisitos](requisitos.md). Referências veterinárias permanecem nos documentos originais: NRC, AAHA, WSAVA e CRMV-SP. Elas não substituem a validação do método de cálculo nesta entrega.

Foto demonstrativa: [imagem no Unsplash](https://images.unsplash.com/photo-1573865526739-10659fec78a5) sob [licença Unsplash](https://unsplash.com/license), consultada para composição ilustrativa. Inter: [projeto oficial e licença SIL Open Font License](https://github.com/rsms/inter). Ilustração do gato sorrindo: vetor do próprio projeto.
