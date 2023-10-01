# Corrida general del workflow

options(error = function() {
  traceback(20)
  options(error = NULL)
  stop("exiting after script error")
})


# corrida de cada paso del workflow

# primeros pasos, relativamente rapidos
source("~/labo2023ba/src/workflow-inicial/Individual/611_tarea4_CA_reparar_dataset.r")
source("~/labo2023ba/src/workflow-inicial/Individual/621_tarea4_DR_corregir_drifting.r")
source("~/labo2023ba/src/workflow-inicial/Individual/631_tarea4_FE_historia.r")
source("~/labo2023ba/src/workflow-inicial/Individual/641_tarea4_TS_training_strategy.r")

# ultimos pasos, muy lentos
source("~/labo2023ba/src/workflow-inicial/Individual/651_tarea4_HT_lightgbm.r")
source("~/labo2023ba/src/workflow-inicial/Individual/661_tarea4_ZZ_final.r")
print("FIN")