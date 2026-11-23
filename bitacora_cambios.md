# Bitácora de cambios — Proyecto 4 (recomendador Procaps)

## Decisiones tomadas por el equipo

| # | Fase | Decisión | Elección |
|---|---|---|---|
| D0 | General | Interpretación de directrices de diseño | Criterios para plantear opciones; la decisión es del equipo |
| D1 | 2 | Tipo de join | `left_join(pro2, cab)`; unidad de análisis = línea de compra |
| D1b | 2 | 306 facturas sin detalle | Quedan fuera por el join; se documentan (mayoría WEB, 2020–2021; 3 compradores solo aparecen ahí) |
| D2 | 2 | Sociedades | PROCAPS y DIABETRICS en una sola matriz; sociedad como etiqueta del producto |
| D2b | 2 | 27 productos compartidos | Etiqueta PROCAPS / DIABETRICS / AMBAS + columna `pct_diabetrics` |
| D2c | 2 | Canal SAP/WEB | Se incluye; solo descriptivo |
| D2d | 2 | Resumen descriptivo | Verificación del join; compradores/productos/periodo (total y por sociedad); distribución de cantidad; top 10; ventas por año y canal |
| D3 | 1 | Fuente del código base | Rmd del profesor (`recbooks_1.Rmd`) |
| D4 | 1 | Tratamiento de errores del tutorial | Opción B: solo versión corregida, con comentario breve; cambios registrados aquí |
| D5 | 1 | Reemplazo de `top_n(10000)` | Libros más leídos + todos sus lectores |
| D6 | 1 | Número de libros más leídos | 1.000 libros (9.774 usuarios, 50.286 calificaciones, 78 MB, dispersión 99,49 %, mínimo 25 lectores por libro) |
| D7 | 1 | Muestra del recomendador de contenido (Gower) | 10.000 libros de los autores con más títulos, como dice el texto del tutorial |
| — | General | RAM del equipo que renderiza | 8 GB |
| D8 | 3 | Definición de preferencia | Binaria (1 = compró alguna vez); se compararon suma, facturas, binaria y log(1 + cantidad) |
| D8b | 3 / prototipo | Recuperar la intensidad | En la app: "compra frecuente" vs "compra ocasional" en el historial; las recomendaciones parten de las frecuentes (umbral por definir) |
| D9 | 3 | Significado de la celda vacía | "No sabemos" (no es rechazo); se codifica 0, equivalente a NA en el coseno binario |
| D10 | 4 | Cálculo de la similitud | Bajo demanda, como en el tutorial (sin precalcular la matriz 732 × 732) |
| D11 | 5 | Códigos duplicados | Fusionar antes de construir la matriz; se conserva el código con más unidades |
| D11b | 5 | Regla de fusión | Descripción normalizada (sin espacios, signos ni mayúsculas): 29 grupos, 732 → 703 productos |
| D12 | 5 | Nombre a mostrar | Descripción más reciente de cada código |
| D14 | 5 | Corregir sesgo de popularidad / ruido en ítem–ítem | No: coseno puro, fiel al tutorial; se documenta como limitación |
| D15 | 6 | Orden de candidatos usuario–usuario | Nº de vecinos que lo compraron; desempate por suma de similitudes |
| D16 | 6 | Sensibilidad a k y umbral | Medidas descriptivas (k = 5, 10, 20, 50; umbral = 1, 2, 3; muestra de 300 compradores) |
| D17 | 6 | Arranque en frío | Completar con los productos con más compradores, marcados como "Popular" |
| D18 | 7 | Compradores evaluados | Los 2.568 presentes en ambos periodos (35 sin compras nuevas cuentan como fallo) |
| D19 | 7 | Métodos evaluados | Usuario–usuario e ítem–ítem adaptado (suma de similitudes con lo comprado); similitud ítem–ítem del entrenamiento guardada en archivo |
| D20 | 7 | Línea base | 10 productos con más compradores en el entrenamiento que la persona no tiene |
| D21 | 7 | Valores de k | 10, 20 y 50 (umbral = 2) |
| D22 | 7 | Inferencia | Wilson + McNemar (hit rate); IC t + t pareada (precision); se revisa Bonferroni (α = 0,0125) |
| D23 | Prototipo | Configuración de la app | Usuario–usuario con k = 50 (único que supera a la línea base en ambas métricas con Bonferroni) |
| D24 | Prototipo | Umbral de "compra frecuente" | 3 o más facturas |
| D25 | Prototipo | Imágenes | Ilustraciones SVG por forma farmacéutica + al menos 20 fotorrealistas generadas por el equipo (prompts en `prompts_imagenes.md`) |
| D26 | Prototipo | Compradores en la app | Los 5.888 + lista de compradores sugeridos para la demostración |
| D27 | Prototipo | Publicación | GitHub Pages + archivo HTML de respaldo |
| D28 | Prototipo | Retroalimentación | Carrito simulado que recalcula recomendaciones con ítem–ítem adaptado |
| D13 | 5 | Casos de análisis | 4 populares + 1 poco vendido: G.MET 850 mg, Dolofen 500 mg, Klear Kids tos, Ginkgo Biloba 40 mg, Vitamina D3 2000 UI |

