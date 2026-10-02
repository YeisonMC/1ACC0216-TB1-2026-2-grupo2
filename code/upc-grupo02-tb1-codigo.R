# ============================================================
# FUNDAMENTOS DE DATA SCIENCE
# TB1 - Grupo 2
# ============================================================

# ============================================================
# 1. PREPARACION DEL ENTORNO
# ============================================================

rm(list = ls(all = TRUE))
cat("\014")
graphics.off()

# Instalar:
# install.packages("tidyverse", dependencies = TRUE)
# install.packages("lubridate", dependencies = TRUE)

library(tidyverse)
library(lubridate)

# Crear carpeta de salida para los graficos si no existe
dir.create(
  "output/graficos",
  showWarnings = FALSE,
  recursive = TRUE
)

# Ruta del archivo original
archivo_datos <- "data/hotel_bookings.csv"

# ============================================================
# 2. INSPECCION Y COMPRENSION DEL DATASET
# ============================================================

# ------------------------------------------------------------
# 2.1 Carga del dataset
# ------------------------------------------------------------

hotel <- read.table(
  archivo_datos,
  header = TRUE,
  sep = ",",
  dec = ".",
  na.strings = c("NA", "NULL"),
  stringsAsFactors = FALSE
)


# ------------------------------------------------------------
# 2.2 Dimensiones, variables y estructura inicial
# ------------------------------------------------------------

dimensiones <- tibble(
  registros = nrow(hotel),
  variables = ncol(hotel)
)

dimensiones
head(hotel,2)
names(hotel)
str(hotel)
dim(hotel)
nrow(hotel)
ncol(hotel)
length(names(hotel))

# ------------------------------------------------------------
# 2.3 Muestra de registros
# ------------------------------------------------------------

muestra_registros <- hotel |>
  select(
    hotel,
    is_canceled,
    lead_time,
    arrival_date_year,
    arrival_date_month,
    stays_in_weekend_nights,
    stays_in_week_nights,
    adults,
    children,
    babies,
    adr
  ) |>
  head(6)

muestra_registros


# ------------------------------------------------------------
# 2.4 Tipos de datos detectados por R
# ------------------------------------------------------------

tipos_datos <- sapply(hotel, class)
tipos_datos


# ------------------------------------------------------------
# 2.5 Variables que requieren revision de tipo
# ------------------------------------------------------------

tipos_a_revisar <- sapply(
  hotel[
    c(
      "reservation_status_date",
      "arrival_date_month",
      "hotel",
      "is_canceled",
      "is_repeated_guest",
      "agent",
      "company"
    )
  ],
  class
)

tipos_a_revisar


# ============================================================
# 3. CALIDAD, ANALISIS EXPLORATORIO Y VISUALIZACIONES
# ============================================================


# ============================================================
# 3.1 CALIDAD DE LOS DATOS
# ============================================================

# ------------------------------------------------------------
# 3.1.1 Completitud
# ------------------------------------------------------------

tabla_faltantes <- hotel |>
  summarise(
    across(
      everything(),
      ~ sum(is.na(.))
    )
  ) |>
  pivot_longer(
    cols = everything(),
    names_to = "Variable",
    values_to = "Faltantes"
  ) |>
  mutate(
    Porcentaje = round(
      Faltantes / nrow(hotel) * 100,
      2
    )
  ) |>
  filter(Faltantes > 0) |>
  arrange(desc(Faltantes))

tabla_faltantes


# ------------------------------------------------------------
# 3.1.2 Unicidad
# ------------------------------------------------------------

duplicados <- sum(duplicated(hotel))
duplicados


# ------------------------------------------------------------
# 3.1.3 Consistencia
# ------------------------------------------------------------

unique(hotel$hotel)
unique(hotel$meal)
unique(hotel$market_segment)
unique(hotel$distribution_channel)
unique(hotel$customer_type)
unique(hotel$reservation_status)

