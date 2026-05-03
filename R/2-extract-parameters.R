
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
pcov_std <- standardize(pcov, exclude = c("sociodemografico_age"))

## Load models
model_files <- list.files("models")
models <- lapply(model_files, function(i) {
  readRDS(file = paste0("models/",i))
})

models_summary <-
  lapply(models, summary_model) |>
  rbindlist()

models_summary[!var %like% "^b_", ] |>
  fwrite("output/model_summaries.csv")
