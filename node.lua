gl.setup(NATIVE_WIDTH, NATIVE_HEIGHT)

local font = resource.load_font "font.ttf"
local logo = resource.load_image "logo.png"

-- Reglages
local SECONDES = false          -- true pour afficher les secondes
local LOGO_LARGEUR = 0.25       -- largeur du logo = 1/4 de l'ecran
local PANNEAU_BLANC = true      -- fond blanc derriere le logo

-- Couleurs E.Leclerc (approximatives)
local BLEU   = {0.00, 0.36, 0.67}
local ORANGE = {0.97, 0.58, 0.12}
local BLANC  = {1, 1, 1}

local tex_orange = resource.create_colored_texture(ORANGE[1], ORANGE[2], ORANGE[3], 1)
local tex_blanc  = resource.create_colored_texture(1, 1, 1, 1)

local JOURS = {"DIMANCHE","LUNDI","MARDI","MERCREDI","JEUDI","VENDREDI","SAMEDI"}
local MOIS  = {"janvier","février","mars","avril","mai","juin","juillet",
               "août","septembre","octobre","novembre","décembre"}

-- Heure d'été européenne automatique (France)
local function jour_semaine(y, m, d)   -- 0 = dimanche
  local t = {0,3,2,5,0,3,5,2,6,4,2,4}
  if m < 3 then y = y - 1 end
  return (y + math.floor(y/4) - math.floor(y/100) + math.floor(y/400) + t[m] + d) % 7
end

local function decalage(utc)
  local debut = 3 * 10000 + (31 - jour_semaine(utc.year, 3, 31)) * 100 + 1
  local fin   = 10 * 10000 + (31 - jour_semaine(utc.year, 10, 31)) * 100 + 1
  local now   = utc.month * 10000 + utc.day * 100 + utc.hour
  if now >= debut and now < fin then return 7200 end
  return 3600
end

local function centre(texte, y, taille, c)
  local w = font:width(texte, taille)
  font:write((WIDTH - w) / 2, y, texte, taille, c[1], c[2], c[3], 1)
end

local function dessiner_logo()
  local iw, ih = logo:size()
  local lw = WIDTH * LOGO_LARGEUR
  local lh = lw * ih / iw

  -- Securite : le logo ne depasse pas 20 % de la hauteur
  local max_h = HEIGHT * 0.20
  if lh > max_h then
    lw = lw * max_h / lh
    lh = max_h
  end

  local x = (WIDTH - lw) / 2
  local y = HEIGHT * 0.94 - lh      -- juste au-dessus du bandeau orange

  if PANNEAU_BLANC then
    local pad = HEIGHT * 0.015
    tex_blanc:draw(x - pad, y - pad, x + lw + pad, y + lh + pad)
  end
  logo:draw(x, y, x + lw, y + lh)
end

function node.render()
  gl.clear(BLEU[1], BLEU[2], BLEU[3], 1)

  -- Bandeaux orange haut et bas
  tex_orange:draw(0, 0, WIDTH, HEIGHT * 0.03)
  tex_orange:draw(0, HEIGHT * 0.97, WIDTH, HEIGHT)

  -- Heure locale
  local t   = os.time()
  local utc = os.date("!*t", t)
  local d   = os.date("!*t", t + decalage(utc))

  local heure
  if SECONDES then
    heure = string.format("%02d:%02d:%02d", d.hour, d.min, d.sec)
  else
    heure = string.format("%02d:%02d", d.hour, d.min)
  end

  centre(heure, HEIGHT * 0.05, HEIGHT * 0.38, BLANC)

  -- Filet orange
  local lw = WIDTH * 0.30
  tex_orange:draw((WIDTH - lw) / 2, HEIGHT * 0.48,
                  (WIDTH + lw) / 2, HEIGHT * 0.492)

  -- Jour et date
  centre(JOURS[d.wday], HEIGHT * 0.51, HEIGHT * 0.10, ORANGE)
  centre(string.format("%d %s %d", d.day, MOIS[d.month], d.year),
         HEIGHT * 0.63, HEIGHT * 0.065, BLANC)

  -- Logo en bas, centré
  dessiner_logo()
end
