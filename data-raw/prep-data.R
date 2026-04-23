
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
to_modify <- sapply(raw_data, function(x) {
  is.character(x) & any(grepl("[0-9]", x)) & !any(grepl("[a-zA-Z]", x))
}) |> which()

raw_data[, .SD, .SDcols = to_modify]

## Variables with wrong number format (comma instead of dot) ==> to number
raw_data[, (to_modify) := lapply(.SD, function(x) {
  x <- gsub(pattern = "\\,", replacement = "\\.", x = trimws(x))
  x[x == ""] <- NA_character_
  as.numeric(x)
}), .SDcols = to_modify]

rm(to_modify)


# -------------------------------------------------------------------------

raw_data[
  j = sociodemografico_long_covid_symptoms_2___sum :=
    sociodemografico_long_covid_symptoms_2___fatigue +
    sociodemografico_long_covid_symptoms_2___dyspnea +
    sociodemografico_long_covid_symptoms_2___memory +
    sociodemografico_long_covid_symptoms_2___concentration +
    sociodemografico_long_covid_symptoms_2___sleep +
    sociodemografico_long_covid_symptoms_2___cough +
    sociodemografico_long_covid_symptoms_2___thoracic_pain +
    sociodemografico_long_covid_symptoms_2___speech +
    sociodemografico_long_covid_symptoms_2___muscle_pain +
    sociodemografico_long_covid_symptoms_2___smell_loss +
    sociodemografico_long_covid_symptoms_2___taste_loss +
    sociodemografico_long_covid_symptoms_2___depression +
    sociodemografico_long_covid_symptoms_2___anxiety +
    sociodemografico_long_covid_symptoms_2___fever +
    sociodemografico_long_covid_symptoms_2___other
]

raw_data[
  j = sociodemografico_vaccine_sum :=
    as.numeric(!is.na(sociodemografico_vaccine_1_date)) +
    as.numeric(!is.na(sociodemografico_vaccine_2_date)) +
    as.numeric(!is.na(sociodemografico_bivalent_vaccine_date)) +
    as.numeric(!is.na(sociodemografico_booster_1_date)) +
    as.numeric(!is.na(sociodemografico_booster_2_date))
]

# -------------------------------------------------------------------------

## Column variables to a separate file
names(raw_data) |>
  cat(sep = "\n",
      file = "data-raw/col_names.txt")


# -------------------------------------------------------------------------

raw_data[, sociodemografico_sex := factor(
  x = sociodemografico_sex,
  levels = c("male", "feminine"),
  labels = c("Male", "Female")
)]
raw_data[, sociodemografico_education := factor(
  x = sociodemografico_education,
  levels = c("basico_incompleto", "basico_completo", "medio_incompleto", "medio_completo",
             "tecnico_profesional_incompleto", "tecnico_profesional_completo",
             "universitario_incompleto", "universitario_completo"),
  ordered = TRUE
)]

covariates <-
  raw_data[, sociodemografico_cronic_pathologies___diabetes:sociodemografico_cronic_pathologies___traumatologic_pathology] |>
  names()

raw_data[, (covariates) := lapply(.SD, factor, levels = 0:1, labels = c("No", "Yes")), .SDcols = covariates]

# -------------------------------------------------------------------------

## Extra underscores to single underscore
names(raw_data) <-
  names(raw_data) |>
  gsub(pattern = "[_]+", replacement = "_")

# -------------------------------------------------------------------------

## Final data object
pcov <- copy(raw_data); rm(raw_data)

## Save data to a RData format
save(pcov, file = "data/pcov.RData")

## Save data to a csv format
fwrite(pcov, file = "data/pcov.csv")
