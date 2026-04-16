🌐 [English](../README.md) | [한국어](README_ko.md) | [日本語](README_ja.md) | [中文](README_zh.md) | [Español](README_es.md)

> ⚠️ Esta traducción puede estar desactualizada. Para la versión más reciente, consulta el [English README](../README.md) o [한국어](README_ko.md).

<div align="center">

# ai-agency

**Tu propia agencia de IA, construida en torno a tus objetivos.**

Construye el contexto de tu proyecto una vez — nunca lo expliques de nuevo.
Desarrollo, planificacion, negocio, diseno — agentes especialistas comparten el mismo conocimiento y colaboran.
Sin tokens desperdiciados. Solo trabajo en equipo orquestado hacia tus objetivos.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](../LICENSE)
[![Sponsor](https://img.shields.io/badge/Sponsor-%E2%9D%A4-red?logo=github)](https://github.com/sponsors/itdar)

</div>

---

## Que es ai-agency?

Cada sesion de IA comienza desde cero. Tu agente no conoce tus APIs, las reglas de tu equipo ni los objetivos de tu negocio. Explicas lo mismo una y otra vez — gastando tiempo y dinero.

**ai-agency** construye un contexto persistente para tu organizacion y orquesta especialistas de IA sobre el:

1. **Contexto una vez, para siempre** — Construye la capa de conocimiento de tu proyecto una sola vez. Cada agente inicia completamente informado — codigo, convenciones, reglas de negocio, estructura del equipo. Sin costos repetidos de tokens, sin tiempo de calentamiento.

2. **Especialistas orquestados** — No es solo un agente en un repositorio. Desarrollo, planificacion, negocio, diseno, QA, operaciones — cada especialista comparte el mismo contexto y colabora. Un agente PM los coordina para manejar tareas, resolver problemas y entregar resultados en toda tu organizacion.

Ya sea un solo servicio o el flujo de trabajo de toda una empresa — ai-agency orquesta a los expertos correctos con el contexto correcto.

Funciona con cualquier herramienta de IA: Claude Code, Codex, Cursor, Copilot, Gemini CLI, Windsurf, Aider.

<!-- TODO: GIF demo de 30 segundos — ai-agency init → lanzamiento de sesion de agente → agente trabajando inmediatamente con contexto cargado -->

---

## Instalacion

### Homebrew (recomendado)

```bash
brew install itdar/tap/ai-agency
```

### Sin Homebrew

```bash
curl -fsSL https://raw.githubusercontent.com/itdar/ai-agency/main/src/install.sh | bash -s -- --global
```

### Solo por proyecto

```bash
cd /path/to/your-project
curl -fsSL https://raw.githubusercontent.com/itdar/ai-agency/main/src/install.sh | bash
```

---

## Primeros pasos

### 1. Inicializar tu proyecto

```bash
cd ~/my-project
ai-agency init
```

Tambien puedes ejecutarlo desde cualquier lugar: `ai-agency init ~/my-project`

Se realizan tres pasos automaticamente:
1. **Escaneo** — Explora la estructura de directorios y clasifica cada directorio (backend, frontend, infra, business, etc.)
2. **Generacion** — Genera `AGENTS.md` y contexto `.ai-agents/` para cada area
3. **Validacion** — Verifica la completitud de los archivos generados

<!-- TODO: Captura de pantalla de ai-agency init ejecutandose — mostrando la CUI de seleccion de herramienta/idioma -->

Eliges tu herramienta de IA (Claude Code, Codex o Gemini) e idioma. La IA analiza tu proyecto y construye el contexto. Es una configuracion unica — toma unos minutos pero ahorra horas despues.

### 2. Iniciar una sesion de agente

```bash
ai-agency
```

Eso es todo. Elige un agente del menu interactivo y comienza a trabajar. El agente ya conoce tu proyecto.

<!-- TODO: Captura de pantalla de la CUI interactiva de ai-agency — mostrando la lista de agentes con navegacion por teclas de flecha, agentes con colores -->

### 3. Uso diario

Tu flujo de trabajo diario no cambia. Solo ejecuta `ai-agency` en lugar de lanzar tu herramienta de IA directamente.

```bash
ai-agency                     # Seleccionar agente interactivamente
ai-agency --agent api         # Ir directamente al agente API
```

Cuando seleccionas un agente de nivel superior (PM, Domain Coordinator), automaticamente invoca y coordina sub-agentes segun sea necesario — no necesitas gestionarlos tu mismo.

Para ejecutar multiples agentes independientes en paneles divididos de tmux:

```bash
ai-agency --multi             # Seleccionar que agentes ejecutar en paralelo
```

<!-- TODO: Captura de pantalla de paneles divididos multi-agente tmux — 2-3 agentes ejecutandose simultaneamente con bordes de panel de colores -->

---

## Por que lo necesitas

### Sin ai-agency

Cada sesion comienza desde cero. La IA gasta tiempo (y tus tokens) entendiendo tu proyecto:

- "Que framework es este?" — lee 20 archivos para descubrirlo
- "Cuales son los endpoints de la API?" — escanea cada controlador
- "Cuales son las convenciones del equipo?" — no tiene idea, adivina mal
- "Quien aprueba los deploys?" — no lo sabe, se salta el paso

> Investigacion (ETH Zurich, 2026): Los agentes de IA que re-analizan un proyecto conocido gastan **20% mas tokens** y producen **peores resultados** que los agentes con contexto pre-construido.

### Con ai-agency

La IA carga todo en segundos y comienza a trabajar inmediatamente:

```
Inicio de Sesion
  → Lee AGENTS.md              "Soy el experto backend de order-api"
  → Carga .ai-agents/context/  "Conozco las APIs, modelos de datos, reglas del equipo"
  → Comienza a trabajar        Sin fase de exploracion
```

<!-- TODO: Imagen comparativa Before/After — izquierda: IA explorando archivos sin rumbo, derecha: IA inmediatamente productiva con contexto cargado -->

---

## Que se genera

Cuando ejecutas `ai-agency init`, se crean tres capas de contexto:

```
your-project/
├── AGENTS.md                    # Quien soy? (rol, reglas, permisos)
├── .ai-agents/
│   ├── context/                 # Que se? (conocimiento del dominio)
│   │   ├── domain-overview.md   #   Proposito del negocio, politicas, restricciones
│   │   ├── api-spec.json        #   Mapa de endpoints API
│   │   ├── data-model.md        #   Entidades y relaciones
│   │   └── ...                  #   (generado segun el tipo de proyecto)
│   ├── skills/                  # Como trabajo? (estandares de flujo)
│   │   ├── develop/SKILL.md     #   Dev: analizar → implementar → testear → PR
│   │   └── review/SKILL.md      #   Review: checklist de seguridad, rendimiento
│   └── roles/                   # Estrategias de carga por rol
│       ├── pm.md
│       └── backend.md
├── apps/
│   ├── api/AGENTS.md            # Agente por servicio
│   └── web/AGENTS.md
└── infra/AGENTS.md
```

**Solo se almacena informacion no inferible.** Lo que la IA puede descubrir leyendo el codigo (como "esta es una app React") se excluye. Lo que no puede inferir (como "usamos squash merge" o "se requiere aprobacion de QA antes del deploy") se incluye.

---

## Ejemplos de estructura

ai-agency se adapta a la forma de tu proyecto. El directorio donde ejecutas `ai-agency init` se convierte en el PM (coordinador).

### Producto simple

```
my-app/               ← Agente PM
├── api/              ← Agente Backend
├── web/              ← Agente Frontend
└── infra/            ← Agente Infra
```

### Producto + equipos de negocio

```
my-product/            ← Agente PM
├── api/              ← Agente Backend
├── web/              ← Agente Frontend
├── business/         ← Agente Analista de Negocio
├── planning/         ← Agente Planificador
└── infra/            ← Agente Infra
```

No solo codigo — negocio, planificacion, QA, operaciones y mas. Cada area obtiene su propio agente especializado.

### Plataforma multi-dominio

```
platform/              ← Agente PM
├── commerce/         ← Coordinador de Dominio (auto-detectado)
│   ├── order-api/    ← Agente Backend
│   └── storefront/   ← Agente Frontend
├── social/           ← Coordinador de Dominio (auto-detectado)
│   ├── feed-api/     ← Agente Backend
│   └── chat-api/     ← Agente Backend
└── infra/            ← Agente Infra
```

Los dominios se detectan automaticamente — cuando un directorio contiene 2+ subdirectorios con sus propios archivos de build.

---

## Modo equipo

Ejecuta un agente PM que coordina sub-agentes, o lanza multiples agentes en paralelo.

### Equipo coordinado (Claude Code)

El agente PM delega tareas a especialistas via los equipos nativos de Claude Code:

```bash
ai-agency                     # Seleccionar modo "team" del menu
```

<!-- TODO: Captura de pantalla de seleccion de modo equipo — mostrando opciones single/team/multi en la CUI -->

### Agentes paralelos (cualquier herramienta de IA)

Lanza multiples agentes en paneles divididos de tmux. Coordinacion basada en archivos:

```bash
ai-agency --multi             # Seleccionar agentes, se ejecutan en paneles divididos
```

Los agentes se coordinan a traves de `.ai-agents/coordination/` — un tablero de tareas compartido y registro de mensajes que funciona con cualquier herramienta de IA.

<!-- TODO: Captura de pantalla de sesion multi-agente tmux + task-board.md visible -->

---

## Mantener el contexto actualizado

Los archivos de contexto se actualizan automaticamente durante las sesiones de IA — cada AGENTS.md incluye triggers de mantenimiento que le dicen al agente cuando actualizar que.

Despues de una sesion, ai-agency verifica si el codigo cambio pero el contexto no se actualizo, y te avisa:

```
[ai-agency] Cambios de codigo detectados pero ningun archivo de contexto actualizado.
  Ejecutar: ai-agency verify --staleness
```

Tambien puedes verificar manualmente:

```bash
ai-agency verify              # Validar estructura y completitud
ai-agency verify --staleness  # Verificar si el contexto esta sincronizado con el codigo
```

Para cambios grandes, re-ejecuta init en modo incremental — solo genera contexto para directorios nuevos:

```bash
ai-agency init                # Seleccionar "incremental" cuando se solicite
```

---

## Herramientas de IA soportadas

ai-agency es vendor-neutral. AGENTS.md funciona con cualquier herramienta, y se generan archivos bootstrap automaticamente para las que lo necesiten.

| Herramienta | Funciona directamente | Auto-bootstrap |
|---|---|---|
| **OpenAI Codex** | Si | No necesario |
| **Claude Code** | Si | `CLAUDE.md` generado |
| **Cursor** | Via reglas | `.cursor/rules/` generado |
| **GitHub Copilot** | Via instrucciones | `.github/copilot-instructions.md` generado |
| **Windsurf** | Via reglas | `.windsurfrules` generado |
| **Aider** | Via config | `.aider.conf.yml` actualizado |
| **Gemini CLI** | Si | No necesario |

Los archivos bootstrap solo se generan para herramientas que realmente usas. No se crea nada para herramientas que no tienes.

---

## Referencia CLI

```bash
# Configuracion
ai-agency init [path]           # Inicializar proyecto (escanear, generar, validar)
ai-agency classify [path]       # Previsualizar clasificacion de directorios sin generar

# Uso diario
ai-agency                       # Lanzador interactivo de agentes
ai-agency --agent <keyword>     # Lanzar agente especifico
ai-agency --multi               # Agentes paralelos en paneles tmux
ai-agency --tool <claude|codex> # Especificar herramienta de IA
ai-agency --lang <code>         # Configurar idioma de UI (en ko ja zh es fr de ru hi ar)

# Gestion de proyectos
ai-agency register [path]       # Registrar un proyecto
ai-agency scan [dir]            # Auto-descubrir proyectos con AGENTS.md
ai-agency list                  # Listar proyectos registrados
ai-agency unregister [path]     # Eliminar del registro

# Mantenimiento
ai-agency verify [path]         # Validar archivos generados
ai-agency verify --staleness    # Verificar frescura del contexto
ai-agency clear [path]          # Eliminar todos los archivos generados
```

---

## Como funciona (internamente)

Para los curiosos:

1. **classify-dirs.sh** — Escanea el proyecto y proporciona 19 reglas como pistas. La IA analiza el contenido, la estructura y el proposito de cada directorio para determinar si es un sub-proyecto independiente
2. **scaffold.sh** — Crea la estructura de directorios `.ai-agents/` con archivos placeholder en el directorio raiz y en cada sub-proyecto identificado
3. **setup.sh** — Pasa `HOW_TO_AGENTS.md` a tu herramienta de IA elegida — una meta-instruccion que guia a la IA a traves de un proceso de analisis y generacion de 7 pasos
4. **validate.sh** — Verifica la integridad estructural de los archivos generados (secciones requeridas, limites de tokens, completitud de referencias)
5. **sync-ai-rules.sh** — Crea archivos bootstrap especificos de cada vendor que apuntan a AGENTS.md
6. **ai-agency.sh** — Gestiona la CUI interactiva de seleccion de agentes y el ciclo de vida de sesiones, incluyendo seguimiento de checksums de contexto y coordinacion multi-agente

> **Nota sobre tokens:** La configuracion inicial analiza todo el proyecto y puede consumir decenas de miles de tokens. Es un costo unico — las sesiones posteriores cargan el contexto pre-construido instantaneamente.

---

## Referencias

- [AGENTS.md Standard](https://agents.md/) — El estandar vendor-neutral de instrucciones para agentes en el que se basa este proyecto
- [ETH Zurich Research](https://www.infoq.com/news/2026/03/agents-context-file-value-review/) — "Solo documenta lo que no se puede inferir"
- [Kurly OMS Team AI Workflow](https://helloworld.kurly.com/blog/oms-claude-ai-workflow/) — Inspiracion para el diseno de contexto

---

## Licencia

MIT

---

<p align="center">
  <sub>Deja de re-explicar tu proyecto a la IA. Configuralo una vez, usalo para siempre.</sub>
</p>
