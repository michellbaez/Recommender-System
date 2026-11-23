# Clasifica la forma farmacéutica a partir de la descripción (para las ilustraciones)
clasificar_forma <- function(d) {
  d <- toupper(iconv(d, to = "ASCII//TRANSLIT"))
  dplyr::case_when(
    grepl("TAPA ?BOCAS|PROTEKTA", d)                                   ~ "tapabocas",
    grepl("TIRAS|LANCETA|GLUCOMETRO|BRAZALETE|GLUCOQUICK", d) ~ "glucometria",
    grepl("BASCULA|DIAMOND|TEST COVID|KIT PARA", d)                    ~ "dispositivo",
    grepl("TENSI|TERMOMETRO", d)                                    ~ "dispositivo",
    grepl("AGUJ|JERINGA|INY|AMP|JER PRELL|PRELLENADA|VIAL|NANOPASS", d)             ~ "inyectable",
    grepl("AEROSOL|SPRAY", d)                                          ~ "aerosol",
    grepl("OFT|LAGRI|TEARSOFT", d)                                     ~ "oftalmico",
    grepl("OVUL|VAGINAL", d) & !grepl("CREMA", d)                      ~ "ovulo",
    grepl("CREMA|UNGU|GEL TOP|POMADA|UNIGEL|LOCION|LOTION|SHAMPOO|CHAMPU", d) ~ "crema",
    grepl("GOTAS|GOT ", d)                                             ~ "gotas",
    grepl("JBE|JARABE|SUSP|SUS |SOL ORAL|JALEA|EMULSION|ELIXIR|SOL CJA|SOL\\b|ML\\b|ML CIAL|ML$", d) ~ "frasco_liquido",
    grepl("SOB|SACH|POLV|POL |POL SAB|NUTRIGEL", d)                    ~ "sobres",
    grepl("GOMA|GUMIVIT|GUMI|GUMMY|MINIPACK|TROLLI|GLOWWORMS|BEARS", d)                            ~ "gomas",
    grepl("CBG|CAPS|CAP\\b|CAP\\.|CAPSULA|SOFTGEL|PERLA", d)   ~ "capsula_blanda",
    grepl("TAB|COMP|GTAB|GELTAB|CAPLET|GRAGEA|\\bCD\\b", d)            ~ "tabletas",
    grepl(" G\\b|G CIAL|X ?[0-9]+ ?G\\b|BOTELLA", d)                   ~ "tarro_polvo",
    TRUE                                                              ~ "caja"
  )
}
