# Experimentos Colaborativos Default
# Workflow  Data Drifting repair

# limpio la memoria
rm(list = ls(all.names = TRUE)) # remove all objects
gc(full = TRUE) # garbage collection

require("data.table")
require("yaml")


# Parametros del script
PARAM <- list()
PARAM$experimento <- "DR621_i003"

PARAM$exp_input <- "CA611_i003"

PARAM$variables_intrames <- TRUE # atencion esto esta en TRUE

# valores posibles
#  "ninguno", "rank_simple", "rank_cero_fijo", "deflacion", "estandarizar"
#Problema 02 - Julieta Dominguez y Vanina Tempesta
# En este caso dice deflación pero lo que haremos es dolarizar las variables 
PARAM$metodo <- "deflacion"

PARAM$home <- "~/buckets/b1/"
# FIN Parametros del script

OUTPUT <- list()

#------------------------------------------------------------------------------

options(error = function() {
  traceback(20)
  options(error = NULL)
  stop("exiting after script error")
})
#------------------------------------------------------------------------------

GrabarOutput <- function() {
  write_yaml(OUTPUT, file = "output.yml") # grabo output
}
#------------------------------------------------------------------------------
# Esta es la parte que los alumnos deben desplegar todo su ingenio
# Agregar aqui sus PROPIAS VARIABLES manuales

