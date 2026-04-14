🌐 [English](../README.md) | [한국어](README_ko.md) | [中文](README_zh.md) | [日本語](README_ja.md) | [Español](README_es.md) | [Português](README_pt.md)

<div align="center">

# ai-agency

**Sua propria agencia de IA, construida em torno dos seus objetivos.**

Construa o contexto do seu projeto uma vez — nunca explique novamente.
Desenvolvimento, planejamento, negocios, design — agentes especialistas compartilham o mesmo conhecimento e colaboram.
Sem tokens desperdicados. Apenas trabalho em equipe orquestrado rumo aos seus objetivos.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](../LICENSE)
[![Sponsor](https://img.shields.io/badge/Sponsor-%E2%9D%A4-red?logo=github)](https://github.com/sponsors/itdar)

</div>

---

## O que e ai-agency?

Cada sessao de IA comeca do zero. Seu agente nao conhece suas APIs, as regras da sua equipe ou seus objetivos de negocio. Voce explica as mesmas coisas repetidamente — gastando tempo e dinheiro.

**ai-agency** constroi um contexto persistente para sua organizacao e orquestra especialistas de IA sobre ele:

1. **Contexto uma vez, para sempre** — Construa a camada de conhecimento do seu projeto uma unica vez. Cada agente inicia totalmente informado — codigo, convencoes, regras de negocio, estrutura da equipe. Sem custos repetidos de tokens, sem tempo de aquecimento.

2. **Especialistas orquestrados** — Nao e apenas um agente em um repositorio. Desenvolvimento, planejamento, negocios, design, QA, operacoes — cada especialista compartilha o mesmo contexto e colabora. Um agente PM os coordena para lidar com tarefas, resolver problemas e entregar resultados em toda a sua organizacao.

Seja um unico servico ou o fluxo de trabalho de uma empresa inteira — ai-agency orquestra os especialistas certos com o contexto certo.

Funciona com qualquer ferramenta de IA: Claude Code, Codex, Cursor, Copilot, Gemini CLI, Windsurf, Aider.

<!-- TODO: GIF demo de 30 segundos — ai-agency init → lancamento de sessao de agente → agente trabalhando imediatamente com contexto carregado -->

---

## Instalacao

### Homebrew (recomendado)

```bash
brew install itdar/tap/ai-agency
```

### Sem Homebrew

```bash
curl -fsSL https://raw.githubusercontent.com/itdar/ai-agency/main/src/install.sh | bash -s -- --global
```

### Apenas por projeto

```bash
cd /path/to/your-project
curl -fsSL https://raw.githubusercontent.com/itdar/ai-agency/main/src/install.sh | bash
```

---

## Primeiros passos

### 1. Inicializar seu projeto

```bash
cd ~/my-project
ai-agency init
```

Tambem pode executar de qualquer lugar: `ai-agency init ~/my-project`

Tres etapas sao realizadas automaticamente:
1. **Escaneamento** — Explora a estrutura de diretorios e classifica cada diretorio (backend, frontend, infra, business, etc.)
2. **Geracao** — Gera `AGENTS.md` e contexto `.ai-agents/` para cada area
3. **Validacao** — Verifica a completude dos arquivos gerados

<!-- TODO: Captura de tela do ai-agency init em execucao — mostrando a CUI de selecao de ferramenta/idioma -->

Voce escolhe sua ferramenta de IA (Claude Code, Codex ou Gemini) e idioma. A IA entao analisa seu projeto e constroi o contexto. E uma configuracao unica — leva alguns minutos mas economiza horas depois.

### 2. Iniciar uma sessao de agente

```bash
ai-agency
```

So isso. Escolha um agente do menu interativo e comece a trabalhar. O agente ja conhece seu projeto.

<!-- TODO: Captura de tela da CUI interativa do ai-agency — mostrando lista de agentes com navegacao por setas, agentes coloridos -->

### 3. Uso diario

Seu fluxo de trabalho diario nao muda. Apenas execute `ai-agency` em vez de lancar sua ferramenta de IA diretamente.

```bash
ai-agency                     # Selecionar agente interativamente
ai-agency --agent api         # Ir direto para o agente API
```

Quando voce seleciona um agente de nivel superior (PM, Domain Coordinator), ele automaticamente invoca e coordena sub-agentes conforme necessario — voce nao precisa gerencia-los.

Para executar multiplos agentes independentes lado a lado em paineis divididos do tmux:

```bash
ai-agency --multi             # Selecionar quais agentes executar em paralelo
```

<!-- TODO: Captura de tela de paineis divididos multi-agente tmux — 2-3 agentes executando simultaneamente com bordas coloridas -->

---

## Por que voce precisa

### Sem ai-agency

Cada sessao comeca do zero. A IA gasta tempo (e seus tokens) entendendo seu projeto:

- "Que framework e este?" — le 20 arquivos para descobrir
- "Quais sao os endpoints da API?" — escaneia cada controller
- "Quais sao as convencoes da equipe?" — nao tem ideia, adivinha errado
- "Quem aprova os deploys?" — nao sabe, pula a etapa

> Pesquisa (ETH Zurich, 2026): Agentes de IA que re-analisam um projeto conhecido gastam **20% mais tokens** e produzem **resultados piores** do que agentes com contexto pre-construido.

### Com ai-agency

A IA carrega tudo em segundos e comeca a trabalhar imediatamente:

```
Inicio da Sessao
  → Le AGENTS.md               "Sou o especialista backend do order-api"
  → Carrega .ai-agents/context/ "Conheco as APIs, modelos de dados, regras da equipe"
  → Comeca a trabalhar          Sem fase de exploracao
```

<!-- TODO: Imagem comparativa Before/After — esquerda: IA explorando arquivos sem direcao, direita: IA imediatamente produtiva com contexto carregado -->

---

## O que e gerado

Quando voce executa `ai-agency init`, tres camadas de contexto sao criadas:

```
your-project/
├── AGENTS.md                    # Quem sou eu? (papel, regras, permissoes)
├── .ai-agents/
│   ├── context/                 # O que eu sei? (conhecimento do dominio)
│   │   ├── domain-overview.md   #   Proposito do negocio, politicas, restricoes
│   │   ├── api-spec.json        #   Mapa de endpoints API
│   │   ├── data-model.md        #   Entidades e relacionamentos
│   │   └── ...                  #   (gerado conforme o tipo do projeto)
│   ├── skills/                  # Como eu trabalho? (padroes de fluxo)
│   │   ├── develop/SKILL.md     #   Dev: analisar → implementar → testar → PR
│   │   └── review/SKILL.md      #   Review: checklist de seguranca, performance
│   └── roles/                   # Estrategias de carga por papel
│       ├── pm.md
│       └── backend.md
├── apps/
│   ├── api/AGENTS.md            # Agente por servico
│   └── web/AGENTS.md
└── infra/AGENTS.md
```

**Apenas informacoes nao inferiveis sao armazenadas.** O que a IA pode descobrir lendo o codigo (como "este e um app React") e excluido. O que nao pode inferir (como "usamos squash merge" ou "aprovacao do QA e necessaria antes do deploy") e incluido.

---

## Exemplos de estrutura

ai-agency se adapta a forma do seu projeto. O diretorio onde voce executa `ai-agency init` se torna o PM (coordenador).

### Produto simples

```
my-app/               ← Agente PM
├── api/              ← Agente Backend
├── web/              ← Agente Frontend
└── infra/            ← Agente Infra
```

### Produto + equipes de negocio

```
my-product/            ← Agente PM
├── api/              ← Agente Backend
├── web/              ← Agente Frontend
├── business/         ← Agente Analista de Negocios
├── planning/         ← Agente Planejador
└── infra/            ← Agente Infra
```

Nao apenas codigo — negocios, planejamento, QA, operacoes e mais. Cada area ganha seu proprio agente especializado.

### Plataforma multi-dominio

```
platform/              ← Agente PM
├── commerce/         ← Coordenador de Dominio (auto-detectado)
│   ├── order-api/    ← Agente Backend
│   └── storefront/   ← Agente Frontend
├── social/           ← Coordenador de Dominio (auto-detectado)
│   ├── feed-api/     ← Agente Backend
│   └── chat-api/     ← Agente Backend
└── infra/            ← Agente Infra
```

Dominios sao detectados automaticamente — quando um diretorio contem 2+ subdiretorios com seus proprios arquivos de build.

---

## Modo equipe

Execute um agente PM que coordena sub-agentes, ou lance multiplos agentes em paralelo.

### Equipe coordenada (Claude Code)

O agente PM delega tarefas a especialistas via equipes nativas do Claude Code:

```bash
ai-agency                     # Selecionar modo "team" do menu
```

<!-- TODO: Captura de tela da selecao de modo equipe — mostrando opcoes single/team/multi na CUI -->

### Agentes paralelos (qualquer ferramenta de IA)

Lance multiplos agentes em paineis divididos do tmux. Coordenacao baseada em arquivos:

```bash
ai-agency --multi             # Selecionar agentes, executam em paineis divididos
```

Agentes se coordenam atraves de `.ai-agents/coordination/` — um quadro de tarefas compartilhado e registro de mensagens que funciona com qualquer ferramenta de IA.

<!-- TODO: Captura de tela de sessao multi-agente tmux + task-board.md visivel -->

---

## Manter o contexto atualizado

Arquivos de contexto sao atualizados automaticamente durante sessoes de IA — cada AGENTS.md inclui gatilhos de manutencao que dizem ao agente quando atualizar o que.

Apos uma sessao, ai-agency verifica se o codigo mudou mas o contexto nao foi atualizado, e avisa:

```
[ai-agency] Alteracoes de codigo detectadas mas nenhum arquivo de contexto atualizado.
  Execute: ai-agency verify --staleness
```

Voce tambem pode verificar manualmente:

```bash
ai-agency verify              # Validar estrutura e completude
ai-agency verify --staleness  # Verificar se o contexto esta sincronizado com o codigo
```

Para grandes mudancas, re-execute init no modo incremental — gera contexto apenas para diretorios novos:

```bash
ai-agency init                # Selecionar "incremental" quando solicitado
```

---

## Ferramentas de IA suportadas

ai-agency e vendor-neutral. AGENTS.md funciona com qualquer ferramenta, e arquivos bootstrap sao gerados automaticamente para as que precisam.

| Ferramenta | Funciona direto | Auto-bootstrap |
|---|---|---|
| **OpenAI Codex** | Sim | Nao necessario |
| **Claude Code** | Sim | `CLAUDE.md` gerado |
| **Cursor** | Via regras | `.cursor/rules/` gerado |
| **GitHub Copilot** | Via instrucoes | `.github/copilot-instructions.md` gerado |
| **Windsurf** | Via regras | `.windsurfrules` gerado |
| **Aider** | Via config | `.aider.conf.yml` atualizado |
| **Gemini CLI** | Sim | Nao necessario |

Arquivos bootstrap sao gerados apenas para ferramentas que voce realmente usa. Nada e criado para ferramentas que voce nao tem.

---

## Referencia CLI

```bash
# Configuracao
ai-agency init [path]           # Inicializar projeto (escanear, gerar, validar)
ai-agency classify [path]       # Previsualizar classificacao de diretorios sem gerar

# Uso diario
ai-agency                       # Lancador interativo de agentes
ai-agency --agent <keyword>     # Lancar agente especifico
ai-agency --multi               # Agentes paralelos em paineis tmux
ai-agency --tool <claude|codex> # Especificar ferramenta de IA
ai-agency --lang <code>         # Configurar idioma da UI (en ko ja zh es fr de ru hi ar)

# Gerenciamento de projetos
ai-agency register [path]       # Registrar um projeto
ai-agency scan [dir]            # Auto-descobrir projetos com AGENTS.md
ai-agency list                  # Listar projetos registrados
ai-agency unregister [path]     # Remover do registro

# Manutencao
ai-agency verify [path]         # Validar arquivos gerados
ai-agency verify --staleness    # Verificar frescor do contexto
ai-agency clear [path]          # Remover todos os arquivos gerados
```

---

## Como funciona (internamente)

Para os curiosos:

1. **classify-dirs.sh** — Escaneia o projeto e fornece 19 regras como dicas. A IA analisa o conteudo, a estrutura e o proposito de cada diretorio para determinar se e um sub-projeto independente
2. **scaffold.sh** — Cria a estrutura de diretorios `.ai-agents/` com arquivos placeholder no diretorio raiz e em cada sub-projeto identificado
3. **setup.sh** — Passa `HOW_TO_AGENTS.md` para sua ferramenta de IA escolhida — uma meta-instrucao que guia a IA por um processo de analise e geracao de 7 etapas
4. **validate.sh** — Verifica a integridade estrutural dos arquivos gerados (secoes obrigatorias, limites de tokens, completude de referencias)
5. **sync-ai-rules.sh** — Cria arquivos bootstrap especificos de cada vendor apontando para AGENTS.md
6. **ai-agency.sh** — Gerencia a CUI interativa de selecao de agentes e o ciclo de vida das sessoes, incluindo rastreamento de checksums de contexto e coordenacao multi-agente

> **Nota sobre tokens:** A configuracao inicial analisa todo o projeto e pode consumir dezenas de milhares de tokens. E um custo unico — sessoes posteriores carregam o contexto pre-construido instantaneamente.

---

## Referencias

- [AGENTS.md Standard](https://agents.md/) — O padrao vendor-neutral de instrucoes para agentes no qual este projeto se baseia
- [ETH Zurich Research](https://www.infoq.com/news/2026/03/agents-context-file-value-review/) — "So documente o que nao pode ser inferido"
- [Kurly OMS Team AI Workflow](https://helloworld.kurly.com/blog/oms-claude-ai-workflow/) — Inspiracao para o design de contexto

---

## Licenca

MIT

---

<p align="center">
  <sub>Pare de re-explicar seu projeto para a IA. Configure uma vez, use para sempre.</sub>
</p>
