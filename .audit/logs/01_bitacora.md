# AUDITORÍA DE REPRODUCIBILIDAD — BITÁCORA
## Proyecto: PCOV-19_reproducibility_audit
### Inicio: 2026-08-06

---

## Paso 0 — Creación del proyecto

- **Acción**: `git clone https://github.com/matcasti/2026-04-PCOV.git ~/Desktop/PCOV-19_reproducibility_audit`
- **Resultado**: Éxito. 23 archivos clonados.
- **Commit**: d1b52e03d62cd9050cfb10d0a45369e8b91c35d0
- **Fecha commit**: 2026-05-28 22:31:46 -0300
- **Autor**: Matías Castillo <matcasti@umag.cl>
- **Rama**: main
- **Integridad**: Verificada (working tree limpio)

## Paso 1 — Creación de estructura .audit/

- `.audit/logs/` — bitácoras de sesión
- `.audit/inventory/` — inventarios de archivos
- `.audit/reports/` — informes de hallazgos
- `.audit/evidence/` — evidencia (hashes, diffs, capturas)

## Paso 2 — Inventario completo

- **Archivo**: `.audit/inventory/01_inventario_completo.md`
- **Método**: `find`, `ls -lh`, lectura de headers CSV, lectura de scripts R/Python
- **Archivos analizados**: 23 (todos los del repo)
- **Clasificación**: datos fuente (8), datos procesados (3), scripts limpieza (1), scripts análisis (3), scripts figuras (0 — están en Quarto), archivos generados (5), archivos manuales (2), archivos ausentes (10 .rds)

---

## Hallazgos preliminares

1. **Handgrip SÍ existe** en el repo original: `kinesiologia_fpd_1` y `kinesiologia_fyi_1`
2. **NO hay PCA** en el repo original (agregado después en el fork lsarmiento89)
3. **NO hay manuscript builder** en el repo original
4. **10 modelos .rds gitignored** → no reproducibles sin ellos
5. **6MWT NO existe** en ningún raw data file del repo original
