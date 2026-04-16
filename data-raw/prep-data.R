
# Prepare workspace -------------------------------------------------------

## Load libraries
library(data.table)

## Import data
d_analisis_movimiento  <- fread("data-raw/raw_analisis_movimiento.csv") # Muy pocos datos n = 18
d_celulares            <- fread("data-raw/raw_celulares.csv")
d_espirometria         <- fread("data-raw/raw_espirometria.csv")
d_estatus_clinico      <- fread("data-raw/raw_estatus_clinico.csv")
d_kinesiologia         <- fread("data-raw/raw_kinesiologia.csv")
d_laboratorio          <- fread("data-raw/raw_laboratorio.csv")
d_psicologico          <- fread("data-raw/raw_psicologico.csv")
d_sociodemografico     <- fread("data-raw/raw_sociodemografico.csv")

names(d_analisis_movimiento)[-1L] <- paste0("movimiento_", names(d_analisis_movimiento)[-1L])
names(d_celulares)[-1L] <- paste0("celular_", names(d_celulares)[-1L])
names(d_espirometria)[-1L] <- paste0("espirometria_", names(d_espirometria)[-1L])
names(d_estatus_clinico)[-1L] <- paste0("estatus_", names(d_estatus_clinico)[-1L])
names(d_kinesiologia)[-1L] <- paste0("kinesiologia_", names(d_kinesiologia)[-1L])
names(d_laboratorio)[-1L] <- paste0("laboratorio_", names(d_laboratorio)[-1L])
names(d_psicologico)[-1L] <- paste0("psicologico_", names(d_psicologico)[-1L])
names(d_sociodemografico)[-1L] <- paste0("sociodemografico_", names(d_sociodemografico)[-1L])

raw_data <- d_analisis_movimiento[
  d_celulares, on = "record_id"][
  d_espirometria, on = "record_id"][
  d_estatus_clinico, on = "record_id"][
  d_kinesiologia, on = "record_id"][
  d_laboratorio, on = "record_id" ][
  d_psicologico, on = "record_id"][
  d_sociodemografico, on = "record_id"]

rm(d_analisis_movimiento,
   d_celulares,
   d_espirometria,
   d_estatus_clinico,
   d_kinesiologia,
   d_laboratorio,
   d_psicologico,
   d_sociodemografico)

# -------------------------------------------------------------------------

## NA-only columns
to_remove <- sapply(raw_data, function(x) {
  all(is.na(x))
}) |> which()

raw_data[, names(to_remove) := NULL]

## "_complete" columns
to_remove <- grep(pattern = "complete", x = names(raw_data), value = TRUE)

raw_data[, (to_remove) := NULL]

## With the same unique value
to_remove <- sapply(raw_data, function(x) {
  length(unique(x)) == 1
}) |> which()

raw_data[, names(to_remove) := NULL]

rm(to_remove)

# -------------------------------------------------------------------------

## Text variables but are supposed to be number
to_modidy <- sapply(raw_data, function(x) {
  is.character(x) & any(grepl("[0-9]", x)) & !any(grepl("[a-zA-Z]", x))
}) |> which()

raw_data[, .SD, .SDcols = to_modidy]

## Variables with wrong number format (comma instead of dot) ==> to number
raw_data[, (to_modidy) := lapply(.SD, function(x) {
  x <- gsub(pattern = "\\,", replacement = "\\.", x = trimws(x))
  x[x == ""] <- NA_character_
  as.numeric(x)
}), .SDcols = to_modidy]


# -------------------------------------------------------------------------

names(raw_data) |>
  cat(sep = "\n",
      file = "data-raw/col_names.txt")
