egfr_mdrd4 = function(creatinine, age, is_female, is_black) {
  if (length(creatinine) != length(age) ||
      length(creatinine) != length(is_female) ||
      length(creatinine) != length(is_black)) {
    stop("input vector lengths must match!")
  }

  #egfr = 186.3 * (creatinine^-1.154) * (age^-0.203)

  # PMID 17332152, ID-MS standardisiert
  egfr = 175 * (creatinine^-1.154) * (age^-0.203)
  egfr = ifelse(is_black, egfr * 1.212, egfr)
  ifelse(is_female, egfr * 0.742, egfr)
}

egfr_cys_ckdepi = function(cystatin, age, is_female) {
  if (length(cystatin) != length(age) ||
      length(cystatin) != length(is_female)) {
    stop("input vector lengths must match!")
  }

  egfr = ifelse(cystatin <= 0.8,
                133 * ((cystatin / 0.8)^-0.499) * (0.996^age),
                133 * ((cystatin / 0.8)^-1.328) * (0.996^age))
  ifelse(is_female, egfr * 0.932, egfr)
}

egfr_cys_crea_ckdepi = function(cystatin, creatinine, age, is_female, is_black) {
  if (length(cystatin) != length(creatinine) ||
      length(cystatin) != length(age) ||
      length(cystatin) != length(is_female) ||
      length(cystatin) != length(is_black)) {
    stop("input vector lengths must match!")
  }

  a = ifelse(!is_black, ifelse(!is_female, 135, 130), ifelse(!is_female, 145.8, 140.4))
  b = ifelse(!is_female, creatinine/0.9, creatinine/0.7)
  c = ifelse(!is_female, ifelse(creatinine <= 0.9, -0.207, -0.601), ifelse(creatinine <= 0.7, -0.248, -0.601))
  d = cystatin / 0.8
  e = ifelse(cystatin <= 0.8, -0.375, -0.711)  
  a * (b^c) * (d^e) * (0.995^age)
}

egfr_crea_ckdepi = function(creatinine, age, is_female, is_black) {
  if (length(creatinine) != length(age) ||
      length(creatinine) != length(is_female) ||
      length(creatinine) != length(is_black)) {
    stop("input vector lengths must match!")
  }

  a = ifelse(!is_black, ifelse(!is_female, 141, 144), ifelse(!is_female(163, 166)))
  b = ifelse(!is_female, 0.9, 0.7)
  c = ifelse(!is_female, ifelse(creatinine <= 0.9, -0.411, -1.209), ifelse(creatinine <= 0.7, -0.329, -1.209))
  a * ((creatinine / b) ^ c) * (0.993 ^ age)
}

# tests: 
# crea 0.6 - 0.7 - 0.8 - 0.9 - 1.0
# cyst 0.7 - 0.8 - 0.9
# black/white
# male/female

#> egfr_cys_crea_ckdepi(c(0.7,0.7,0.7,0.7,0.7),c(0.6,0.7,0.8,0.9,1.0),c(80,80,80,80,80),c(0,0,0,0,0),c(0,0,0,0,0))
# [1] 103.36609 100.11983  97.39032  95.04455  89.21276
#> egfr_cys_crea_ckdepi(c(0.7,0.7,0.7,0.7,0.7),c(0.6,0.7,0.8,0.9,1.0),c(80,80,80,80,80),c(1,1,1,1,1),c(0,0,0,0,0))
#[1] 95.09104 91.52438 84.46633 78.69388 73.86534
#> egfr_cys_crea_ckdepi(c(0.7,0.7,0.7,0.7,0.7),c(0.6,0.7,0.8,0.9,1.0),c(80,80,80,80,80),c(1,1,1,1,1),c(1,1,1,1,1))
#[1] 102.69832  98.84633  91.22364  84.98939  79.77457
#> egfr_cys_crea_ckdepi(c(0.9,0.9,0.9,0.9,0.9),c(0.6,0.7,0.8,0.9,1.0),c(80,80,80,80,80),c(1,1,1,1,1),c(1,1,1,1,1))
#[1] 89.83528 86.46575 79.79781 74.34441 69.78274
