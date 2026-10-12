# INFORME FINAL DE REPRODUCIBILIDAD
## PCOV-19: Del repositorio original al manuscrito

**Fecha**: 2026-08-06
**Auditor**: Hermes Agent
**Repositorio original**: https://github.com/matcasti/2026-04-PCOV (commit `d1b52e0`)
**Repositorio fork**: https://github.com/lsarmiento89/PCOV-19 (commit `1976fbe`)
**Proyecto auditoría**: ~/Desktop/PCOV-19_reproducibility_audit/

---

## RESUMEN EJECUTIVO

El manuscrito PCOV-19 v8 se construyó sobre una **base híbrida** con tres capas de datos inconsistentes entre sí:

| Capa | Origen | Estado |
|---|---|---|
| **Descriptivos** (severity_score, prevalencia, demografía) | Fork — prep-data.R corregido | ✅ Correctos |
| **Modelos bayesianos** (β, pd, BF₁₀) | Original — severity_score bugueado | ❌ Inconsistentes |
| **PCA y fenotipos** | Fork — código nuevo, no existe en original | ⚠️ Parcialmente correcto |
| **Tablas y figuras** | Build script Python — valores hardcodeados | ❌ No reproducibles |

**El manuscrito NO es completamente reproducible desde ningún repositorio.** Los modelos usan un severity_score incorrecto, el PCA tiene errores de n y varianza, y múltiples valores en tablas están hardcodeados y no coinciden con los datos reales.

---

## 1. BUG CRÍTICO EN severity_score DEL REPO ORIGINAL

El `prep-data.R` de Matías contiene un bug que produce severity_scores incorrectos. El fork lo corrigió.

### 1.1 El bug

```r
# ORIGINAL (bug) — línea 195-196
kinesiologia_range_pimax_1 %in% 0:13, -1,   # ❌ %in% 0:13 es SIEMPRE TRUE
kinesiologia_range_pimax_2 %in% 0:13,  0,   # ❌ idem
kinesiologia_range_pimax_3 %in% 0:13,  1    # ❌ idem
```

El operador `%in% 0:13` evalúa a TRUE para cualquier valor 0-13. Como las columnas `range_*` son flags binarios (0/1), **todas las condiciones se cumplían simultáneamente**, y `fcase()` devolvía siempre la primera (−1). Adicionalmente, NoS=0 y QoL=0 no estaban definidos, generando 110 NA.

### 1.2 La corrección (fork)

```r
# FORK (corregido)
kinesiologia_range_pimax_1 == 1, -1,   # ✅ Solo cuando el flag es 1
kinesiologia_range_pimax_2 == 1,  0,
kinesiologia_range_pimax_3 == 1,  1
# + NA → 0 imputation
# + NoS=0 → sympt_num=0, QoL=0 → qol_num=0
```

### 1.3 Impacto

| Métrica | Original (bug) | Fork (corregido) |
|---|---|---|
| severity_score n | 182/292 (110 NA) | 292/292 |
| severity_score media | 5.8 ± 2.5 | 7.5 ± 3.2 |
| SS ≥ 6 | 88 (30.1%) | 200 (68.5%) |
| PCOV Mod/Sev | 88 (30.1%) | 193 (66.1%) |

---

## 2. INCONSISTENCIA MODELOS BAYESIANOS

### 2.1 Evidencia

| Archivo | SHA256 | Coinciden? |
|---|---|---|
| Original `model_summaries_signif.csv` | `511ca0da...` | — |
| Fork `model_summaries_signif.csv` | `511ca0da...` | **IDÉNTICO** |

Los 803 parámetros son idénticos entre ambos repositorios. El fork **NO regeneró los modelos** con el severity_score corregido.

### 2.2 Consecuencia

- Los modelos se ajustaron con `severity_score ≈ 5.8` (original bugueado)
- El manuscrito reporta `severity_score = 7.5 ± 3.2` (fork corregido)
- Las estimaciones β, pd, y BF₁₀ para `[PCOV Severity Score]` fueron calculadas con un predictor **3 puntos más bajo** que el reportado
- Esto afecta potencialmente TODOS los parámetros del modelo (efectos principales, interacciones, BF)

### 2.3 Los 10 archivos .rds están gitignored

El directorio `models/` está en `.gitignore`. Sin los archivos `.rds`:
- `R/2-extract-parameters.R` **no puede ejecutarse** (hace `list.files("models")`)
- Los modelos **no son reproducibles** desde el repositorio
- No hay forma de verificar si `model_summaries.csv` realmente proviene de esos modelos

---

## 3. HANDGRIP: DATOS REALES vs MANUSCRITO

Handgrip **SÍ existe** en los datos (columnas `kinesiologia_fpd_1`/`fyi_1`, 282/292, 96.6%).

| Variable | Grupo | Datos reales | Manuscrito (Table 1) | Error |
|---|---|---|---|---|
| Right (kg) | Mild | **36.6 ± 12.7** | 31.2 ± 8.5 | **−15%** |
| Right (kg) | ModSev | **28.6 ± 10.3** | 27.8 ± 9.1 | −3% |
| Left (kg) | Mild | **35.4 ± 12.2** | 30.1 ± 8.2 | **−15%** |
| Left (kg) | ModSev | **27.4 ± 10.1** | 26.4 ± 8.8 | −4% |

**Conclusión**: Los valores en el manuscrito NO coinciden con los datos. Las medias de Mild están subestimadas en ~15%. Las SDs están subestimadas en ~30%. El `01_setup.R` del fork dice erróneamente que handgrip "no está disponible".

---