tabla_consistencia <- table(
  hotel$is_canceled,
  hotel$reservation_status
)

tabla_consistencia


# ------------------------------------------------------------
# 3.1.4 Validez
# ------------------------------------------------------------

resumen_validez <- tibble(
  indicador = c(
    "ADR negativo",
    "Reservas sin huéspedes",
    "ADR mínimo",
    "ADR máximo"
  ),
  valor = c(
    sum(hotel$adr < 0, na.rm = TRUE),
    sum(
      hotel$adults +
        replace_na(hotel$children, 0) +
        hotel$babies == 0
    ),
    min(hotel$adr, na.rm = TRUE),
    max(hotel$adr, na.rm = TRUE)
  )
)

resumen_validez

unique(hotel$is_canceled)
unique(hotel$is_repeated_guest)


# ------------------------------------------------------------
# 3.1.5 Exactitud
# ------------------------------------------------------------

# ============================================================
# 3.2 PREPARACION Y TRANSFORMACION DE LOS DATOS
# ============================================================

hotel_limpio <- hotel |>
  
  # Eliminar filas exactamente duplicadas
  distinct() |>
  
  # Excluir reservas sin huéspedes
  filter(
    adults +
      replace_na(children, 0) +
      babies > 0
  ) |>
  
  mutate(
    # Convertir fecha de estado de reserva
    reservation_status_date = as.Date(
      reservation_status_date
    ),
    
    # Crear fecha de llegada
    arrival_month_num = match(
      arrival_date_month,
      month.name
    ),
    
    arrival_date = make_date(
      arrival_date_year,
      arrival_month_num,
      arrival_date_day_of_month
    ),
    
    # Crear periodo mensual para el análisis temporal
    periodo = floor_date(
      arrival_date,
      unit = "month"
    ),
    
    # Duración total de la estancia
    total_nights =
      stays_in_weekend_nights +
      stays_in_week_nights,
    
    # Identificar reservas con niños o bebés
    con_menores = case_when(
      children > 0 | babies > 0 ~ "Con niños/bebés",
      children == 0 & babies == 0 ~ "Sin niños/bebés",
      TRUE ~ NA_character_
    ),
    
    # Conversión de variables categóricas
    hotel = factor(hotel),
    
    arrival_date_month = factor(
      arrival_date_month,
      levels = month.name,
      ordered = TRUE
    ),
    
    is_canceled = factor(
      is_canceled,
      levels = c(0, 1),
      labels = c("No", "Sí")
    ),
    
    is_repeated_guest = factor(
      is_repeated_guest,
      levels = c(0, 1),
      labels = c("No", "Sí")
    ),
    
    meal = factor(meal),
    country = factor(country),
    market_segment = factor(market_segment),
    distribution_channel = factor(distribution_channel),
    reserved_room_type = factor(reserved_room_type),
    assigned_room_type = factor(assigned_room_type),
    deposit_type = factor(deposit_type),
    agent = factor(agent),
    company = factor(company),
    customer_type = factor(customer_type),
    reservation_status = factor(reservation_status),
    
    con_menores = factor(
      con_menores,
      levels = c(
        "Sin niños/bebés",
        "Con niños/bebés"
      )
    )
  )


# ------------------------------------------------------------
# 3.2.1 Verificación del dataset preparado
# ------------------------------------------------------------

dim(hotel)
dim(hotel_limpio)
glimpse(hotel_limpio)


# ------------------------------------------------------------
# 3.2.2 Guardar dataset preparado
# ------------------------------------------------------------

write.csv(
  hotel_limpio,
  "data/hotel_bookings_preparado.csv",
  row.names = FALSE
)


# ============================================================
# 3.3 ANALISIS UNIVARIADO Y VALORES ATIPICOS
# ============================================================


# ------------------------------------------------------------
# 3.3.1 Duracion de la estancia
# ------------------------------------------------------------