## Cambios al código del tutorial (Fase 1)

Hallazgos verificados ejecutando `recbooks_1.Rmd` con los datos de Kaggle.

| # | Bloque original | Problema | Evidencia | Corrección |
|---|---|---|---|---|
| C1 | `matrix(ncol = 115246, nrow = 115246)` y `daisy()` sobre todos los libros | Fallan a propósito (demostración de memoria) e impiden renderizar el Rmd | Error de asignación de memoria | Se reemplaza por el cálculo del tamaño teórico (≈141 GB para 132.831 × 132.831 celdas) |
| C2 | `recomendar()` (contenido) | El `left_join` une la calificación al libro recomendado, no al leído → solo recomienda libros ya leídos | User.1167: 8 de 8 recomendaciones ya estaban calificadas por él | Unir por `readed_book`; excluir libros ya leídos |
| C3 | `ratings %>% top_n(10000)` | Sin `wt`, ordena por `Rating` y toma todos los 10 (64.887 filas): la matriz solo contiene dieces | Conteo de filas y valores únicos | Filtrar los 1.000 libros con más calificaciones y conservar todos sus lectores (D5, D6) |
| C4 | `item_recommendation()` | Busca el libro en `rownames` (usuarios) y no en `colnames` (libros); el ISBN de ejemplo no está en la matriz | `which()` devuelve vacío; ISBN ausente | Buscar por columna; elegir un ISBN presente en la matriz |
| C5 | `pivot_wider` de la matriz usuario–libro | 8.525 × 42.151 celdas agotan 7 GB de RAM | El proceso fue terminado por el sistema | Resuelto por C3: matriz de 9.774 × 1.000 (78 MB) |
| C6 | Nota | El número 115.246 viene de los datos de Ander; con Kaggle quedan 132.831 libros tras el filtro | Conteo | Usar `nrow(books)` en lugar de un número fijo |
| C7 | `books[1:10000]` en el recomendador de contenido | El texto dice "10.000 libros de los autores más comunes", pero el código toma las primeras 10.000 filas del archivo | Lectura del código | Seleccionar los libros de los autores con más títulos hasta completar 10.000 (D7) |
| C8 | Texto de la lista de prioridades de Gower | El tutorial lista seis casos y omite "autor y editorial" (disimilitud 0,286) | Tabla de valores únicos de la matriz Gower | Se reemplaza por una tabla con los ocho valores posibles |
| C9 | `table(round(dissimilarity, 3))` (añadido por nosotros para mostrar valores) | Con 100 millones de celdas agotó la memoria al renderizar | Proceso terminado por el sistema | Se calcula sobre el objeto `dist` con `match()`/`tabulate()` y se libera memoria con `gc()` |

## Verificación del render (Fases 1 y 2)

- El documento renderiza de principio a fin sin errores.
- Pico de memoria medido: unos 3,7 GB (cabe en 8 GB si se cierran otros programas pesados).
- Cifras de Procaps coinciden con el enunciado: 496.375 líneas, 250.748 facturas, 5.888 compradores, 732 productos, julio 2013 – marzo 2022; suma por comprador–producto entre 1 y 263; mediana de 22 productos por comprador.

## Hallazgos pendientes de decisión

| # | Fase | Hallazgo | Estado |
|---|---|---|---|
| P1 | 5 / prototipo | 51 códigos de producto tienen más de una descripción en el tiempo | Resuelto (D12) |
| P2 | Bonificación | 131 productos cambiaron de IVA (probablemente la reforma de 2017, del 16 % al 19 %) | Decidir qué IVA usar si se hace el recomendador de contenido |
| P3 | 5 | Productos duplicados con códigos distintos | Resuelto (D11, D11b) |

## Verificación del render (Fases 3 y 4)

- Matriz binaria de 5.888 × 732 (33 MB); 216.414 celdas con compra; dispersión 94,98 %.
- La función de coseno coincide con `lsa::cosine` en 4 pares (diferencia 0).
- Fórmula binaria n_AB / √(n_A·n_B) y equivalencia 0 = NA comprobadas.
- Similitud de un producto contra todos: unos 0,08 segundos.

