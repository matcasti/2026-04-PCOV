
# Prepare workspace -------------------------------------------------------

## Load libraries
library(data.table)
library(datawizard)
library(brms)

## Load data
data("pcov")

## Standardize data
pcov_std <- standardize(pcov)

# -------------------------------------------------------------------------

# Response variables:

# - Psychological
#   - psicologico_pittsburg_score
#   - psicologico_wais_score
#   - psicologico_bdi_score
#   - psicologico_bai_score

# - Hematológicos / Linfocitos
#   - laboratorio_monocitos
#   - laboratorio_linfocitos
#   - laboratorio_basofilos
#   - laboratorio_eosinofilos
#   - laboratorio_plaquetas
#   - laboratorio_leucocitos
#   - laboratorio_hemoglobina
#   - laboratorio_hematocrito

# - Perfil hepático / proteínas
#   - laboratorio_gpt
#   - laboratorio_transaminases
#   - laboratorio_bilirubin
#   - laboratorio_albumin
#   - laboratorio_proteins

# - Función renal y metabolismo nitrogenado
#   - laboratorio_creatinine
#   - laboratorio_urea
#   - laboratorio_blood_urea_nitrogen
#   - laboratorio_uric_acid

# - Metabolismo nutricional / mineral / glucídico-lipídico
#   - laboratorio_glucose
#   - laboratorio_cholesterol
#   - laboratorio_triglycerides
#   - laboratorio_vitamin_d
#   - laboratorio_f_sforo
#   - laboratorio_calcio

# - Subsets linfocitarios
#   - celular_lymphocytes_subsets_cd45
#   - celular_lymphocytes_subsets_cd19
#   - celular_lymphocytes_subsets_cd3
#   - celular_lymphocytes_subsets_cd4
#   - celular_lymphocytes_subsets_cd8
#   - celular_lymphocytes_subsets_cd56

# - Aged B Cells
#   - celular_abcs_linfocitos_totales
#   - celular_abcs_b_cells
#   - celular_age_associated_b_cell

# - Composición corporal
#   - kinesiologia_inbody_me
#   - kinesiologia_inbody_de_grasa
#   - kinesiologia_peso
#   - kinesiologia_talla
#   - kinesiologia_imc

# - Respiratorios
#   - espirometria_prebd_fvc_l
#   - espirometria_prebd_fev1_l
#   - espirometria_prebd_fev1_fvc
#   - espirometria_prebd_fef_25_75_l_s
#   - espirometria_prebd_fef_max_l_s
#   - espirometria_pim
#   - espirometria_pem

# - Calidad de vida
#   - sociodemografico_q1_personal_activities
#   - sociodemografico_q1_family_life
#   - sociodemografico_q1_profesional_life
#   - sociodemografico_q1_social_life
#   - sociodemografico_q1_metal_health
#   - sociodemografico_q1_caretakers

# Main effect:
# - sociodemografico_long_covid_symptoms_2_sum
# - sociodemografico_vaccine_sum
# - severity_score

# covariates:
# - sociodemografico_age
# - sociodemografico_sex
# - sociodemografico_education
# - kinesiologia_escala_fas
# - sociodemografico_cronic_pathologies_diabetes
# - sociodemografico_cronic_pathologies_hypertension
# - sociodemografico_cronic_pathologies_dyslipidemia
# - sociodemografico_cronic_pathologies_obesity

# -------------------------------------------------------------------------

## Custom function to specify the models
specify_model <- function(...) {
  arguments <-
    match.call()[-1L] |>
    as.character() |>
    paste(collapse = ", ")
  paste0(
    "bf(
      mvbind(",arguments,") | mi() ~
        (sociodemografico_long_covid_symptoms_2_sum +
        severity_score +
        sociodemografico_vaccine_sum) *
        (sociodemografico_age +
           sociodemografico_sex +
           kinesiologia_escala_fas +
           sociodemografico_education +
           sociodemografico_cronic_pathologies_diabetes +
           sociodemografico_cronic_pathologies_hypertension +
           sociodemografico_cronic_pathologies_dyslipidemia +
           sociodemografico_cronic_pathologies_obesity)
    ) + set_rescor(TRUE)"
  ) |> str2expression() |> eval()
}

# -------------------------------------------------------------------------

# Psychological
psicologico_model <- specify_model(
  psicologico_pittsburg_score,
  psicologico_wais_score,
  psicologico_bdi_score,
  psicologico_bai_score
)

# Hematológicos / Linfocitos
hemograma_model <- specify_model(
  laboratorio_monocitos,
  laboratorio_linfocitos,
  laboratorio_basofilos,
  laboratorio_eosinofilos,
  laboratorio_plaquetas,
  laboratorio_leucocitos,
  laboratorio_hemoglobina,
  laboratorio_hematocrito
)

