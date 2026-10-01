# PetAmigo

Aplicativo mobile de saúde animal voltado à alimentação e ao peso ideal de cães e gatos.

## Turma

Programação para Dispositivos Móveis

## Integrantes e responsabilidades nesta atividade


**Matheus Silva** — líder do grupo, responsável pela criação do repositório, pela estrutura de pastas, pela manutenção do CHANGELOG e pela consolidação final do documento de análise.

**Raissa Andrade** — responsável pela análise do problema, do objetivo e da proposta de valor, correspondentes aos itens 2.1 e 2.4 da atividade.

**João Lopes** — responsável pela análise do público, dos usuários e do contexto de uso, correspondentes aos itens 2.2 e 2.3 da atividade.

**Paulo Emanuel** — responsável pela análise da personalidade, da identidade e da experiência pretendida e pelos pontos de atenção, correspondentes aos itens 2.5 e 2.8 da atividade.

**Matheus Leão** — responsável pelo levantamento das funcionalidades e das restrições já definidas, correspondentes aos itens 2.6 e 2.7, e pela revisão final do documento.

## Breve descrição do projeto

O PetAmigo é uma proposta de aplicativo para acompanhar alimentação, petiscos, atividades e peso de um único cão ou gato. A referência alimentar baseada em método NRC permanece indisponível até documentação e validação profissional; diário e histórico funcionam independentemente dessa referência. A especificação atual está em `docs/requisitos.md`.

O aplicativo é pensado para uso diário em contextos de pouca atenção, como a cozinha durante a refeição do animal, o balcão do pet shop e a rua durante o passeio, e por isso prioriza o registro em poucos toques, o funcionamento offline e uma interface acolhedora, que motiva o tutor sem culpá-lo. O público-alvo reúne tutores de cães e gatos, médicos veterinários nutrólogos, pet shops e ONGs.

## Estrutura do repositório

O repositório contém, na raiz, os arquivos README.md e CHANGELOG.md, e, na pasta docs, o arquivo estudo-de-caso.md, que reúne a análise produzida nesta atividade.

## Status

Atividade 01, correspondente à análise do estudo de caso, concluída.


## Atividade 03 - Funcionalidades e requisitos

A especificação desta etapa está em [docs/requisitos.md](docs/requisitos.md). As responsabilidades acima descrevem a Atividade 01; abaixo está a divisão planejada da Atividade 03. Cada integrante deve revisar e publicar sua contribuição com a própria conta.

### Responsabilidades da Atividade 03

- **Paulo Emanuel:** requisitos funcionais RF01 a RF20 e coerência entre comportamentos e funcionalidades.
- **Raissa Andrade Santos:** contexto, decisões de escopo e funcionalidades F01 a F06, relacionadas ao problema e à pesquisa.
- **João Lopes:** funcionalidades F07 a F12, relacionadas às personas e aos contextos de uso.
- **Matheus Leão:** requisitos não funcionais RNF01 a RNF12, restrições e critérios de verificação.
- **Matheus Silva:** CRUD, priorização, rastreabilidade, consolidação da apresentação e organização da entrega.


## Atividade 04 - Prototipação

Protótipos e documentação preparados em 30/09/2026. Não há aplicativo implementado nesta entrega.

- [Figma - arquivo único](https://www.figma.com/design/KMFuEzPGv0SJTS7L8c3DMV): planejamento, fluxos, baixa fidelidade, identidade/componentes, alta fidelidade e seis slides editáveis. Visualização pública sem login verificada em 30/09/2026.
- [Baixa fidelidade](docs/prototipoBaixaFidelidade.pdf).
- [Alta fidelidade](docs/prototipoAltaFidelidade.pdf).
- [Justificativas, arquitetura e matriz de requisitos](docs/justificativas.md).
- [Evolução e roteiro da apresentação](docs/apresentacao-prototipacao.md).

### Divisão proposta da Atividade 04

| Integrante | Contribuição para revisar e publicar |
|---|---|
| Paulo Emanuel | `docs/prototipoBaixaFidelidade.pdf` |
| Raissa Andrade Santos | `docs/justificativas.md` |
| João Lopes | `docs/prototipoAltaFidelidade.pdf` |
| Matheus Leão | `docs/apresentacao-prototipacao.md` e revisão dos seis slides |
| Matheus Silva | `README.md`, `CHANGELOG.md`, links e consolidação |

### Escopo e pendências

Quatro destinos: Início, Diário, Atividades e Evolução; uso local sem conta e cópia remota opcional por Wi-Fi. Dados demonstrativos; não há recomendação clínica gerada. Cálculo NRC, revisão das dicas, reflow a 200%, TalkBack, desempenho, persistência e sincronização precisam de validação/implementação. Os PDFs mostram telas e estados representados no Figma, incluindo conferência de variação de peso; seletores nativos e operações dinâmicas são simulações documentadas.