## Para el informe: limitaciones

- **Fusión de códigos (pedido del equipo):** la regla de normalización podría unir por error dos productos distintos cuyos nombres difieran solo en un signo (por ejemplo, un punto decimal). En nuestros datos no ocurre (se revisaron los 29 grupos uno por uno), pero si la regla se aplicara a otros datos habría que repetir la revisión manual; de lo contrario se afectaría la reproducibilidad.
- **Sesgo de popularidad en ítem–ítem:** en los productos muy vendidos, buena parte de las recomendaciones son productos del top 20 general sin relación clínica (p. ej. Dolofen 500 mg → Tapabocas).
- **Ruido en productos poco vendidos:** con pocos compradores, una sola persona crea similitudes sin sentido (Vitamina D3 2000 UI → productos con 1 comprador en común).
- **Arranque en frío en usuario–usuario:** los vecinos más parecidos de un comprador con un solo producto son otros compradores con ese único producto (coseno = 1), que no aportan candidatos; su lista se completa con populares.

## Cambios propios en usuario–usuario (Fase 6)

| # | Cambio respecto al tutorial | Motivo |
|---|---|---|
| U1 | Orden por nº de vecinos y desempate por suma de similitudes (en vez de calificación media) | Con preferencia binaria la media siempre vale 1 |
| U2 | Solo vecinos con similitud > 0 | Un comprador sin productos en común no es "parecido" |
| U3 | `umbral` como mínimo (≥) de vecinos; por defecto 2 (equivale al `threshold = 1` con `>` del tutorial) | Lectura más directa |
| U4 | `n_recommendations` por defecto 10 | La evaluación es @10 |
| U5 | Relleno con populares cuando faltan recomendaciones | Decisión D17 |
| U6 | Opción de pasar la similitud ya calculada | Reutilizarla en las 12 combinaciones de sensibilidad |
- **Similitud guardada en archivo (Fase 7, pedido del equipo):** en la evaluación, la similitud ítem–ítem se calcula una vez y se guarda en `similitud_items_entrenamiento.rds` para no repetir cálculos idénticos; en la Fase 5 y en la app se calcula bajo demanda. Si cambian los datos, hay que borrar el archivo para que se recalcule (el código comprueba la fecha de corte y los productos); de lo contrario se usaría una similitud desactualizada y se afectaría la reproducibilidad.
- **Elección de k con los datos de prueba:** puede sobrestimar ligeramente el desempeño del k elegido.
- **Techo de la evaluación:** el 24,1 % de las compras nuevas son productos que no existían antes de 2021.
- **Evaluación fuera de línea:** un acierto indica que el comprador compró el producto después, no que lo comprara por la recomendación.

## Cambios propios en la Fase 7

| # | Cambio | Motivo |
|---|---|---|
| E1 | `user_recommendation()` recibe la lista de populares como argumento | En la evaluación el relleno debe usar solo datos del entrenamiento |
| E2 | Error corregido en el cálculo de IC: la precisión se resumía antes de calcular su intervalo | El intervalo se calculaba sobre un solo número |

## Para el informe: comparación de k (evaluada fuera del R Markdown)

Misma evaluación de la Fase 7 (2.568 compradores; entrenamiento hasta 2020, prueba 2021–2022). Con 6 comparaciones contra la línea base, el umbral de Bonferroni es 0,05 / 6 ≈ 0,008.

| k | Hit rate@10 [IC 95 %] | Precision@10 [IC 95 %] | p McNemar | p t pareada | Coincidencia con la línea base |
|---|---|---|---|---|---|
| Línea base | 63,9 % [62,0; 65,7] | 11,70 % [11,23; 12,17] | — | — | 10 de 10 |
| 20 | 64,7 % [62,9; 66,5] | 11,98 % [11,50; 12,46] | 0,31 | 0,069 | 6,3 de 10 |
| 30 | 64,9 % [63,0; 66,7] | 12,15 % [11,67; 12,64] | 0,20 | 0,003 | 6,5 de 10 |
| 40 | 65,5 % [63,6; 67,3] | 12,26 % [11,78; 12,75] | 0,027 | < 0,001 | 6,7 de 10 |
| 50 | 66,0 % [64,1; 67,8] | 12,45 % [11,96; 12,95] | 0,004 | < 0,001 | 6,9 de 10 |