AgregarVariables_IntraMes <- function(dataset) {
  gc()
  # INICIO de la seccion donde se deben hacer cambios con variables nuevas

  # creo un ctr_quarter que tenga en cuenta cuando
  # los clientes hace 3 menos meses que estan
  dataset[, ctrx_quarter_normalizado := ctrx_quarter]
  dataset[cliente_antiguedad == 1, ctrx_quarter_normalizado := ctrx_quarter * 5]
  dataset[cliente_antiguedad == 2, ctrx_quarter_normalizado := ctrx_quarter * 2]
  dataset[
    cliente_antiguedad == 3,
    ctrx_quarter_normalizado := ctrx_quarter * 1.2
  ]

  # variable extraida de una tesis de maestria de Irlanda
  dataset[, mpayroll_sobre_edad := mpayroll / cliente_edad]

  # se crean los nuevos campos para MasterCard  y Visa,
  #  teniendo en cuenta los NA's
  # varias formas de combinar Visa_status y Master_status
  dataset[, vm_status01 := pmax(Master_status, Visa_status, na.rm = TRUE)]
  dataset[, vm_status02 := Master_status + Visa_status]

  dataset[, vm_status03 := pmax(
    ifelse(is.na(Master_status), 10, Master_status),
    ifelse(is.na(Visa_status), 10, Visa_status)
  )]

  dataset[, vm_status04 := ifelse(is.na(Master_status), 10, Master_status)
    + ifelse(is.na(Visa_status), 10, Visa_status)]

  dataset[, vm_status05 := ifelse(is.na(Master_status), 10, Master_status)
    + 100 * ifelse(is.na(Visa_status), 10, Visa_status)]

  dataset[, vm_status06 := ifelse(is.na(Visa_status),
    ifelse(is.na(Master_status), 10, Master_status),
    Visa_status
  )]

  dataset[, mv_status07 := ifelse(is.na(Master_status),
    ifelse(is.na(Visa_status), 10, Visa_status),
    Master_status
  )]


  # combino MasterCard y Visa
  dataset[, vm_mfinanciacion_limite := rowSums(cbind(Master_mfinanciacion_limite, Visa_mfinanciacion_limite), na.rm = TRUE)]

  dataset[, vm_Fvencimiento := pmin(Master_Fvencimiento, Visa_Fvencimiento, na.rm = TRUE)]
  dataset[, vm_Finiciomora := pmin(Master_Finiciomora, Visa_Finiciomora, na.rm = TRUE)]
  dataset[, vm_msaldototal := rowSums(cbind(Master_msaldototal, Visa_msaldototal), na.rm = TRUE)]
  dataset[, vm_msaldopesos := rowSums(cbind(Master_msaldopesos, Visa_msaldopesos), na.rm = TRUE)]
  dataset[, vm_msaldodolares := rowSums(cbind(Master_msaldodolares, Visa_msaldodolares), na.rm = TRUE)]
  dataset[, vm_mconsumospesos := rowSums(cbind(Master_mconsumospesos, Visa_mconsumospesos), na.rm = TRUE)]
  dataset[, vm_mconsumosdolares := rowSums(cbind(Master_mconsumosdolares, Visa_mconsumosdolares), na.rm = TRUE)]
  dataset[, vm_mlimitecompra := rowSums(cbind(Master_mlimitecompra, Visa_mlimitecompra), na.rm = TRUE)]
  dataset[, vm_madelantopesos := rowSums(cbind(Master_madelantopesos, Visa_madelantopesos), na.rm = TRUE)]
  dataset[, vm_madelantodolares := rowSums(cbind(Master_madelantodolares, Visa_madelantodolares), na.rm = TRUE)]
  dataset[, vm_fultimo_cierre := pmax(Master_fultimo_cierre, Visa_fultimo_cierre, na.rm = TRUE)]
  dataset[, vm_mpagado := rowSums(cbind(Master_mpagado, Visa_mpagado), na.rm = TRUE)]
  dataset[, vm_mpagospesos := rowSums(cbind(Master_mpagospesos, Visa_mpagospesos), na.rm = TRUE)]
  dataset[, vm_mpagosdolares := rowSums(cbind(Master_mpagosdolares, Visa_mpagosdolares), na.rm = TRUE)]
  dataset[, vm_fechaalta := pmax(Master_fechaalta, Visa_fechaalta, na.rm = TRUE)]
  dataset[, vm_mconsumototal := rowSums(cbind(Master_mconsumototal, Visa_mconsumototal), na.rm = TRUE)]
  dataset[, vm_cconsumos := rowSums(cbind(Master_cconsumos, Visa_cconsumos), na.rm = TRUE)]
  dataset[, vm_cadelantosefectivo := rowSums(cbind(Master_cadelantosefectivo, Visa_cadelantosefectivo), na.rm = TRUE)]
  dataset[, vm_mpagominimo := rowSums(cbind(Master_mpagominimo, Visa_mpagominimo), na.rm = TRUE)]

  # a partir de aqui juego con la suma de Mastercard y Visa
  dataset[, vmr_Master_mlimitecompra := Master_mlimitecompra / vm_mlimitecompra]
  dataset[, vmr_Visa_mlimitecompra := Visa_mlimitecompra / vm_mlimitecompra]
  dataset[, vmr_msaldototal := vm_msaldototal / vm_mlimitecompra]
  dataset[, vmr_msaldopesos := vm_msaldopesos / vm_mlimitecompra]
  dataset[, vmr_msaldopesos2 := vm_msaldopesos / vm_msaldototal]
  dataset[, vmr_msaldodolares := vm_msaldodolares / vm_mlimitecompra]
  dataset[, vmr_msaldodolares2 := vm_msaldodolares / vm_msaldototal]
  dataset[, vmr_mconsumospesos := vm_mconsumospesos / vm_mlimitecompra]
  dataset[, vmr_mconsumosdolares := vm_mconsumosdolares / vm_mlimitecompra]
  dataset[, vmr_madelantopesos := vm_madelantopesos / vm_mlimitecompra]
  dataset[, vmr_madelantodolares := vm_madelantodolares / vm_mlimitecompra]
  dataset[, vmr_mpagado := vm_mpagado / vm_mlimitecompra]
  dataset[, vmr_mpagospesos := vm_mpagospesos / vm_mlimitecompra]
  dataset[, vmr_mpagosdolares := vm_mpagosdolares / vm_mlimitecompra]
  dataset[, vmr_mconsumototal := vm_mconsumototal / vm_mlimitecompra]
  dataset[, vmr_mpagominimo := vm_mpagominimo / vm_mlimitecompra]

  # Aqui debe usted agregar sus propias nuevas variables
    #Problema #03 - GRUPO B // Variables Iván
    # Corrida solo con las variables que entraron en el ranking top 30 de ganancias de todas las semillas. 

  #1)-------------------------------------------------------------
  # Sumo todas las cantidades de transacciones y las rankeo. 

  dataset[, cX1_Suma_cantytrans := ctarjeta_debito_transacciones + ctarjeta_visa_transacciones + ctarjeta_master_transacciones
  + cpayroll2_trx + ccuenta_debitos_automaticos + cforex + cforex_buy + cforex_sell + ccallcenter_transacciones
  + chomebanking_transacciones + ccajas_transacciones + ccajas_otras + catm_trx + catm_trx_other + ctrx_quarter + cmobile_app_trx]

  dataset[, cX1_Suma_cantytrans_decil := frankv(X1_Suma_cantytrans, ties.method = "dense", na.last = "keep"), by=foto_mes]

  #5)-------------------------------------------------------------
  # Hago un rankeo de las variables de montos y saldos totales: 
  
  dataset[, X5_mpasivos_margen_decil := frankv(mpasivos_margen, ties.method = "dense", na.last = "keep"), by=foto_mes]
  dataset[, X5_mcaja_ahorro_decil := frankv(mcaja_ahorro, ties.method = "dense", na.last = "keep"), by=foto_mes]
  dataset[, X5_mcuentas_saldo_decil := frankv(mcuentas_saldo, ties.method = "dense", na.last = "keep"), by=foto_mes]
  dataset[, X5_mtarjeta_visa_consumo_decil := frankv(mtarjeta_visa_consumo, ties.method = "dense", na.last = "keep"), by=foto_mes]
  dataset[, X5_mprestamos_personales_decil := frankv(mprestamos_personales, ties.method = "dense", na.last = "keep"), by=foto_mes]
  dataset[, X5_mpayroll_decil := frankv(mpayroll, ties.method = "dense", na.last = "keep"), by=foto_mes]
  dataset[, X5_mcomisiones_mantenimiento_decil := frankv(mcomisiones_mantenimiento, ties.method = "dense", na.last = "keep"), by=foto_mes]


  #6)-------------------------------------------------------------
  # Aplico logaritmos a las variables monetarias

  dataset[, X6_Log2_mrentabilidad_annual := ifelse(mrentabilidad_annual > 1, log2(mrentabilidad_annual), mrentabilidad_annual)]
  dataset[, X6_Log2_mcuenta_corriente_adicional := ifelse(mcuenta_corriente_adicional > 1, log2(mcuenta_corriente_adicional), mcuenta_corriente_adicional)]
  dataset[, X6_Log2_mcaja_ahorro := ifelse(mcaja_ahorro > 1, log2(mcaja_ahorro), mcaja_ahorro)]
  dataset[, X6_Log2_mcuentas_saldo := ifelse(mcuentas_saldo > 1, log2(mcuentas_saldo), mcuentas_saldo)]
  dataset[, X6_Log2_mtarjeta_visa_consumo := ifelse(mtarjeta_visa_consumo > 1, log2(mtarjeta_visa_consumo), mtarjeta_visa_consumo)]
  dataset[, X6_Log2_mprestamos_personales := ifelse(mprestamos_personales > 1, log2(mprestamos_personales), mprestamos_personales)]
  dataset[, X6_Log2_mcomisiones_mantenimiento := ifelse(mcomisiones_mantenimiento > 1, log2(mcomisiones_mantenimiento), mcomisiones_mantenimiento)]

  #7)-------------------------------------------------------------
  # Estandarizo las variables monetarias

  # Calculo la media y la desviación estándar de cada variable monetaria por Mes

  dataset[, Media_mprestamos_personales := mean(mprestamos_personales, na.rm = TRUE), by = foto_mes]

  dataset[, SD_mprestamos_personales := sd(mprestamos_personales, na.rm = TRUE), by = foto_mes]

  # Normalizo las Variables por Mes utilizando la media y desviación estándar

  dataset[, X7_mprestamos_personales_normalizada := ifelse(any(is.na(c(mprestamos_personales, Media_mprestamos_personales, SD_mprestamos_personales))), 0, (mprestamos_personales - Media_mprestamos_personales) / SD_mprestamos_personales)]

  #8)-------------------------------------------------------------
  # Normalizo las variables monetarias



  cat("LLego bien!")









  # valvula de seguridad para evitar valores infinitos
  # paso los infinitos a NULOS
  infinitos <- lapply(
    names(dataset),
    function(.name) dataset[, sum(is.infinite(get(.name)))]
  )

  infinitos_qty <- sum(unlist(infinitos))
  if (infinitos_qty > 0) {
    cat(
      "ATENCION, hay", infinitos_qty,
      "valores infinitos en tu dataset. Seran pasados a NA\n"
    )
    dataset[mapply(is.infinite, dataset)] <<- NA
  }


  # valvula de seguridad para evitar valores NaN  que es 0/0
  # paso los NaN a 0 , decision polemica si las hay
  # se invita a asignar un valor razonable segun la semantica del campo creado
  nans <- lapply(
    names(dataset),
    function(.name) dataset[, sum(is.nan(get(.name)))]
  )

  nans_qty <- sum(unlist(nans))
  if (nans_qty > 0) {
    cat(
      "ATENCION, hay", nans_qty,
      "valores NaN 0/0 en tu dataset. Seran pasados arbitrariamente a 0\n"
    )

    cat("Si no te gusta la decision, modifica a gusto el programa!\n\n")
    dataset[mapply(is.nan, dataset)] <<- 0
  }
}
#------------------------------------------------------------------------------
# Ajusta por USD

