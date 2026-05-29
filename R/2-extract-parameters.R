
# Prepare workspace -------------------------------------------------------

## Load libraries
library(data.table)
library(datawizard)
library(brms)

## Load custom functions
source("R/_functions.R")

## Load data
data("pcov")

## Standardize data
pcov_std <- standardize(pcov)

## Load models
model_files <- list.files("models")
models <- lapply(model_files, function(i) {
  readRDS(file = paste0("models/",i))
})

models_summary <-
  lapply(models, summary_model, variable = "^b_") |>
  rbindlist(idcol = "area")

rm(models)

# -------------------------------------------------------------------------


models_summary[, area := fcase(
  grepl("celular|laboratorio", var), "Laboratory and Cellular",
  grepl("kinesiologia|espirometria", var), "Physical and Functional",
  grepl("psicologico", var), "Psychological",
  grepl("sociodemografico", var), "Quality of Life"
)]

models_summary[, var := gsub("movimiento|celular|espirometria|estatus|kinesiologia|laboratorio|psicologico|sociodemografico","",var)][]
models_summary[, var := gsub("[_]+"," ",var)][]

models_summary[, response := gsub("Intercept|^b |long covid symptoms 2 sum", "", var)][, response]
models_summary[, response := gsub("cronic pathologies|education|age$", "", response)][, response]
models_summary[, response := gsub("sexFemale|escala fas", "", response)][, response]
models_summary[, response := gsub("diabetesYes|hypertensionYes|dyslipidemiaYes|obesityYes", "", response)][, response]
models_summary[, response := gsub("vaccine sum|severity score", "", response)][, response]
models_summary[, response := gsub("E[3-7]|\\.L|\\.Q|\\.C", "", response)][, response]
models_summary[, response := gsub(" : ", "", response)][, response]
models_summary[, response := gsub("\\s+", "", response)][, response]

models_summary[, id := 1:.N]

models_summary[, var := gsub(pattern = response, replacement = "", var), id][]
models_summary[, var := gsub(pattern = "^b\\s+", replacement = "", var)][]
models_summary[, var := gsub(pattern = "long covid symptoms 2 sum", replacement = "[PCOV NoS]", var)][]
models_summary[, var := gsub(pattern = "severity score", replacement = "[PCOV Severity Score]", var)][]
models_summary[, var := gsub(pattern = "vaccine sum", replacement = "[PCOV NoV]", var)][]
models_summary[, var := gsub(pattern = "cronic pathologies", replacement = "[Pathologies:", var)][]
models_summary[, var := gsub(pattern = "diabetesYes", replacement = "Diabetes (Yes)]", var)][]
models_summary[, var := gsub(pattern = "hypertensionYes", replacement = "Hypertension (Yes)]", var)][]
models_summary[, var := gsub(pattern = "dyslipidemiaYes", replacement = "Dyslipidemia (Yes)]", var)][]
models_summary[, var := gsub(pattern = "obesityYes", replacement = "Obesity (Yes)]", var)][]
models_summary[, var := gsub(pattern = "\\]\\:", replacement = "] x", var)][]

models_summary <- models_summary[!var %like% "education[E]"]

models_summary[, var := gsub(pattern = "education\\.", replacement = "[Education level: ", var)][]
models_summary[, var := gsub(pattern = "level\\: C$", replacement = "level: Cubic]", var)][]
models_summary[, var := gsub(pattern = "level\\: Q$", replacement = "level: Quadratic]", var)][]
models_summary[, var := gsub(pattern = "level\\: L$", replacement = "level: Linear]", var)][]
models_summary[, var := gsub(pattern = "sexFemale", replacement = "[Sex: Female]", var)][]
models_summary[, var := gsub(pattern = "age$", replacement = "[Age]", var)][]
models_summary[, var := gsub(pattern = "escala fas", replacement = "[Fatigue scale]", var)][]

models_summary <- models_summary[!var %like% "Intercept"]