Los valores de k = 20 y 50 coinciden con los del R Markdown. Se probaron k = 10, 20, 30, 40 y 50 con los mismos datos de prueba, lo que aumenta el riesgo de elegir un k favorecido por azar.

## Prototipo: decisiones técnicas y limitaciones

- Las recomendaciones de la app se calculan con **todos los datos (2013–2022)**; la evaluación usó solo hasta 2020.
- **Nombres legibles:** la app expande las abreviaturas de la factura (CJA → caja, CBG → cápsulas blandas, JBE → jarabe…) y muestra también la descripción original en la ficha del producto.
- **Explicación en la vista comprador:** además de "N de sus 50 compradores más parecidos lo compraron", se muestra el producto del historial más relacionado (por similitud ítem–ítem), prefiriendo sus compras frecuentes (D8b). No cambia el orden de las recomendaciones.
- **Carrito:** suma las similitudes de los productos del carrito usando los 50 vecinos más parecidos de cada producto (aproximación: los productos fuera de esos 50 cuentan como 0).
- **Ilustraciones:** la forma farmacéutica se infiere de la descripción con reglas (`clasificar_forma.R`); 58 productos sin forma reconocible usan una caja genérica.
- **Exportación:** `exportar_app.R` se ejecuta aparte del R Markdown para no alargar el render.

## Evolución de la app (versión 2)

Pedido del equipo: nueva paleta (azules y grises) conservando tipografías, estructura de vistas, canasta, reglas de negocio y `window.DATOS`.

| # | Cambio | Detalle |
|---|---|---|
| V1 | Paleta azul y gris | Azul marino #13294B, pizarra #4E5D73, cielo #5AA9E6, hielo #E3EAF3; las cápsulas blandas de las ilustraciones conservan el color ámbar por fidelidad |
| V2 | Más vendidos al entrar | 6 productos con más compradores (respetan filtros y búsqueda), con acceso a la ficha y a la canasta |
| V3 | Filtros combinables | Tipo (`fo`), línea (`s`), fórmula médica (`fm`) y promociones; O dentro de un grupo, Y entre grupos; botón para limpiar |
| V4 | Catálogo paginado | 24 productos por página, anterior/siguiente, números con elipsis, salto a página y contador; respeta filtros y búsqueda |
| V5 | Cuentas de usuario | Registro e inicio de sesión con usuario y contraseña (PBKDF2-SHA256 con sal; respaldo SHA-256 en JS); obligatorio para la canasta y para guardar filtros; la acción interrumpida se completa al entrar |
| V6 | Persistencia por usuario | `localStorage` clave `vitrina.v1` con usuarios, perfiles (canasta, filtros, intereses) y sesión, detrás del objeto `Almacen` para migrar a un backend |
| V7 | Intereses sutiles | Se cuentan las formas farmacéuticas que el usuario mira o agrega; con 3 o más aparece "Sueles ver: …" como atajo |
| V8 | También suelen llevar | Panel al agregar a la canasta con 3 complementos tomados de `D.vecinos` |
| V9 | Fórmula médica y promociones | Aviso respetuoso en la ficha de productos con `fm = SI`; marca "Promoción" cuando el nombre incluye PAGUE/LLEVE/GRATIS/OBSEQUIO/OFERTA/2X1/(1+1) |
| V10 | Un solo archivo | `docs/index.html` incluye los datos; es idéntico para GitHub Pages y para uso local. Se eliminaron `vitrina_respaldo.html`, `crear_respaldo.R`, `docs/datos_app.js` y `docs/fotos.js` |

**Tensión señalada al equipo:** exigir cuenta para usar la canasta agrega un paso en la sustentación (prueba de experiencia de usuario). Se mitigó con registro de un solo paso y acción pendiente que se completa sola.

**Limitación:** las cuentas son de demostración y viven en un navegador; no protegen datos reales y no se comparten entre computadores ni entre el archivo local y GitHub Pages.

## Ajustes visuales de la app (versión 2.1)

| # | Cambio | Detalle |
|---|---|---|
| V11 | Filtros más compactos | Padding 10px 14px, radio 14px, margen superior 16px; rótulos en línea; chips con padding 3px 10px y letra de 13,5px |
| V12 | Más vendidos más compactos | Columnas de mínimo 125px, separación de 10px, cuerpo con padding 8px 10px 10px, nombre en máximo 2 líneas, explicación en máximo 3 |
| V13 | Sugeridos para tu canasta | Bloque entre los filtros y los más vendidos, visible solo con sesión iniciada y productos en la canasta; usa la misma lógica de la canasta lateral (suma de similitudes de `D.vecinos`) y se actualiza al agregar, quitar o vaciar |