resumen_duracion <- hotel_limpio |>
  summarise(
    media = round(
      mean(total_nights),
      2
    ),
    mediana = median(total_nights),
    Q1 = quantile(
      total_nights,
      0.25
    ),
    Q3 = quantile(
      total_nights,
      0.75
    ),
    minimo = min(total_nights),
    maximo = max(total_nights),
    desviacion = round(
      sd(total_nights),
      2
    )
  )

resumen_duracion

porcentaje_hasta_5 <- round(
  mean(
    hotel_limpio$total_nights <= 5
  ) * 100,
  1
)

porcentaje_hasta_5


# Figura 5: distribucion de la duracion de estancia

grafico_duracion <- ggplot(
  hotel_limpio,
  aes(x = total_nights)
) +
  geom_histogram(
    binwidth = 1,
    boundary = 0,
    fill = "#4E79A7",
    color = "white"
  ) +
  scale_x_continuous(
    breaks = seq(
      0,
      max(
        hotel_limpio$total_nights,
        na.rm = TRUE
      ),
      5
    )
  ) +
  scale_y_continuous(
    labels = scales::comma
  ) +
  labs(
    title = "El 82.1 % de las reservas presenta estancias de hasta 5 noches",
    x = "Número total de noches",
    y = "Cantidad de reservas"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(
      face = "bold"
    ),
    axis.title = element_text(
      face = "bold"
    )
  )

grafico_duracion

ggsave(
  filename = "output/graficos/figura5_duracion_estancias.png",
  plot = grafico_duracion,
  width = 8,
  height = 5,
  units = "in",
  dpi = 300
)


# ------------------------------------------------------------
# 3.3.2 Reservas con niños o bebes
# ------------------------------------------------------------

tabla_menores <- hotel_limpio |>
  filter(
    !is.na(con_menores)
  ) |>
  count(
    con_menores,
    name = "reservas"
  ) |>
  mutate(
    proporcion = reservas / sum(reservas),
    porcentaje = round(
      proporcion * 100,
      1
    )
  )

tabla_menores


# Figura 6: reservas con y sin menores

grafico_menores <- ggplot(
  tabla_menores,
  aes(
    x = con_menores,
    y = proporcion,
    fill = con_menores
  )
) +
  geom_col(
    width = 0.6,
    show.legend = FALSE
  ) +
  geom_text(
    aes(
      label = scales::percent(
        proporcion,
        accuracy = 0.1
      )
    ),
    vjust = -0.4,
    size = 4
  ) +
  scale_fill_manual(
    values = c(
      "Sin niños/bebés" = "#F8766D",
      "Con niños/bebés" = "#00BFC4"
    )
  ) +
  scale_y_continuous(
    labels = scales::percent_format(
      accuracy = 1
    ),
    limits = c(0, 1)
  ) +
  labs(
    title = "Solo el 10.4 % de las reservas incluye niños o bebés",
    x = NULL,
    y = "Porcentaje de reservas"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(
      face = "bold"
    ),
    axis.title = element_text(
      face = "bold"
    )
  )

grafico_menores

ggsave(
  filename = "output/graficos/figura6_reservas_menores.png",
  plot = grafico_menores,
  width = 8,
  height = 5,
  units = "in",
  dpi = 300
)


# ------------------------------------------------------------
# 3.3.3 Deteccion de posibles valores atipicos
# ------------------------------------------------------------

detectar_atipicos <- function(x) {
  
  q1 <- quantile(
    x,
    0.25,
    na.rm = TRUE
  )
  
  q3 <- quantile(
    x,
    0.75,
    na.rm = TRUE
  )
  
  iqr <- q3 - q1
  
  limite_inferior <- q1 - 1.5 * iqr
  limite_superior <- q3 + 1.5 * iqr
  
  sum(
    x < limite_inferior |
      x > limite_superior,
    na.rm = TRUE
  )
}


