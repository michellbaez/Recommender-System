# =============================================================================
# Exportación de resultados para el prototipo web
# Proyecto 4 — Sistema de recomendación para un marketplace farmacéutico
#
# Requiere haber renderizado antes proyecto4_recomendador.Rmd (usa los .rds
# que guarda). Genera fuente/datos_app.js y luego construye docs/index.html.
# Tiempo aproximado: 20 a 40 minutos (el usuario–usuario de 5.888 compradores).
#
# Configuración (decisiones del equipo):
#   - Vista producto: ítem–ítem, coseno puro (D14), 10 recomendaciones.
#   - Vista comprador: usuario–usuario, k = 50, umbral = 2 (D23), 10
#     recomendaciones, relleno con populares (D17).
#   - Compra frecuente: 3 o más facturas (D24).
#   - Carrito: suma de similitudes ítem–ítem con los productos del carrito (D28).
#   - Recomendaciones calculadas con TODOS los datos (2013–2022).
# =============================================================================

suppressMessages({library(dplyr); library(tidyr); library(jsonlite); library(parallel)})
source("clasificar_forma.R")

user_item <- readRDS("matriz_binaria_procaps.rds")   # 5.888 × 703, binaria
productos <- readRDS("productos_depurados.rds")      # catálogo depurado
pares     <- readRDS("pares_procaps.rds")            # comprador–producto con nº de facturas

stopifnot(identical(sort(colnames(user_item)), sort(productos$Material)))

# Misma función de coseno de las Fases 1 y 4
cos_similarity <- function(A, B) {
  num <- sum(A * B, na.rm = TRUE)
  den <- sqrt(sum(A^2, na.rm = TRUE)) * sqrt(sum(B^2, na.rm = TRUE))
  num / den
}

productos <- productos %>%
  mutate(forma = clasificar_forma(description)) %>%
  arrange(desc(compradores))
codigos <- productos$Material
idx <- setNames(seq_along(codigos) - 1, codigos)        # índice 0-based para JavaScript
n_compradores <- setNames(productos$compradores, codigos)

# --- 1. Similitud ítem–ítem (bajo demanda, producto por producto) -------------
cat("Similitud ítem–ítem...\n")
sim_items <- sapply(codigos, function(m)
  apply(user_item[, codigos], 2, function(y) cos_similarity(user_item[, m], y)))
en_comun_items <- crossprod(user_item[, codigos])       # compradores en común (n_AB)
diag(sim_items) <- 0

# Vecinos de cada producto: los 50 más parecidos (las primeras 10 son la vista
# producto; las 50 alimentan el carrito)
vecinos_items <- lapply(codigos, function(m) {
  s <- sim_items[, m]
  o <- order(-s)[1:50]
  o <- o[s[o] > 0]
  lapply(o, function(j) c(idx[codigos[j]], round(s[j], 4), en_comun_items[j, m]))
})

# --- 2. Usuario–usuario, k = 50 ----------------------------------------------
populares <- codigos                                   # ya ordenados por compradores
facturas_par <- pares %>% select(colaborador, Material, facturas)

recomendar_comprador <- function(uid, k = 50, umbral = 2, n = 10) {
  u <- user_item[uid, ]
  sim <- apply(user_item, 1, function(y) cos_similarity(u, y))
  vec <- sim[names(sim) != uid & sim > 0]
  vec <- sort(vec, decreasing = TRUE)[seq_len(min(k, length(vec)))]
  ya  <- colnames(user_item)[u > 0]
  Mv  <- user_item[names(vec), , drop = FALSE]
  cand <- tibble(Material = colnames(user_item),
                 vecinos  = colSums(Mv),
                 suma_sim = colSums(Mv * vec)) %>%
    filter(!(Material %in% ya), vecinos >= umbral) %>%
    arrange(desc(vecinos), desc(suma_sim)) %>%
    slice_head(n = n)
  recs <- cand$Material; fuente <- rep(1, length(recs)); nvec <- cand$vecinos
  if (length(recs) < n) {
    extra <- setdiff(populares, c(ya, recs))[seq_len(n - length(recs))]
    recs <- c(recs, extra); fuente <- c(fuente, rep(0, length(extra))); nvec <- c(nvec, rep(0, length(extra)))
  }
  # Para la explicación: el producto de su historial más relacionado con cada
  # recomendación, prefiriendo sus compras frecuentes (D8b)
  hist <- facturas_par %>% filter(colaborador == uid)
  frec <- hist$Material[hist$facturas >= 3]
  rel <- sapply(recs, function(r) {
    pool <- if (length(frec) > 0 && max(sim_items[frec, r]) > 0) frec else ya
    pool[which.max(sim_items[pool, r])]
  })
  list(r = unname(idx[recs]), f = fuente, v = nvec, rel = unname(idx[rel]), k = length(vec))
}

