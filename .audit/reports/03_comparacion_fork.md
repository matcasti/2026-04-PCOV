# FASE 4 — COMPARACIÓN ORIGINAL vs FORK vs MANUSCRITO

## 4.1 severity_score

| Fuente | n | Media ± SD | SS ≥ 6 | PCOV Mod/Sev |
|---|---|---|---|---|
| **Original (Matías)** — prep-data.R con bug | 182/292 | 5.8 ± 2.5 | 88 | 88 (30.1%) |
| **Fork (lsarmiento89)** — prep-data.R corregido | 292/292 | 7.5 ± 3.2 | 200 | 193 (66.1%) |
| **Manuscrito** | 292 | 7.5 ± 3.2 | — | 193 (66.1%) |
| **Conclusión** | Manuscrito = fork corregido ✓ | | | |

## 4.2 model_summaries

| Fuente | SHA256 | Filas |
|---|---|---|
| **Original** `model_summaries_signif.csv` | `511ca0da...` | 803 |
| **Fork** `model_summaries_signif.csv` | `511ca0da...` | 803 |
| **Conclusión** | **IDÉNTICOS** — el fork NO regeneró los modelos | |

**⚠️ CRÍTICO**: Los modelos bayesianos se ajustaron con el severity_score **bugueado** (original). Pero el manuscrito reporta el severity_score **corregido** (fork). Las estimaciones de los modelos (β, pd, BF₁₀) para `[PCOV Severity Score]` son inconsistentes con los valores descriptivos reportados.

## 4.3 Archivos del fork NO presentes en el original

| Archivo | Descripción | Origen |
|---|---|---|
| `figures/01_setup.R` | PCA + k-means + setup | **Nuevo en fork** |
| `figures/02_fig1_phenotypes.R` | Figura 1 | **Nuevo en fork** |
| `figures/03_fig2_bayesian.R` | Figura 2 | **Nuevo en fork** |
| `figures/04_fig3_clinical.R` | Figura 3 | **Nuevo en fork** |
| `figures/05_supp_figures.R` | Figuras S1-S4 | **Nuevo en fork** |
| `figures/06_descriptive.R` | Tabla 1 + Figs S5-S7 | **Nuevo en fork** |
| `figures/07_visual_abstract.R` | Visual abstract | **Nuevo en fork** |
| `figures/08_section31.R` | Figuras 3.1a-d | **Nuevo en fork** |
| `scripts/build_manuscript_v8.py` | Builder del DOCX | **Nuevo en fork** |
| `output/domain_comparisons.csv` | Comparaciones por dominio | **Nuevo en fork** |
| `output/tables/table1_baseline.csv` | Tabla 1 | **Nuevo en fork** |
| `R/3-paper-stats.R` | Estadísticas adicionales | **Nuevo en fork** |
| `docs/PCOV19_*.docx/html` | Manuscritos | **Nuevo en fork** |

## 4.4 Trazabilidad del pipeline

```
Matías (original)                    Lindy (fork)
─────────────────                    ────────────
raw_*.csv (8 archivos)    ──same──→  raw_*.csv
prep-data.R (bug)         ──FIXED─→  prep-data.R (corregido)
pcov.csv (severity bug)   ──DIFF──→  pcov.csv (corregido)
1-fit-models.R            ──same──→  (no regenerado)
models/*.rds (bug)        ──COPY──→  (no regenerado)
2-extract-parameters.R    ──same──→  (no re-ejecutado)
model_summaries.csv       ──IDÉNTICO→ model_summaries.csv ⚠️
index.qmd                 ──NOT USED→ (no usado en fork)
                          ──NEW───→  01_setup.R (PCA)
                          ──NEW───→  02-08 figuras R
                          ──NEW───→  build_manuscript_v8.py
                          ──NEW───→  PCOV19_Revision8_Final.docx
```

**Conclusión**: El manuscrito se construyó sobre una base híbrida: datos corregidos del fork + modelos NO regenerados del original. El PCA y los fenotipos son completamente nuevos (no existen en el repo original). Las figuras son nuevas. El build script es nuevo.