tabla_atipicos <- tibble(
  Variable = c(
    "Anticipación de la reserva",
    "Noches totales",
    "Tarifa diaria promedio"
  ),
  
  Posibles_atipicos = c(
    detectar_atipicos(
      hotel_limpio$lead_time
    ),
    detectar_atipicos(
      hotel_limpio$total_nights
    ),
    detectar_atipicos(
      hotel_limpio$adr
    )
  ),
  
  Minimo = c(
    min(
      hotel_limpio$lead_time,
      na.rm = TRUE
    ),
    min(
      hotel_limpio$total_nights,
      na.rm = TRUE
    ),
    min(
      hotel_limpio$adr,
      na.rm = TRUE
    )
  ),
  
  Maximo = c(
    max(
      hotel_limpio$lead_time,
      na.rm = TRUE
    ),
    max(
      hotel_limpio$total_nights,
      na.rm = TRUE
    ),
    max(
      hotel_limpio$adr,
      na.rm = TRUE
    )
  )
)

tabla_atipicos


# Figura 7: anticipacion de la reserva

grafico_lead_time <- ggplot(
  hotel_limpio,
  aes(
    x = "",
    y = lead_time
  )
) +
  geom_boxplot(
    fill = "#A0CBE8",
    outlier.alpha = 0.3
  ) +
  labs(
    title = "Valores extremos en la anticipación de la reserva",
    x = NULL,
    y = "Días de anticipación"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(
      face = "bold"
    ),
    axis.text.x = element_blank(),
    axis.ticks.x = element_blank(),
    axis.title = element_text(
      face = "bold"
    )
  )

grafico_lead_time

ggsave(
  filename = "output/graficos/figura7_anticipacion_reserva.png",
  plot = grafico_lead_time,
  width = 7,
  height = 5,
  units = "in",
  dpi = 300
)


# Figura 8: noches totales

grafico_total_nights <- ggplot(
  hotel_limpio,
  aes(
    x = "",
    y = total_nights
  )
) +
  geom_boxplot(
    fill = "#A0CBE8",
    outlier.alpha = 0.3
  ) +
  labs(
    title = "Valores extremos en la duración de la estancia",
    x = NULL,
    y = "Número total de noches"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(
      face = "bold"
    ),
    axis.text.x = element_blank(),
    axis.ticks.x = element_blank(),
    axis.title = element_text(
      face = "bold"
    )
  )

grafico_total_nights

ggsave(
  filename = "output/graficos/figura8_noches_totales.png",
  plot = grafico_total_nights,
  width = 7,
  height = 5,
  units = "in",
  dpi = 300
)


# Figura 9: tarifa diaria promedio

grafico_adr <- ggplot(
  hotel_limpio,
  aes(
    x = "",
    y = adr
  )
) +
  geom_boxplot(
    fill = "#A0CBE8",
    outlier.alpha = 0.3
  ) +
  labs(
    title = "Valores extremos en la tarifa diaria promedio",
    x = NULL,
    y = "Tarifa diaria promedio"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(
      face = "bold"
    ),
    axis.text.x = element_blank(),
    axis.ticks.x = element_blank(),
    axis.title = element_text(
      face = "bold"
    )
  )

grafico_adr

ggsave(
  filename = "output/graficos/figura9_tarifa_diaria.png",
  plot = grafico_adr,
  width = 7,
  height = 5,
  units = "in",
  dpi = 300
)


# ============================================================
# 3.4 ANALISIS BIVARIADO Y MULTIVARIADO
# ============================================================


# ------------------------------------------------------------
# 3.4.1 Duracion de estancia segun tipo de hotel
# ------------------------------------------------------------

resumen_estancia_hotel <- hotel_limpio |>
  group_by(hotel) |>
  summarise(
    reservas = n(),
    media_noches = round(
      mean(total_nights),
      2
    ),
    mediana_noches = median(
      total_nights
    ),
    Q1 = quantile(
      total_nights,
      0.25
    ),
    Q3 = quantile(
      total_nights,
      0.75
    ),
    minimo = min(total_nights),
    maximo = max(total_nights),
    .groups = "drop"
  )

