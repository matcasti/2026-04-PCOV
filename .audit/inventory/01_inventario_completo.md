# AUDITORÍA DE REPRODUCIBILIDAD — INVENTARIO COMPLETO
## Repositorio original: matcasti/2026-04-PCOV
### Fecha de auditoría: 2026-08-06

---

## 1. DATOS DEL REPOSITORIO

| Campo | Valor |
|---|---|
| URL | https://github.com/matcasti/2026-04-PCOV |
| Clon local | ~/Desktop/PCOV-19_reproducibility_audit |
| Rama | main |
| Último commit | d1b52e03d62cd9050cfb10d0a45369e8b91c35d0 |
| Autor | Matías Castillo <matcasti@umag.cl> |
| Fecha | 2026-05-28 22:31:46 -0300 |
| Archivos totales | 23 (excluyendo .git) |
| Estado working tree | Limpio |

---

## 2. ESTRUCTURA DE CARPETAS

```
2026-04 PCOV/
├── .gitignore                  # models/ está excluido del repo
├── 2026-04 PCOV.Rproj          # Proyecto RStudio
├── R/
│   ├── 1-fit-models.R          # 10 modelos bayesianos (brms, 413 líneas)
│   ├── 2-extract-parameters.R  # Extracción y formateo de parámetros (154 líneas)
│   └── _functions.R            # Funciones auxiliares (bf_01, summary_posterior, etc.)
├── data-raw/
│   ├── col_names.txt           # Lista de columnas del dataset final
│   ├── prep-data.R             # Pipeline de limpieza y merge (242 líneas)
│   ├── raw_analisis_movimiento.csv  # n=18, 24 columnas
│   ├── raw_celulares.csv            # 13 columnas
│   ├── raw_espirometria.csv         # 23 columnas
│   ├── raw_estatus_clinico.csv      # 18 columnas
│   ├── raw_kinesiologia.csv         # 26 columnas — INCLUYE fpd_1, fyi_1 (handgrip)
│   ├── raw_laboratorio.csv          # 45 columnas
│   ├── raw_psicologico.csv          # 20 columnas
│   └── raw_sociodemografico.csv     # 178 columnas
├── data/
│   ├── pcov.csv                # Dataset final: 292 filas × 318 columnas
│   └── pcov.RData              # Objeto R (mismo contenido)
├── models/                     # ⚠️ GITIGNORED — NO está en el repo
│   ├── psicologico_fit.rds
│   ├── hemograma_fit.rds
│   ├── hepatico_fit.rds
│   ├── renal_fit.rds
│   ├── metabolismo_fit.rds
│   ├── subpoblaciones_fit.rds
│   ├── abc_fit.rds
│   ├── composicion_fit.rds
│   ├── respiratorio_fit.rds
│   └── calidad_vida_fit.rds
├── output/
│   ├── model_summaries.csv         # 2,236 parámetros (todos)
│   └── model_summaries_signif.csv  # 803 parámetros con pd ≥ 0.80
└── docs/
    ├── index.qmd               # Reporte Quarto (779 líneas)
    ├── index.html              # Reporte HTML renderizado (9.3 MB)
    ├── references.bib          # 4 referencias bibliográficas
    └── graphical-abstract.png  # Graphical abstract placeholder
```

---

## 3. INVENTARIO CLASIFICADO

### 3.1 DATOS FUENTE (raw data)

| Archivo | Filas | Columnas | Descripción |
|---|---|---|---|
| `data-raw/raw_sociodemografico.csv` | ~292 | 178 | REDCap: demografía, COVID, vacunas, síntomas |
| `data-raw/raw_laboratorio.csv` | ~292 | 45 | REDCap: panel metabólico, hematológico, bioquímico |
| `data-raw/raw_psicologico.csv` | ~292 | 20 | REDCap: BDI-II, BAI, WAIS-IV, PSQI |
| `data-raw/raw_kinesiologia.csv` | ~292 | 26 | REDCap: FAS, PIMAX, InBody, **fpd_1/fyi_1 (handgrip)** |
| `data-raw/raw_celulares.csv` | ~292 | 13 | REDCap: subpoblaciones linfocitarias, ABCs |
| `data-raw/raw_espirometria.csv` | ~292 | 23 | REDCap: FVC, FEV1, PEF, PIM/PEM |
| `data-raw/raw_estatus_clinico.csv` | ~292 | 18 | REDCap: estatus clínico, diagnóstico, derivación |
| `data-raw/raw_analisis_movimiento.csv` | ~292 | 24 | REDCap: gait analysis 3D (n=18 completos) |

### 3.2 DATOS PROCESADOS

| Archivo | Descripción | Generado por |
|---|---|---|
| `data/pcov.csv` | Dataset mergeado y limpio (292×318) | `data-raw/prep-data.R` |
| `data/pcov.RData` | Mismo dataset en formato R | `data-raw/prep-data.R` |
| `data-raw/col_names.txt` | Lista de nombres de columnas finales | `data-raw/prep-data.R` |

### 3.3 SCRIPTS DE LIMPIEZA Y PREPARACIÓN