drift_deflacion <- function(campos_monetarios) {
  vfoto_mes <- c(
    201901, 201902, 201903, 201904, 201905, 201906,
    201907, 201908, 201909, 201910, 201911, 201912,
    202001, 202002, 202003, 202004, 202005, 202006,
    202007, 202008, 202009, 202010, 202011, 202012,
    202101, 202102, 202103, 202104, 202105, 202106,
    202107, 202108, 202109
  )

  vIPC <- c(
    0.0266556605, 0.0259694459, 0.0240922637,
    0.0230206129, 0.0222933370, 0.0228440891,
    0.0235304859, 0.0189786993, 0.0158197811,
    0.0144917371, 0.0137751166, 0.0138012092,
    0.0126599337, 0.0122712367, 0.0116463855,
    0.0099376245, 0.0088380274, 0.0093657513,
    0.0089214024, 0.0080367304, 0.0079163063,
    0.0066650164, 0.0069044800, 0.0070734975,
    0.0067956942, 0.0068508532, 0.0069440278,
    0.0068297614, 0.0064089590, 0.0061971215,
    0.0059495478, 0.0058491422, 0.0056942744
  )

  tb_IPC <- data.table(
    "foto_mes" = vfoto_mes,
    "IPC" = vIPC
  )

  dataset[tb_IPC,
    on = c("foto_mes"),
    (campos_monetarios) := .SD * i.IPC,
    .SDcols = campos_monetarios
  ]
}

