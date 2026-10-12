# FASE 3 — RECONSTRUCCIÓN DEL PIPELINE
## Resultado de ejecutar prep-data.R

### Paso 1: prep-data.R (original Matías)

- **Script**: `data-raw/prep-data.R` (commit `d1b52e0`, 2026-05-28)
- **Entrada**: 8 archivos `data-raw/raw_*.csv`
- **Salida**: `data/pcov.csv` (292 filas × 318 columnas), `data/pcov.RData`
- **Resultado**: ✅ ÉXITO (exit code 0)
- **Hash pcov.csv regenerado**: `2d253a1be923...` — IDÉNTICO al hash git del commit original

### Hallazgo CRÍTICO: Bug en severity_score del repo original

El `prep-data.R` de Matías contiene un **bug de lógica** en el cálculo del severity_score que produce valores incorrectos. El fork `lsarmiento89/PCOV-19` lo corrigió.

**Diferencias en prep-data.R:**

| Aspecto | Original (Matías) | Fork (lsarmiento89) |
|---|---|---|
| `sympt_num` para NoS=0 | ❌ No definido → NA | ✅ `fcase(NoS==0, 0, ...)` |
| `qol_num` para QoL=0 | ❌ No definido → NA | ✅ `fcase(QoL==0, 0, ...)` |
| Lógica PIMAX range | ❌ `%in% 0:13` (siempre TRUE) | ✅ `== 1` |
| Lógica FAS range | ❌ `%in% 0:13` (siempre TRUE) | ✅ `== 1` |
| NA imputation | ❌ No imputa | ✅ `NA → 0` para pimax_num, fas_num, qol_num |

**Impacto del bug en el severity_score:**

| Métrica | Original (bug) | Fork (corregido) |
|---|---|---|
| n con severity_score | **182/292** (110 NA) | **292/292** |
| Media | 5.8 ± 2.5 | 7.5 ± 3.2 |
| Mediana | 5.0 | 7.0 |
| SS ≥ 6 | **88 (30.1%)** | **200 (68.5%)** |
| PCOV Mod/Sev (NoS≥1 & SS≥6) | **88 (30.1%)** | **193 (66.1%)** |

**Causa raíz**: El operador `%in% 0:13` en `fcase()` evalúa a TRUE para TODO valor numérico entre 0 y 13. Como las columnas `range_pimax_*` y `range_fas_*` son flags binarios (0/1), **todas las condiciones se cumplían simultáneamente**, asignando siempre el primer match (−1 para PIMAX, −1 para FAS). Esto producía un severity_score sesgado hacia abajo. Adicionalmente, la falta de manejo de casos cero (NoS=0, QoL=0) generaba 110 NA.

### Conclusión: El severity_score del repo original es INCORRECTO
El fork corrigió un bug real. El manuscrito usa los valores corregidos del fork.

### Paso 2: Modelos — NO REPRODUCIBLES

- **Script**: `R/1-fit-models.R`
- **Bloqueante**: Directorio `models/` está en `.gitignore`. Los 10 archivos `.rds` no están en el repo.
- **Script**: `R/2-extract-parameters.R`
- **Bloqueante**: Depende de `list.files("models")` → falla sin los .rds
- **Además**: Los modelos se ajustaron con el severity_score bugueado, por lo que incluso si tuviéramos los .rds, los resultados serían inconsistentes con el fork.

### Paso 3: Reporte Quarto — PARCIALMENTE reproducible

- **Script**: `docs/index.qmd`
- **Depende de**: `output/model_summaries.csv` y `output/model_summaries_signif.csv` (sí disponibles)
- **Bloqueante parcial**: Sin los .rds, el reporte puede renderizarse con los CSVs existentes, pero no puede regenerar las figuras desde cero.