| Archivo | Tipo | Qué hace |
|---|---|---|
| `data-raw/prep-data.R` | Automático | Merge 8 CSVs → prefijos → limpieza NA → severity score → pcov.csv |

### 3.4 SCRIPTS DE ANÁLISIS

| Archivo | Tipo | Qué hace |
|---|---|---|
| `R/1-fit-models.R` | Automático | 10 modelos brms multivariados (4 cadenas, 5000 iter) |
| `R/2-extract-parameters.R` | Automático | Extrae parámetros, formatea etiquetas, genera CSVs |
| `R/_functions.R` | Auxiliar | Bayes Factors, summary_posterior, report_model |

### 3.5 SCRIPTS DE FIGURAS

| Archivo | Descripción |
|---|---|
| `docs/index.qmd` | Reporte Quarto con figuras y tablas inline (NO scripts R separados) |

### 3.6 ARCHIVOS GENERADOS AUTOMÁTICAMENTE

| Archivo | Generado por |
|---|---|
| `data/pcov.csv` | `data-raw/prep-data.R` |
| `data/pcov.RData` | `data-raw/prep-data.R` |
| `data-raw/col_names.txt` | `data-raw/prep-data.R` |
| `output/model_summaries.csv` | `R/2-extract-parameters.R` |
| `output/model_summaries_signif.csv` | `R/2-extract-parameters.R` |
| `docs/index.html` | `quarto render docs/index.qmd` |

### 3.7 ARCHIVOS ESCRITOS MANUALMENTE

| Archivo | Descripción |
|---|---|
| `docs/index.qmd` | Reporte Quarto (texto narrativo + código inline) |
| `docs/references.bib` | 4 referencias BibTeX |
| `.gitignore` | Configuración de exclusiones |

### 3.8 ARCHIVOS AUSENTES (gitignored)

| Archivo | Ubicación esperada | Impacto |
|---|---|---|
| `models/*.rds` (10 archivos) | `models/` | **CRÍTICO**: sin estos, el análisis NO es reproducible |
| `.quarto/` | `docs/.quarto/` | Menor: caché de render |
| `.positai/` | Raíz | Menor: configuración IDE |

---

## 4. HALLAZGOS CLAVE DE REPRODUCIBILIDAD

### 4.1 HANDGRIP EN EL REPO ORIGINAL

**HANDGRIP SÍ EXISTE** en el repositorio original de Matías:

- `data-raw/raw_kinesiologia.csv` → columnas `fpd_1` (derecha) y `fyi_1` (izquierda)
- `data/pcov.csv` → columnas `kinesiologia_fpd_1` y `kinesiologia_fyi_1`
- 282/292 valores (96.6% completitud)
- Medias: derecha 31.3 kg, izquierda 30.1 kg

**Sin embargo**, ninguna de estas variables se usa en los modelos bayesianos (`R/1-fit-models.R`). No aparecen en la lista de outcomes modelados.

### 4.2 PCA — NO EXISTE EN EL REPO ORIGINAL

El repositorio de Matías **no contiene ningún análisis de PCA**:
- No hay script de PCA
- No hay k-means clustering
- No hay análisis de fenotipos (A/B)
- No hay `01_setup.R` ni equivalentes

El PCA y los fenotipos fueron agregados posteriormente en el fork `lsarmiento89/PCOV-19`.

### 4.3 MODELOS — NO REPRODUCIBLES SIN .rds

Los 10 archivos `.rds` con los modelos ajustados están en `models/`, que está en `.gitignore`. Sin estos archivos, el script `R/2-extract-parameters.R` no puede ejecutarse (hace `list.files("models")`).

### 4.4 DIFERENCIAS CLAVE vs lsarmiento89/PCOV-19

| Elemento | matcasti/2026-04-PCOV (original) | lsarmiento89/PCOV-19 (fork) |
|---|---|---|
| PCA / fenotipos | ❌ No existe | ✅ Agregado (01_setup.R) |
| Figuras R | ❌ No tiene | ✅ 7 scripts (02-08) |
| Manuscript builder | ❌ No tiene | ✅ build_manuscript_v8.py |
| Manuscript DOCX | ❌ No tiene | ✅ PCOV19_Revision8_Final.docx |
| domain_comparisons.csv | ❌ No tiene | ✅ Generado |
| Model .rds | ✅ Gitignored | ✅ Gitignored |
| Handgrip en datos | ✅ kinesiologia_fpd_1/fyi_1 | ✅ Mismas columnas |
| Handgrip en modelos | ❌ No usado | ❌ No usado (pero manuscrito lo reporta) |
| 6MWT | ❌ No existe | ❌ No existe (pero manuscrito lo reporta) |

---

## 5. TRAZABILIDAD

Esta auditoría fue realizada exclusivamente sobre el repositorio clonado en:
`~/Desktop/PCOV-19_reproducibility_audit/`

**No se modificó ningún archivo** del repositorio original de Matías.
**No se modificó ningún archivo** del repositorio lsarmiento89/PCOV-19.

Fecha de clonación: 2026-08-06
Hash del commit auditado: d1b52e03d62cd9050cfb10d0a45369e8b91c35d0