#------------------------------------------------------------------------------

drift_rank_simple <- function(campos_drift) {
  for (campo in campos_drift)
  {
    cat(campo, " ")
    dataset[, paste0(campo, "_rank") :=
      (frank(get(campo), ties.method = "random") - 1) / (.N - 1), by = foto_mes]
    dataset[, (campo) := NULL]
  }
}
#------------------------------------------------------------------------------
# El cero se transforma en cero
# los positivos se rankean por su lado
# los negativos se rankean por su lado

drift_rank_cero_fijo <- function(campos_drift) {
  for (campo in campos_drift)
  {
    cat(campo, " ")
    dataset[get(campo) == 0, paste0(campo, "_rank") := 0]
    dataset[get(campo) > 0, paste0(campo, "_rank") :=
      frank(get(campo), ties.method = "random") / .N, by = foto_mes]

    dataset[get(campo) < 0, paste0(campo, "_rank") :=
      -frank(-get(campo), ties.method = "random") / .N, by = foto_mes]
    dataset[, (campo) := NULL]
  }
}
#------------------------------------------------------------------------------

drift_estandarizar <- function(campos_drift) {
  for (campo in campos_drift)
  {
    cat(campo, " ")
    dataset[, paste0(campo, "_normal") := 
      (get(campo) -mean(get(campo), na.rm=TRUE)) / sd(get(campo), na.rm=TRUE),
      by = foto_mes]

    dataset[, (campo) := NULL]
  }
}
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
# Aqui comienza el programa
OUTPUT$PARAM <- PARAM
OUTPUT$time$start <- format(Sys.time(), "%Y%m%d %H%M%S")