resumen_estancia_hotel


# Figura 10: duración de estancia por tipo de hotel

grafico_estancia_hotel <- ggplot(
  hotel_limpio,
  aes(
    x = hotel,
    y = total_nights,
    fill = hotel
  )
) +
  geom_boxplot(
    width = 0.55,
    outlier.alpha = 0.25,
    show.legend = FALSE
  ) +
  scale_fill_manual(
    values = c(
      "City Hotel" = "#F8766D",
      "Resort Hotel" = "#00BFC4"
    )
  ) +
  labs(
    title = "Resort Hotel registra estancias más prolongadas que City Hotel",
    x = NULL,
    y = "Número total de noches"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(
      face = "bold"
    ),
    axis.title = element_text(
      face = "bold"
    )
  )

grafico_estancia_hotel

ggsave(
  filename = "output/graficos/figura10_estancia_tipo_hotel.png",
  plot = grafico_estancia_hotel,
  width = 8,
  height = 5,
  units = "in",
  dpi = 300
)


# ------------------------------------------------------------
# 3.4.2 Cancelaciones segun hotel y presencia de menores
# ------------------------------------------------------------

resumen_cancelacion <- hotel_limpio |>
  filter(
    !is.na(con_menores)
  ) |>
  mutate(
    con_menores = factor(
      con_menores,
      levels = c(
        "Con niños/bebés",
        "Sin niños/bebés"
      )
    )
  ) |>
  group_by(
    hotel,
    con_menores
  ) |>
  summarise(
    reservas = n(),
    canceladas = sum(
      is_canceled == "Sí"
    ),
    tasa_cancelacion =
      canceladas / reservas,
    .groups = "drop"
  )

resumen_cancelacion


# Figura 11: cancelaciones segun hotel y presencia de menores

grafico_cancelacion_menores <- ggplot(
  resumen_cancelacion,
  aes(
    x = hotel,
    y = tasa_cancelacion,
    fill = con_menores
  )
) +
  geom_col(
    position = position_dodge(
      width = 0.75
    ),
    width = 0.65
  ) +
  geom_text(
    aes(
      label = scales::percent(
        tasa_cancelacion,
        accuracy = 0.1
      )
    ),
    position = position_dodge(
      width = 0.75
    ),
    vjust = -0.4,
    size = 3.8
  ) +
  scale_fill_manual(
    values = c(
      "Con niños/bebés" = "#F8766D",
      "Sin niños/bebés" = "#00BFC4"
    )
  ) +
  scale_y_continuous(
    labels = scales::percent_format(
      accuracy = 1
    ),
    limits = c(0, 0.40)
  ) +
  labs(
    title = "Las reservas con menores registran una mayor tasa de cancelación en ambos hoteles",
    x = "Tipo de hotel",
    y = "Porcentaje de reservas canceladas",
    fill = "Composición de la reserva"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(
      face = "bold"
    ),
    axis.title = element_text(
      face = "bold"
    )
  )

grafico_cancelacion_menores

ggsave(
  filename = "output/graficos/figura11_cancelacion_menores_hotel.png",
  plot = grafico_cancelacion_menores,
  width = 9,
  height = 5,
  units = "in",
  dpi = 300
)


# ------------------------------------------------------------
# 3.4.3 Perfil de las reservas con niños o bebes
# ------------------------------------------------------------

reservas_menores <- hotel_limpio |>
  filter(
    con_menores == "Con niños/bebés"
  )


perfil_menores <- reservas_menores |>
  summarise(
    reservas = n(),
    
    media_noches = round(
      mean(total_nights),
      2
    ),
    
    mediana_noches = median(
      total_nights
    ),
    
    media_adultos = round(
      mean(adults),
      2
    ),
    
    porcentaje_transient = round(
      mean(
        customer_type == "Transient"
      ) * 100,
      2
    ),
    
    porcentaje_canceladas = round(
      mean(
        is_canceled == "Sí"
      ) * 100,
      2
    )
  )

