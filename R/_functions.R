bf_01 <- function(x, prior_sigma) {
  dens <- density(x = as.numeric(x))
  dens_at_0 <- approx(dens$x, dens$y, xout = 0, n = 1000, rule = 2)$y
  dnorm(x = 0, mean = 0, sd = prior_sigma) / dens_at_0
}

summary_posterior <- function(x, prior_sigma = 3) {
  estimate = round(x = median(x), digits = 2)
  ci = round(x = tidybayes::hdi(x), digits = 2)
  ci = paste0("[", paste0(ci, collapse = ", "), "]")
  pd_side = if (estimate < 0) {x < 0} else {x > 0}
  pd = round(x = sum(pd_side)/length(x), digits = 3)
  ps_side = if (estimate < 0) {x < -0.1} else {x > 0.1}
  ps = round(x = sum(ps_side)/length(x), digits = 3)
  bf = round(x = bf_01(x, prior_sigma), digits = 2)
  ess = round(x = posterior::ess_basic(x), digits = 1)
  rhat = round(x = posterior::rhat(x), digits = 3)

  list(estimate = estimate, ci = ci,
       pd = pd, ps = ps, bf = bf,
       ess = ess, rhat = rhat)
}

summary_model <- function(model, variable = NULL) {
  m_summary <-
    brms::as_draws_df(model, variable = variable, regex = TRUE) |>
    lapply(summary_posterior) |>
    rbindlist(idcol = "var") |>
    as.data.table()

  m_summary[!var %in% c(".chain", ".iteration", ".draw"),]
}

report_summary <- function(m_summary, return_bf = TRUE) {
  if (isTRUE(return_bf)) {
    m_report<- m_summary[, list(
      effect = paste0("$\beta$ = ", estimate, ", CI~95%~", ci),
      significance = paste0("pd = ", pd*100, "%, ps = ", ps*100, "%, BF~10~ = ", bf),
      convergence = paste0("ESS = ", ess, ", R-hat = ", rhat)
    ), by = var]
  } else if (isFALSE(return_bf)) {
    m_report<- m_summary[, list(
      effect = paste0("$\beta$ = ", estimate, ", CI~95%~", ci),
      significance = paste0("pd = ", pd*100, "%, ps = ", ps*100, "%"),
      convergence = paste0("ESS = ", ess, ", R-hat = ", rhat)
    ), by = var]
  } else stop("`return_bf` must be either TRUE or FALSE, now it returned:", return_bf)

  m_report[, var := gsub("_", " ", var)][]
  m_report[, list(label = paste0(effect, ", ", significance)), by = "var"]
}

report_posterior <- function(x, prior_sigma = 3, return_bf = TRUE) {
  m_summary <-
    summary_posterior(
      x = x,
      prior_sigma = prior_sigma
    ) |>
    as.data.table()

  m_summary$var <- NA

  report_summary(
    m_summary = m_summary,
    return_bf = return_bf
  )
}

report_model <- function(model, variable = NULL, return_bf = TRUE) {
  m_summary <-
    summary_model(
      model = model,
      variable = variable
    )

  report_summary(
    m_summary = m_summary,
    return_bf = return_bf
  )
}