setwd(PARAM$home)

# cargo el dataset donde voy a entrenar
# esta en la carpeta del exp_input y siempre se llama  dataset.csv.gz
dataset_input <- paste0("./exp/", PARAM$exp_input, "/dataset.csv.gz")
dataset <- fread(dataset_input)

# creo la carpeta donde va el experimento
dir.create(paste0("./exp/", PARAM$experimento, "/"), showWarnings = FALSE)
# Establezco el Working Directory DEL EXPERIMENTO
setwd(paste0("./exp/", PARAM$experimento, "/"))

GrabarOutput()
write_yaml(PARAM, file = "parametros.yml") # escribo parametros utilizados

# primero agrego las variables manuales
if (PARAM$variables_intrames) AgregarVariables_IntraMes(dataset)

# ordeno de esta forma por el ranking
setorder(dataset, foto_mes, numero_de_cliente)

# por como armé los nombres de campos,
#  estos son los campos que expresan variables monetarias
campos_monetarios <- colnames(dataset)
campos_monetarios <- campos_monetarios[campos_monetarios %like%
  "^(m|Visa_m|Master_m|vm_m)"]

# aqui aplico un metodo para atacar el data drifting
# hay que probar experimentalmente cual funciona mejor
switch(PARAM$metodo,
  "ninguno"        = cat("No hay correccion del data drifting"),
  "rank_simple"    = drift_rank_simple(campos_monetarios),
  "rank_cero_fijo" = drift_rank_cero_fijo(campos_monetarios),
  "deflacion"      = drift_deflacion(campos_monetarios),
  "estandarizar"   = drift_estandarizar(campos_monetarios)
)



fwrite(dataset,
  file = "dataset.csv.gz",
  logical01 = TRUE,
  sep = ","
)

#------------------------------------------------------------------------------

# guardo los campos que tiene el dataset
tb_campos <- as.data.table(list(
  "pos" = 1:ncol(dataset),
  "campo" = names(sapply(dataset, class)),
  "tipo" = sapply(dataset, class),
  "nulos" = sapply(dataset, function(x) {
    sum(is.na(x))
  }),
  "ceros" = sapply(dataset, function(x) {
    sum(x == 0, na.rm = TRUE)
  })
))

fwrite(tb_campos,
  file = "dataset.campos.txt",
  sep = "\t"
)

#------------------------------------------------------------------------------
OUTPUT$dataset$ncol <- ncol(dataset)
OUTPUT$dataset$nrow <- nrow(dataset)
OUTPUT$time$end <- format(Sys.time(), "%Y%m%d %H%M%S")
GrabarOutput()

# dejo la marca final
cat(format(Sys.time(), "%Y%m%d %H%M%S"), "\n",
  file = "zRend.txt",
  append = TRUE
)
print("Done!!")