perfil_menores


hotel_menores <- reservas_menores |>
  count(
    hotel,
    name = "reservas"
  ) |>
  mutate(
    porcentaje = round(
      reservas / sum(reservas) * 100,
      2
    )
  )

hotel_menores


# ============================================================
# 3.5 ANALISIS TEMPORAL
# ============================================================


# ------------------------------------------------------------
# 3.5.1 Reservas mensuales por tipo de hotel
# ------------------------------------------------------------

reservas_mes <- hotel_limpio |>
  count(
    periodo,
    hotel,
    name = "reservas"
  )

reservas_mes


# ------------------------------------------------------------
# 3.5.2 Mes con mayor cantidad de reservas por hotel
# ------------------------------------------------------------

resumen_temporal <- reservas_mes |>
  group_by(hotel) |>
  summarise(
    mes_maximo =
      periodo[which.max(reservas)],
    max_reservas =
      max(reservas),
    .groups = "drop"
  )

resumen_temporal


# ------------------------------------------------------------
# 3.5.3 Comparacion mensual entre ambos hoteles
# ------------------------------------------------------------

comparacion_mensual <- reservas_mes |>
  pivot_wider(
    names_from = hotel,
    values_from = reservas
  ) |>
  summarise(
    meses_observados = n(),
    meses_city_superior = sum(
      `City Hotel` >
        `Resort Hotel`
    )
  )

comparacion_mensual


# ------------------------------------------------------------
# 3.5.4 Picos de reservas
# ------------------------------------------------------------

picos_reservas <- reservas_mes |>
  group_by(hotel) |>
  slice_max(
    reservas,
    n = 1,
    with_ties = FALSE
  ) |>
  ungroup()

picos_reservas


# Figura 12: evolucion mensual de reservas

titulo_temporal <- sprintf(
  "City Hotel registra más reservas en %d de los %d meses observados",
  comparacion_mensual$meses_city_superior,
  comparacion_mensual$meses_observados
)

grafico_temporal <- ggplot(
  reservas_mes,
  aes(
    x = periodo,
    y = reservas,
    color = hotel,
    linetype = hotel
  )
) +
  geom_line(
    linewidth = 1
  ) +
  geom_point(
    size = 2
  ) +
  geom_text(
    data = picos_reservas,
    aes(
      label = reservas
    ),
    vjust = -0.8,
    show.legend = FALSE
  ) +
  scale_color_manual(
    values = c(
      "City Hotel" = "#F8766D",
      "Resort Hotel" = "#00BFC4"
    )
  ) +
  scale_x_date(
    date_breaks = "3 months",
    date_labels = "%b-%Y"
  ) +
  scale_y_continuous(
    labels = scales::comma,
    expand = expansion(
      mult = c(0, 0.08)
    )
  ) +
  labs(
    title = titulo_temporal,
    x = "Mes de llegada",
    y = "Cantidad de reservas",
    color = "Tipo de hotel",
    linetype = "Tipo de hotel"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(
      face = "bold"
    ),
    axis.title = element_text(
      face = "bold"
    ),
    axis.text.x = element_text(
      angle = 45,
      hjust = 1
    )
  )

grafico_temporal

ggsave(
  filename = "output/graficos/figura12_evolucion_reservas.png",
  plot = grafico_temporal,
  width = 9,
  height = 5,
  units = "in",
  dpi = 300
)


# ============================================================
# 3.6 RESPUESTA A LAS PREGUNTAS ANALITICAS
# ============================================================

# Pregunta analiica 1:
# Duracion de estancia segun tipo de hotel
resumen_estancia_hotel

# Pregunta analitica 2:
# Caracteristicas de las reservas con niños o bebes
perfil_menores
hotel_menores
resumen_cancelacion