# Perfil hepático / proteínas
hepatico_model <- specify_model(
  laboratorio_gpt,
  laboratorio_transaminases,
  laboratorio_bilirubin,
  laboratorio_albumin,
  laboratorio_proteins
)

# Función renal y metabolismo nitrogenado
renal_model <- specify_model(
  laboratorio_creatinine,
  laboratorio_urea,
  laboratorio_blood_urea_nitrogen,
  laboratorio_uric_acid
)

# Metabolismo nutricional / mineral / glucídico-lipídico
metabolismo_model <- specify_model(
  laboratorio_glucose,
  laboratorio_cholesterol,
  laboratorio_triglycerides,
  laboratorio_vitamin_d,
  laboratorio_f_sforo,
  laboratorio_calcio
)

# Subsets linfocitarios
subpoblaciones_model <- specify_model(
  celular_lymphocytes_subsets_cd45,
  celular_lymphocytes_subsets_cd19,
  celular_lymphocytes_subsets_cd3,
  celular_lymphocytes_subsets_cd4,
  celular_lymphocytes_subsets_cd8,
  celular_lymphocytes_subsets_cd56
)

# Aged B Cells
abc_model <- specify_model(
  celular_abcs_linfocitos_totales,
  celular_abcs_b_cells,
  celular_age_associated_b_cell
)

# Composición corporal
composicion_model <- specify_model(
  kinesiologia_inbody_me,
  kinesiologia_inbody_de_grasa,
  kinesiologia_peso,
  kinesiologia_talla,
  kinesiologia_imc
)

# Respiratorios
respiratorio_model <- specify_model(
  espirometria_prebd_fvc_l,
  espirometria_prebd_fev1_l,
  espirometria_prebd_fev1_fvc,
  espirometria_prebd_fef_25_75_l_s,
  espirometria_prebd_fef_max_l_s
)

# Calidad de vida
calidad_vida_model <- specify_model(
  sociodemografico_q1_personal_activities,
  sociodemografico_q1_family_life,
  sociodemografico_q1_profesional_life,
  sociodemografico_q1_social_life,
  sociodemografico_q1_metal_health,
  sociodemografico_q1_caretakers
)


# -------------------------------------------------------------------------

## Custom priors
custom_prior <- function(response) {
  c(
    set_prior("normal(0,3)", class = "b", resp = response),
    set_prior("normal(0,3)", class = "Intercept", resp = response, lb = 0),
    set_prior("normal(0,3)", class = "sigma", resp = response, lb = 0),
    set_prior("lkj(2)", class = "rescor")
  )
}

# -------------------------------------------------------------------------

psicologico_fit <- brm(
  formula = psicologico_model,
  data = pcov_std,
  family = gaussian(link = "identity"),
  prior = custom_prior(c("psicologicopittsburgscore",
                         "psicologicowaisscore",
                         "psicologicobdiscore",
                         "psicologicobaiscore")),
  chains = 4, iter = 5000, warmup = 2500, cores = 4,
  seed = 1234, file = "models//psicologico_fit.rds",
  control = list(adapt_delta = 0.99,
                 max_treedepth = 20)
)

rstan::check_hmc_diagnostics(psicologico_fit$fit)

hemograma_fit <- brm(
  formula = hemograma_model,
  data = pcov_std,
  family = gaussian(link = "identity"),
  prior = custom_prior(c("laboratoriomonocitos",
                         "laboratoriolinfocitos",
                         "laboratoriobasofilos",
                         "laboratorioeosinofilos",
                         "laboratorioplaquetas",
                         "laboratorioleucocitos",
                         "laboratoriohemoglobina",
                         "laboratoriohematocrito")),
  chains = 4, iter = 5000, warmup = 2500, cores = 4,
  seed = 1234, file = "models/hemograma_fit.rds",
  control = list(adapt_delta = 0.99,
                 max_treedepth = 20)
)

rstan::check_hmc_diagnostics(hemograma_fit$fit)

hepatico_fit <- brm(
  formula = hepatico_model,
  data = pcov_std,
  family = gaussian(link = "identity"),
  prior = custom_prior(c("laboratoriogpt",
                         "laboratoriotransaminases",
                         "laboratoriobilirubin",
                         "laboratorioalbumin",
                         "laboratorioproteins")),
  chains = 4, iter = 5000, warmup = 2500, cores = 4,
  seed = 1234, file = "models/hepatico_fit.rds",
  control = list(adapt_delta = 0.99,
                 max_treedepth = 20)
)