cat("Usuario–usuario para", nrow(user_item), "compradores (k = 50)...\n")
t0 <- Sys.time()
compradores <- rownames(user_item)
recs_compradores <- mclapply(compradores, recomendar_comprador, mc.cores = max(1, detectCores() - 0))
names(recs_compradores) <- compradores
cat("Listo en", round(difftime(Sys.time(), t0, units = "mins"), 1), "minutos\n")

# Comprobación: ninguna recomendación ya comprada
stopifnot(all(mapply(function(r, uid) !any(codigos[r$r + 1] %in% colnames(user_item)[user_item[uid, ] > 0]),
                     recs_compradores, compradores)))

# --- 3. Historiales -----------------------------------------------------------
historiales <- facturas_par %>%
  mutate(i = idx[Material], frecuente = as.integer(facturas >= 3)) %>%
  arrange(colaborador, desc(frecuente), desc(facturas)) %>%
  group_by(colaborador) %>%
  summarise(h = list(lapply(seq_along(i), function(j) c(i[j], facturas[j]))), .groups = "drop")
hist_lista <- setNames(historiales$h, historiales$colaborador)

# --- 4. Compradores sugeridos para la demostración ----------------------------
n_prod <- rowSums(user_item)
tipico   <- names(sort(n_prod))[round(length(n_prod) / 2)]
diabetes <- names(which(user_item[, "300005212"] > 0 & user_item[, "500000204"] > 0))
diabetes <- diabetes[which.min(abs(n_prod[diabetes] - 25))]
grande   <- names(which.max(n_prod))
frio     <- names(n_prod[n_prod == 1 & user_item[, "300001244"] > 0])[1]   # solo Orlistat
sugeridos <- list(
  list(id = tipico,   titulo = "Comprador típico",          detalle = "Compró la cantidad mediana de productos"),
  list(id = diabetes, titulo = "Paciente con diabetes",     detalle = "Compra metformina y tiras de glucosa"),
  list(id = grande,   titulo = "Comprador muy frecuente",   detalle = "El historial más amplio de la tienda"),
  list(id = frio,     titulo = "Comprador nuevo",           detalle = "Solo ha comprado un producto")
)

# --- 5. Escribir el archivo para la app ----------------------------------------
catalogo <- productos %>%
  transmute(c = Material, n = description, b = compradores, s = sociedad,
            fm = formula_medica, fo = forma)

salida <- list(
  meta = list(generado = format(Sys.time(), "%Y-%m-%d %H:%M"), k = 50, umbral = 2,
              frecuente_desde = 3, compradores = length(compradores), productos = length(codigos)),
  productos   = catalogo,
  vecinos     = vecinos_items,
  compradores = recs_compradores,
  historial   = hist_lista,
  sugeridos   = sugeridos
)

dir.create("fuente", showWarnings = FALSE); dir.create("docs", showWarnings = FALSE)
writeLines(c("// Generado por exportar_app.R. No editar a mano.",
             paste0("window.DATOS = ", toJSON(salida, auto_unbox = TRUE, digits = 4), ";")),
           "fuente/datos_app.js", useBytes = TRUE)

# Versión legible en CSV (vista producto), para el repositorio y el informe
productos_rec <- bind_rows(lapply(seq_along(codigos), function(i) {
  v <- vecinos_items[[i]][1:min(10, length(vecinos_items[[i]]))]
  tibble(Material = codigos[i], producto = productos$description[i],
         posicion = seq_along(v),
         Material_recomendado = sapply(v, function(x) codigos[x[1] + 1]),
         recomendado = productos$description[sapply(v, function(x) x[1] + 1)],
         similitud = sapply(v, `[`, 2), compradores_en_comun = sapply(v, `[`, 3))
}))
write.csv(productos_rec, "fuente/recomendaciones_producto.csv", row.names = FALSE, fileEncoding = "UTF-8")

cat("Archivo fuente/datos_app.js:", round(file.size("fuente/datos_app.js") / 1e6, 1), "MB\n")
source("construir_app.R")   # app en un solo archivo: docs/index.html
