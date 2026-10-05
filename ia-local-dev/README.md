# IA local para desarrollo de software — POC

Asistente de programación que corre **100 % en el equipo** (sin enviar código a la nube):
chat, autocompletado y generación de código por capas (p. ej. CRUD completo con controlador,
servicio, repositorio, modelo, pruebas y documentación).

## Equipo del POC
| Componente | Valor |
|---|---|
| Equipo | Dell OptiPlex 7090 · Windows 11 Pro |
| CPU | Intel i7-10700 (8 núcleos / 16 hilos) |
| RAM | 32 GB |
| GPU | Intel UHD 630 (integrada, **no sirve para IA**) → inferencia solo en CPU |
| Disco | NVMe 1 TB |

## Arquitectura (lo más simple posible)
```
VS Code + extensión Continue  ──HTTP──▶  Ollama (localhost:11434)
   ├─ Chat / Agente  ───────────────▶  dev-coder  (Qwen2.5-Coder 7B, Q4, ~4.7 GB)
   ├─ Autocompletado ───────────────▶  qwen2.5-coder:1.5b-base (~1 GB)
   └─ @codebase (búsqueda) ─────────▶  nomic-embed-text
```
- **Ollama**: motor que ejecuta los modelos. Instalador nativo de Windows, sin Docker.
- **Continue**: extensión open source de VS Code/JetBrains para chat, autocompletado y modo agente.
- **dev-coder**: Qwen2.5-Coder 7B con un *system prompt* propio ([`ollama/Modelfile`](ollama/Modelfile)) que obliga a generar todas las capas y la documentación.

## Instalación (≈15 min + descarga de ~6 GB)
```powershell
git clone -b claude/peaceful-cray-ng885y https://github.com/salakin93/profile.git
cd profile\ia-local-dev
powershell -ExecutionPolicy Bypass -File .\scripts\instalar.ps1
```
El script instala Ollama (winget), descarga los modelos, crea `dev-coder`, instala Continue
y copia [`continue/config.yaml`](continue/config.yaml) a `%USERPROFILE%\.continue\` (respaldando el anterior).

> ⚠️ El equipo es de dominio corporativo con **App Control for Business** activo. Si winget o
> Ollama quedan bloqueados, hay que pedir a TI que autorice `Ollama` y la extensión `Continue`.

## Uso
| Acción | Cómo |
|---|---|
| Chat | `Ctrl+L` |
| Generar CRUD | `Ctrl+L` → `/crud Usuario con nombre, edad, genero` |
| Editar código seleccionado | `Ctrl+I` |
| Autocompletar | Escribir y aceptar con `Tab` |
| Preguntar sobre el proyecto | `@codebase ¿dónde se valida el login?` |
| Documentar / tests | Seleccionar código → `/documentar` o `/tests` |

Ejemplo paso a paso: [`docs/ejemplo-crud.md`](docs/ejemplo-crud.md).

## Rendimiento esperado en este equipo (solo CPU)
| Tarea | Modelo | Velocidad aprox. |
|---|---|---|
| Autocompletado | 1.5B | 20–30 tokens/s → sugerencias en ~1 s |
| Chat / CRUD | 7B | 5–8 tokens/s → un CRUD completo (~2.500 tokens) tarda **5–8 min** |

Mide los valores reales con `.\scripts\benchmark.ps1` (genera un CSV para el informe del POC).

**Consejos**: cierra apps pesadas (el reporte muestra solo ~7.8 GB de RAM libre); con
<6 GB libres cambia `dev-coder` por `qwen2.5-coder:3b` en el Modelfile.

## Criterios para evaluar el POC
1. ¿El CRUD generado compila con pocas correcciones?
2. ¿Incluye todas las capas, validaciones, pruebas y documentación?
3. ¿El autocompletado es útil en el día a día?
4. Tiempo ahorrado vs. escribirlo a mano.

## Siguiente paso si convence: GPU
| GPU | VRAM | Qué permite |
|---|---|---|
| RTX 4060 Ti 16 GB | 16 GB | 7B–14B a 40–60 tok/s (CRUD en < 1 min) |
| RTX 4070 Ti Super / 5070 Ti | 16 GB | Igual, ~1.5× más rápido |
| RTX 3090 / 4090 / 5090 | 24–32 GB | Qwen2.5-Coder **32B**: calidad cercana a modelos comerciales; modo agente fluido |

⚠️ El OptiPlex 7090 (formato torre/SFF) tiene fuente limitada y poco espacio: una GPU dedicada
probablemente requiera **otro equipo o una workstation**. Ollama puede servir a todo el equipo
desde una sola máquina con GPU (cambiando `apiBase` en `config.yaml`).

## Estructura
```
ia-local-dev/
├── README.md
├── ollama/Modelfile        # modelo dev-coder (system prompt + parámetros)
├── continue/config.yaml    # chat, autocompletado, embeddings y comandos /crud /tests /documentar
├── scripts/instalar.ps1    # instalación automática en Windows
├── scripts/benchmark.ps1   # medición de tokens/s para el informe
└── docs/ejemplo-crud.md
```
