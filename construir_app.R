# =============================================================================
# Construye docs/index.html: la app completa en UN SOLO ARCHIVO (datos incluidos).
# Ese mismo archivo es el que se sube a GitHub Pages y el que se abre localmente,
# así que las dos versiones son idénticas. Las fotos se leen de docs/imagenes/.
#
# Entradas:  fuente/plantilla.html  (diseño y lógica de la app)
#            fuente/datos_app.js    (generado por exportar_app.R)
# Conserva la lista de fotos (bloque FOTOS) que ya tenga docs/index.html.
# =============================================================================
leer <- function(f) readLines(f, encoding = "UTF-8", warn = FALSE)

plantilla <- leer("fuente/plantilla.html")
datos     <- leer("fuente/datos_app.js")
datos     <- datos[!grepl("^//", datos)]                 # quita el comentario inicial

# Bloque de fotos: se conserva el de la versión anterior si existe
bloque <- function(x) { a <- grep("FOTOS-INICIO", x, fixed = TRUE); b <- grep("FOTOS-FIN", x, fixed = TRUE); c(a, b) }
if (file.exists("docs/index.html")) {
  anterior <- leer("docs/index.html"); ia <- bloque(anterior); ip <- bloque(plantilla)
  if (length(ia) == 2 && length(ip) == 2)
    plantilla <- c(plantilla[1:(ip[1] - 1)], anterior[ia[1]:ia[2]], plantilla[(ip[2] + 1):length(plantilla)])
}

i <- grep("/*__DATOS__*/", plantilla, fixed = TRUE)
stopifnot(length(i) == 1)
salida <- c(plantilla[1:(i - 1)], "<script>", datos, "</script>", plantilla[(i + 1):length(plantilla)])

dir.create("docs/imagenes", recursive = TRUE, showWarnings = FALSE)
writeLines(salida, "docs/index.html", useBytes = TRUE)
cat("Listo: docs/index.html (", round(file.size("docs/index.html") / 1e6, 1), "MB )\n")
