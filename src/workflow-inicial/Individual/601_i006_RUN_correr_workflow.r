# Corrida general del workflow

options(error = function() {
  traceback(20)
  options(error = NULL)
  stop("exiting after script error")
})


# corrida de cada paso del workflow

# primeros pasos, relativamente rapidos
source("~/labo2023ba/src/workflow-inicial/Individual/611_i006_CA_reparar_dataset.r")
source("~/labo2023ba/src/workflow-inicial/Individual/621_i006_DR_corregir_drifting.r")
source("~/labo2023ba/src/workflow-inicial/Individual/631_i006_FE_historia.r")
source("~/labo2023ba/src/workflow-inicial/Individual/641_i006_TS_training_strategy.r")

# ultimos pasos, muy lentos
source("~/labo2023ba/src/workflow-inicial/Individual/651_i006_HT_lightgbm.r")
source("~/labo2023ba/src/workflow-inicial/Individual/661_i006_ZZ_final.r")
print("FIN")