## 4. PCA: LO QUE EL CÓDIGO HACE vs LO QUE EL MANUSCRITO DICE

| Parámetro | Código real (01_setup.R) | Manuscrito |
|---|---|---|
| n participantes | **75** (de 200 SS≥6) | "193 with complete PCA data" |
| Variables | **14** | "15" (incluye handgrip) |
| Varianza PC1 | **20.6%** | "34.2%" |
| Varianza PC2 | **16.2%** | "18.5%" |
| Varianza PC3 | **13.1%** | "9.7%" |
| Varianza acumulada | **49.9%** | "62.4%" |

**Causa del n=75**: FVC (`espirometria_prebd_fvc_l`) solo está disponible en 75/200 (37.5%) de los SS≥6. El PCA en R automáticamente descarta los casos incompletos.

### 4.1 Si se quita FVC y se agrega handgrip

| Parámetro | Valor |
|---|---|
| n participantes | **192** (de 200) |
| Varianza acumulada | **44.9%** |

**Los valores de varianza del manuscrito (62.4%) no se reproducen con ninguna configuración.** Están hardcodeados en el build script.

---

## 5. 6MWT: FABRICADO

- **No existe** en ningún raw data file del repositorio original
- **No existe** en `pcov.csv` (ni original ni fork)
- **No existe** en `model_summaries_signif.csv`
- **No existe** en ningún script R
- Única mención: `build_manuscript_v8.py` línea 447, listado como outcome modelado

---

## 6. TABLA 2: VALORES HARDCODEADOS vs DATOS REALES

| Variable | Manuscript Mild | Real Mild | Manuscript ModSev | Real ModSev |
|---|---|---|---|---|
| FAS | 16.8 ± 4.8 | **17.7 ± 4.6** | 28.6 ± 8.1 | **26.4 ± 7.1** |
| BAI | 4.8 ± 3.8 | **6.1 ± 6.8** | 18.3 ± 10.8 | **18.1 ± 10.7** |
| BDI-II | 5.9 ± 4.1 | **6.7 ± 5.6** | 17.1 ± 9.3 | **17.1 ± 9.3** |
| PSQI | 7.0 ± 3.9 | **7.3 ± 4.1** | 11.0 ± 4.1 | **11.0 ± 4.1** |
| WAIS-IV | **18.2 ± 5.1** | **22.6 ± 4.5** ❌ | **15.8 ± 5.6** | **21.9 ± 4.7** ❌ |
| PIMAX | 90.7 ± 30.6 | **88.7 ± 30.9** | 69.8 ± 28.7 | **70.0 ± 28.8** |
| GPT | 31.0 ± 22.6 | **30.0 ± 22.1** | 26.4 ± 25.3 | **26.8 ± 25.7** |
| Handgrip R | 31.2 ± 8.5 | **36.6 ± 12.7** ❌ | 27.8 ± 9.1 | **28.6 ± 10.3** |

**DISCREPANCIAS SIGNIFICATIVAS**: WAIS-IV (error de ~4-6 puntos, ~20%), Handgrip Mild (error de ~15%), FAS Mild (error de ~1 punto).

---

## 7. RESUMEN DE REPRODUCIBILIDAD POR COMPONENTE

| Componente | ¿Reproducible? | Causa |
|---|---|---|
| **pcov.csv (fork)** | ✅ Sí | prep-data.R corregido se ejecuta correctamente |
| **pcov.csv (original)** | ✅ Sí | prep-data.R original se ejecuta, pero con bug |
| **severity_score (fork)** | ✅ Sí | Corregido, valores correctos |
| **Modelos bayesianos** | ❌ No | .rds gitignored + severity_score bugueado |
| **PCA / clustering** | ⚠️ Parcial | Código ejecutable pero n=75, no 193 |
| **Varianza PCA** | ❌ No | Valores hardcodeados (62.4% vs 49.9% real) |
| **Tabla 1 (descriptivos)** | ⚠️ Parcial | Algunos valores hardcodeados no coinciden |
| **Tabla 2 (outcomes)** | ❌ No | Valores hardcodeados, múltiples errores |
| **Tabla 4 (contrast profiles)** | ❌ No | Todos los valores hardcodeados |
| **Figuras R** | ✅ Sí | Scripts ejecutables (02-08) |
| **Figura 1 (PCA)** | ⚠️ Parcial | Basada en PCA con n=75 y varianza incorrecta |
| **Handgrip en texto** | ❌ No | Valores no coinciden con datos |
| **6MWT** | ❌ No | No existe en los datos |
| **Manuscrito DOCX** | ❌ No | Build script con valores hardcodeados |

---

## 8. RECOMENDACIONES

### Prioridad 1 — Críticas para reproducibilidad

1. **Regenerar modelos bayesianos** con el severity_score corregido del fork
2. **Corregir PCA**: decidir si incluir handgrip (n≈192) o mantener FVC (n=75), pero reportar el n real y la varianza real
3. **Eliminar 6MWT** del manuscrito (no existe en los datos)
4. **Recalcular todos los valores de tablas** desde los datos, no hardcodear

### Prioridad 2 — Consistencia

5. Corregir valores de handgrip en tablas y texto con datos reales
6. Corregir WAIS-IV (diferencia de ~4-6 puntos)
7. Unificar definición de PCOV Mod/Sev entre scripts R y manuscrito

### Prioridad 3 — Trazabilidad

8. Incluir `models/*.rds` en el repositorio o documentar cómo regenerarlos
9. Versionar `prep-data.R` con el fix documentado
10. Reconstruir `model_summaries.csv` desde modelos corregidos