models_summary[, response := gsub("abcsbcells", "B cells", response)]
models_summary[, response := gsub("abcslinfocitostotales", "Total lymphocytes", response)]
models_summary[, response := gsub("ageassociatedbcell", "Aged B cells", response)]
models_summary[, response := gsub("albumin", "Albumin", response)]
models_summary[, response := gsub("baiscore", "BAI score", response)]
models_summary[, response := gsub("basofilos", "Basophils", response)]
models_summary[, response := gsub("bdiscore", "BDI score", response)]
models_summary[, response := gsub("bilirubin", "Bilirubin", response)]
models_summary[, response := gsub("bloodureanitrogen", "Blood urea nitrogen", response)]
models_summary[, response := gsub("calcio", "Calcium", response)]
models_summary[, response := gsub("cholesterol", "Cholesterol", response)]
models_summary[, response := gsub("creatinine", "Creatinine", response)]
models_summary[, response := gsub("eosinofilos", "Eosinophils", response)]
models_summary[, response := gsub("fsforo", "Phosphorus", response)]
models_summary[, response := gsub("glucose", "Glucose", response)]
models_summary[, response := gsub("gpt", "GPT", response)]
models_summary[, response := gsub("hematocrito", "Hematocrit", response)]
models_summary[, response := gsub("hemoglobina", "Hemoglobin", response)]
models_summary[, response := gsub("imc", "BMI", response)]
models_summary[, response := gsub("inbodydegrasa", "Fat mass", response)]
models_summary[, response := gsub("inbodyme", "Muscle mass", response)]
models_summary[, response := gsub("leucocitos", "Leucocytes", response)]
models_summary[, response := gsub("linfocitos", "Lymphocytes", response)]
models_summary[, response := gsub("lymphocytessubsetscd19", "Lymphocytes CD19+", response)]
models_summary[, response := gsub("lymphocytessubsetscd3", "Lymphocytes CD3+", response)]
models_summary[, response := gsub("lymphocytessubsetscd45", "Lymphocytes CD45+", response)]
models_summary[, response := gsub("lymphocytessubsetscd4", "Lymphocytes CD4+", response)]
models_summary[, response := gsub("lymphocytessubsetscd56", "Lymphocytes CD56+", response)]
models_summary[, response := gsub("lymphocytessubsetscd8", "Lymphocytes CD8+", response)]
models_summary[, response := gsub("monocitos", "Monocytes", response)]
models_summary[, response := gsub("peso", "Weight", response)]
models_summary[, response := gsub("pittsburgscore", "Pittsburg score", response)]
models_summary[, response := gsub("plaquetas", "Platelets", response)]
models_summary[, response := gsub("prebdfef2575ls", "PEF 25-75%", response)]
models_summary[, response := gsub("prebdfefmaxls", "PEF max", response)]
models_summary[, response := gsub("prebdfev1fvc", "Ratio FEV1/FVC", response)]
models_summary[, response := gsub("prebdfev1l", "FEV1", response)]
models_summary[, response := gsub("prebdfvcl", "FVC", response)]
models_summary[, response := gsub("proteins", "Proteins", response)]
models_summary[, response := gsub("q1caretakers", "QoL: Caretakers", response)]
models_summary[, response := gsub("q1familylife", "QoL: Family life", response)]
models_summary[, response := gsub("q1metalhealth", "QoL: Mental health", response)]
models_summary[, response := gsub("q1personalactivities", "QoL: Personal activities", response)]
models_summary[, response := gsub("q1profesionallife", "QoL: Profesional life", response)]
models_summary[, response := gsub("q1sociallife", "QoL: Social life", response)]
models_summary[, response := gsub("talla", "Height", response)]
models_summary[, response := gsub("transaminases", "Transaminases", response)]
models_summary[, response := gsub("triglycerides", "Triglycerides", response)]
models_summary[, response := gsub("urea", "Urea", response)]
models_summary[, response := gsub("uricacid", "Uric Acid", response)]
models_summary[, response := gsub("vitamind", "Vitamin D", response)]
models_summary[, response := gsub("waisscore", "WAISS score", response)]

models_summary[, table(response)]


# -------------------------------------------------------------------------

models_summary[, id := NULL]

setkey(models_summary, area, response, var)

setcolorder(models_summary)

# -------------------------------------------------------------------------


labels <- models_summary[, report_summary(.SD), keyby = list(area, response)]

labels[, label := gsub("\beta", "\\beta", label, fixed = TRUE)]

model_report <- labels[models_summary, on = c("area", "response", "var")]

# -------------------------------------------------------------------------

fwrite(x = model_report, file = "output/model_summaries.csv")
fwrite(x = model_report[pd >= 0.8], file = "output/model_summaries_signif.csv")
