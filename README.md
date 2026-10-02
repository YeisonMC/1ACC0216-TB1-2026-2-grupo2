# TB1: Análisis EDA - Hotel Booking Demand

Trabajo académico desarrollado para el curso **Fundamentos de Data Science**.  
El proyecto realiza un análisis exploratorio de datos (EDA) sobre el dataset **Hotel Booking Demand**, con énfasis en la duración de las estancias y en las características de las reservas que incluyen niños y/o bebés.

## Integrantes

| N.° | Integrante                       |
| --: | -------------------------------- |
|   1 | Chavez Pino, Paula Brenda        |
|   2 | Macalupu Marchan, Yeissen Beckam |
|   3 | Quispe Valdez, Elim Zabdi        |
|   4 | Cárdenas Cabrera, Ángel David    |

**Grupo:** 2

## Objetivo del trabajo

Realizar un análisis exploratorio del dataset **Hotel Booking Demand** mediante R/RStudio, evaluando la calidad de los datos, preparando una versión adecuada para el análisis, estudiando distribuciones y valores atípicos, explorando relaciones entre variables y comunicando los principales hallazgos mediante tablas, medidas descriptivas y visualizaciones.

El análisis se orienta especialmente a responder las siguientes preguntas:

1. **¿Cómo se distribuye y compara la duración total de la estancia entre las reservas de City Hotel y Resort Hotel?**
2. **¿Qué características presentan las reservas con niños y/o bebés en relación con el tipo de hotel, duración de estancia, cantidad de adultos, tipo de cliente y cancelación?**

## Descripción del dataset

El archivo original `hotel_bookings.csv` contiene información sobre reservas realizadas en dos tipos de alojamiento:

- **City Hotel**
- **Resort Hotel**

El dataset original contiene **119 390 registros y 32 variables**. Entre las variables disponibles se encuentran información sobre cancelaciones, fechas de llegada, anticipación de la reserva, duración de la estancia, cantidad de huéspedes, segmentos de mercado, tipo de cliente, tarifa diaria promedio (`adr`) y estado final de la reserva.

Durante la preparación se conservaron los datos originales sin modificaciones y se creó `hotel_bookings_preparado.csv`, con **87 230 registros y 37 variables**, incorporando variables auxiliares como la fecha de llegada, el periodo mensual, el total de noches y la presencia de niños o bebés.

## Metodología

El desarrollo del trabajo siguió las siguientes etapas:

1. **Inspección y comprensión del dataset**
   - Dimensiones y estructura.
   - Tipos de variables.
   - Muestra de registros.
   - Identificación de conversiones necesarias.

2. **Evaluación de la calidad de los datos**
   - Completitud.
   - Unicidad.
   - Consistencia.
   - Validez.
   - Exactitud, cuando fue posible verificarla.

3. **Preparación de los datos**
   - Eliminación de registros exactamente duplicados.
   - Exclusión de reservas sin huéspedes.
   - Conversión de variables categóricas y temporales.
   - Creación de variables auxiliares para el análisis.

4. **Análisis exploratorio**
   - Análisis univariado.
   - Identificación de posibles valores atípicos mediante el criterio IQR.
   - Análisis bivariado y multivariado.
   - Análisis temporal.
   - Respuesta a las preguntas analíticas del grupo.

## Principales hallazgos

- **El 82.1 % de las reservas presenta estancias de hasta 5 noches**, por lo que las estancias cortas constituyen el comportamiento más frecuente.
- **Resort Hotel registra estancias más prolongadas que City Hotel**. La duración media es de aproximadamente 4.39 noches en Resort Hotel y 3.14 noches en City Hotel.
- **Aproximadamente el 10.4 % de las reservas con información disponible incluye niños o bebés**.
- Las reservas con menores presentan una **mayor proporción de cancelaciones en ambos tipos de hotel** que las reservas sin menores. Esta relación es descriptiva y no implica causalidad.
- **City Hotel registra más reservas que Resort Hotel en 23 de los 26 meses observados**.

## Valores atípicos

Mediante el criterio del rango intercuartílico (IQR) se identificaron posibles valores atípicos en variables cuantitativas relevantes:

| Variable                                 | Posibles valores atípicos | Mínimo | Máximo |
| ---------------------------------------- | ------------------------: | -----: | -----: |
| Anticipación de la reserva (`lead_time`) |                     2 394 |      0 |    737 |
| Noches totales (`total_nights`)          |                     2 991 |      0 |     69 |
| Tarifa diaria promedio (`adr`)           |                     2 508 |  -6.38 |   5400 |

Los valores atípicos no fueron eliminados automáticamente, ya que pueden representar observaciones reales. El valor negativo de `adr` fue identificado como un caso de validez que requiere revisión.

## Conclusiones

- Las reservas hoteleras se concentran principalmente en estancias cortas.
- Resort Hotel presenta estancias promedio y medianas superiores a las observadas en City Hotel.
- Las reservas con niños o bebés representan aproximadamente una décima parte de los registros con información disponible sobre esta característica y se caracterizan por una estancia cercana a cuatro noches y aproximadamente dos adultos por reserva.
- Las reservas con menores presentan una mayor proporción de cancelaciones en ambos hoteles; este resultado corresponde a una asociación descriptiva y no implica causalidad.
- City Hotel concentra una mayor cantidad de reservas durante la mayoría de los meses observados.

## Estructura del repositorio

```text
1ACC0216-TB1-2026-2-grupo2/
│
├── README.md
├── LICENSE
│
├── data/
│   ├── hotel_bookings.csv
│   └── hotel_bookings_preparado.csv
│
├── code/
│   └── upc-grupo02-tb1-codigo.R
│
├── output/
│   └── graficos/
│       ├── figura5_duracion_estancias.png
│       ├── figura6_reservas_menores.png
│       ├── figura7_anticipacion_reserva.png
│       ├── figura8_noches_totales.png
│       ├── figura9_tarifa_diaria.png
│       ├── figura10_estancia_tipo_hotel.png
│       ├── figura11_cancelacion_menores_hotel.png
│       └── figura12_evolucion_reservas.png
│
└── report/
    ├── upc-grupo02-tb1-informe.Rmd
    └── upc-grupo02-tb1-informe.html
```

## Archivos principales

- [`code/upc-grupo02-tb1-codigo.R`](code/upc-grupo02-tb1-codigo.R): código completo utilizado para la preparación, análisis y generación de gráficos.
- [`report/upc-grupo02-tb1-informe.Rmd`](report/upc-grupo02-tb1-informe.Rmd): informe reproducible desarrollado en R Markdown.
- [`report/upc-grupo02-tb1-informe.html`](report/upc-grupo02-tb1-informe.html): versión HTML generada mediante Knit.
- [`output/graficos/`](output/graficos/): visualizaciones generadas durante el análisis.

## Reproducción del análisis

Para reproducir el trabajo:

1. Clonar o descargar este repositorio.
2. Abrir el proyecto desde la carpeta raíz `1ACC0216-TB1-2026-2-grupo2`.
3. Verificar que R tenga instalados los paquetes utilizados:

```r
install.packages(c(
  "tidyverse",
  "lubridate",
  "scales",
  "knitr",
  "rmarkdown"
))
```

4. Ejecutar el archivo:

```text
code/upc-grupo02-tb1-codigo.R
```

5. Para generar nuevamente el informe HTML, abrir:

```text
report/upc-grupo02-tb1-informe.Rmd
```

## Tecnologías utilizadas

- R
- RStudio
- R Markdown
- tidyverse
- dplyr
- ggplot2
- lubridate
- knitr

## Licencia

El **código y la documentación desarrollados por el equipo** se distribuyen bajo la **MIT License**. Verifique el archivo [`LICENSE`](LICENSE) para conocer los términos.

## Referencias

- Datos.gob.es. (2021). _Guía práctica de introducción al análisis exploratorio de datos en R_. Gobierno de España.
- Posit Software, PBC. (2024). _Transformación de datos con dplyr: guía rápida_ [Hoja de referencia].
- Posit Software, PBC. (2024). _Visualización de datos con ggplot2: guía rápida_ [Hoja de referencia].
- Wickham, H., & Grolemund, G. (2023). _R para ciencia de datos_ [Versión en español].
