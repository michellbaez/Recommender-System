# Bitácora de uso de IA — Proyecto 4

> **Borrador.** Lo preparó la IA a partir de la conversación de trabajo. El
> equipo debe revisarlo, completarlo con sus propias palabras y agregar las
> entradas de las imágenes que genere con otras herramientas.

## Herramienta principal

- **Claude (Anthropic)**, usado como mentor y programador en una sola
  conversación de trabajo, del 18 al 23 de noviembre de 2026.
- **Regla de trabajo acordada con la IA:** la IA plantea opciones con pros y
  contras y el equipo decide; la IA escribe el código solo cuando el equipo da
  la orden.

## Registro por fase

| Fase | Prompt (resumen de lo pedido) | Qué produjo la IA | Qué se aceptó | Qué se corrigió y por qué |
|---|---|---|---|---|
| Inicio | Actuar como mentor; no tomar decisiones; explicar; avanzar fase por fase | Resumen de las fases 1 y 2 y primera decisión (tipo de join) | La forma de trabajo | — |
| Directrices | Integrar criterios de diseño de recomendadores (señales implícitas, escalabilidad, iteración) | Análisis de conflictos con el enunciado (celdas vacías, señales no disponibles, iteración) | Usarlas como criterios para plantear opciones (D0) | Se descartó tratar la celda vacía como rechazo (D9) |
| 1 | Reproducir el tutorial con el `.Rmd` del docente | Ejecución del código y detección de 7 errores (C1–C7) | Mostrar solo la versión corregida y registrar los cambios (D4) | Recomendador de contenido que recomendaba libros ya leídos; `top_n` sin columna; ítem–ítem que buscaba en filas; bloque que impedía renderizar |
| 1 | Recorte por memoria (PC de 8 GB) | Opciones de recorte con su tamaño en memoria | 1.000 libros más leídos (D5, D6); Gower con autores más comunes (D7) | — |
| 2 | Leer, unir y describir los datos de Procaps | Verificación del join; hallazgo de 306 facturas vacías y de dos sociedades | `left_join(pro2, cab)`; ambas sociedades con etiqueta y `pct_diabetrics` (D1–D2d) | — |
| 3 | Definir la preferencia y construir la matriz | Comparación de 4 definiciones con una medida de dominación | Preferencia binaria (D8); intensidad en la app (D8b); vacío = "no sabemos" (D9) | — |
| 4 | Implementar y validar el coseno | Función validada contra `lsa::cosine` y fórmula binaria | Cálculo bajo demanda (D10) | — |
| 5 | Recomendador ítem–ítem y 5 casos | Fusión de códigos duplicados; análisis farmacéutico de casos | Fusión normalizada (D11, D11b); nombre más reciente (D12); casos (D13); coseno puro (D14) | El equipo pidió registrar como limitación el riesgo de fusionar por error |
| 6 | Recomendador usuario–usuario | Función con orden y desempate; sensibilidad a k y umbral | D15, D16, D17 | La IA corrigió una explicación equivocada sobre los vecinos en el arranque en frío tras revisar los datos |
| 7 | Evaluación con partición temporal | Hit rate y precision con IC, McNemar y t pareada | D18–D22; k = 50 para la app tras comparar k = 20, 30, 40 y 50 (D23) | Error de código: el IC de la precisión se calculaba sobre un solo número (E2) |
| Prototipo | Construir la app con las decisiones D23–D28 | `exportar_app.R`, `docs/index.html`, ilustraciones SVG por forma farmacéutica, carrito | *(completar tras revisar la app)* | *(completar)* |
| App v2 | Actuar como desarrollador frontend senior y diseñador UI/UX: paleta azul y gris, más vendidos, filtros combinables, catálogo paginado, registro e inicio de sesión obligatorio para canasta y preferencias, complementos, avisos de fórmula médica y promociones, un solo archivo idéntico local y en GitHub | `fuente/plantilla.html`, `construir_app.R`, nuevo `docs/index.html` | *(completar)* | La IA advirtió que exigir cuenta agrega un paso en la sustentación; se mantuvo por decisión del equipo |

## Prompt de la aplicación (resumen)

> Construir una aplicación web en español para un comprador sin
> conocimientos técnicos, con dos vistas: buscar un producto por nombre y ver
> los más parecidos como tarjetas con imagen y explicación; y elegir un
> comprador para ver su historial (compra frecuente desde 3 facturas) junto a
> sus 10 recomendaciones de usuario–usuario con k = 50, sin productos ya
> comprados. Incluir compradores sugeridos para la demostración, una canasta
> que recalcula sugerencias con la similitud ítem–ítem, ilustraciones por
> forma farmacéutica sin marcas inventadas, y funcionar desde GitHub Pages y
> como archivo sin internet.

## Imágenes generadas con otras IA

Completar una fila por imagen (los prompts están en `prompts_imagenes.md`).

| Código | Producto | Herramienta | Prompt usado | ¿Se aceptó? | Qué se corrigió |
|---|---|---|---|---|---|
| | | | | | |