rstan::check_hmc_diagnostics(hepatico_fit$fit)

renal_fit <- brm(
  formula = renal_model,
  data = pcov_std,
  family = gaussian(link = "identity"),
  prior = custom_prior(c("laboratoriocreatinine",
                         "laboratoriourea",
                         "laboratoriobloodureanitrogen",
                         "laboratoriouricacid")),
  chains = 4, iter = 5000, warmup = 2500, cores = 4,
  seed = 1234, file = "models/renal_fit.rds",
  control = list(adapt_delta = 0.99,
                 max_treedepth = 20)
)

rstan::check_hmc_diagnostics(renal_fit$fit)

metabolismo_fit <- brm(
  formula = metabolismo_model,
  data = pcov_std,
  family = gaussian(link = "identity"),
  prior = custom_prior(c("laboratorioglucose",
                         "laboratoriocholesterol",
                         "laboratoriotriglycerides",
                         "laboratoriovitamind",
                         "laboratoriofsforo",
                         "laboratoriocalcio")),
  chains = 4, iter = 5000, warmup = 2500, cores = 4,
  seed = 1234, file = "models/metabolismo_fit.rds",
  control = list(adapt_delta = 0.99,
                 max_treedepth = 20)
)

rstan::check_hmc_diagnostics(metabolismo_fit$fit)

subpoblaciones_fit <- brm(
  formula = subpoblaciones_model,
  data = pcov_std,
  family = gaussian(link = "identity"),
  prior = custom_prior(c("celularlymphocytessubsetscd45",
                         "celularlymphocytessubsetscd19",
                         "celularlymphocytessubsetscd3",
                         "celularlymphocytessubsetscd4",
                         "celularlymphocytessubsetscd8",
                         "celularlymphocytessubsetscd56")),
  chains = 4, iter = 5000, warmup = 2500, cores = 4,
  seed = 1234, file = "models/subpoblaciones_fit.rds",
  control = list(adapt_delta = 0.99,
                 max_treedepth = 20)
)

rstan::check_hmc_diagnostics(subpoblaciones_fit$fit)

abc_fit <- brm(
  formula = abc_model,
  data = pcov_std,
  family = gaussian(link = "identity"),
  prior = custom_prior(c("celularabcslinfocitostotales",
                         "celularabcsbcells",
                         "celularageassociatedbcell")),
  chains = 4, iter = 5000, warmup = 2500, cores = 4,
  seed = 1234, file = "models/abc_fit.rds",
  control = list(adapt_delta = 0.99,
                 max_treedepth = 20)
)

rstan::check_hmc_diagnostics(abc_fit$fit)

composicion_fit <- brm(
  formula = composicion_model,
  data = pcov_std,
  family = gaussian(link = "identity"),
  prior = custom_prior(c("kinesiologiainbodyme",
                         "kinesiologiainbodydegrasa",
                         "kinesiologiapeso",
                         "kinesiologiatalla",
                         "kinesiologiaimc")),
  chains = 4, iter = 5000, warmup = 2500, cores = 4,
  seed = 1234, file = "models/composicion_fit.rds",
  control = list(adapt_delta = 0.99,
                 max_treedepth = 20)
)

rstan::check_hmc_diagnostics(composicion_fit$fit)

respiratorio_fit <- brm(
  formula = respiratorio_model,
  data = pcov_std,
  family = gaussian(link = "identity"),
  prior = custom_prior(c("espirometriaprebdfvcl",
                         "espirometriaprebdfev1l",
                         "espirometriaprebdfev1fvc",
                         "espirometriaprebdfef2575ls",
                         "espirometriaprebdfefmaxls")),
  chains = 4, iter = 5000, warmup = 2500, cores = 4,
  seed = 1234, file = "models/respiratorio_fit.rds",
  control = list(adapt_delta = 0.99,
                 max_treedepth = 20)
)

rstan::check_hmc_diagnostics(respiratorio_fit$fit)

calidad_vida_fit <- brm(
  formula = calidad_vida_model,
  data = pcov_std,
  family = gaussian(link = "identity"),
  prior = custom_prior(c("sociodemograficoq1personalactivities",
                         "sociodemograficoq1familylife",
                         "sociodemograficoq1profesionallife",
                         "sociodemograficoq1sociallife",
                         "sociodemograficoq1metalhealth",
                         "sociodemograficoq1caretakers")),
  chains = 4, iter = 5000, warmup = 2500, cores = 4,
  seed = 1234, file = "models/calidad_vida_fit.rds",
  control = list(adapt_delta = 0.99,
                 max_treedepth = 20)
)

rstan::check_hmc_diagnostics(calidad_vida_fit$fit)
