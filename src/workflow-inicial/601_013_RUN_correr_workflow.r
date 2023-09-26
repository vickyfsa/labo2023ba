# Corrida general del workflow

options(error = function() {
  traceback(20)
  options(error = NULL)
  stop("exiting after script error")
})


# corrida de cada paso del workflow

# primeros pasos, relativamente rapidos
source("~/labo2023ba/src/workflow-inicial/611_000_CA_reparar_dataset.r")
source("~/labo2023ba/src/workflow-inicial/621_000_DR_corregir_drifting.r")
source("~/labo2023ba/src/workflow-inicial/631_013_FE_historia.r")
source("~/labo2023ba/src/workflow-inicial/641_013_TS_training_strategy.r")

# ultimos pasos, muy lentos
source("~/labo2023ba/src/workflow-inicial/651_013_HT_lightgbm.r")
source("~/labo2023ba/src/workflow-inicial/661_013_ZZ_final.r")
print("Done with RUN correr workflow")