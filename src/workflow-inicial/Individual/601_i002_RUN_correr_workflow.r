# Corrida general del workflow

options(error = function() {
  traceback(20)
  options(error = NULL)
  stop("exiting after script error")
})


# corrida de cada paso del workflow

# primeros pasos, relativamente rapidos
source("~/labo2023ba/src/workflow-inicial/Individual/611_i002_CA_reparar_dataset.r")
source("~/labo2023ba/src/workflow-inicial/Individual/621_i002_DR_corregir_drifting.r")
source("~/labo2023ba/src/workflow-inicial/Individual/631_i002_FE_historia.r")
source("~/labo2023ba/src/workflow-inicial/Individual/641_i002_TS_training_strategy.r")

# ultimos pasos, muy lentos
source("~/labo2023ba/src/workflow-inicial/Individual/651_i002_HT_lightgbm.r")
source("~/labo2023ba/src/workflow-inicial/Individual/661_i002_ZZ_final.r")
print("FIN")