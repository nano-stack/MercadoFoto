"""
Servicio Blue Express — puntos de despacho en Chile.
Lista curada de sus principales oficinas y puntos de retiro/despacho
(Salcobrand, oficinas propias, Chile Express).
Se filtra por similitud con el nombre de comuna ingresado.
"""

from typing import List, Dict

# ── Puntos de despacho Blue Express Chile ─────────────────────────────────────
# Fuente: web Blue Express + locales conocidos (actualizar periódicamente)
_PUNTOS: List[Dict] = [
    # ── REGIÓN METROPOLITANA ───────────────────────────────────────────────
    {"comuna": "Santiago Centro", "nombre": "Blue Express Santiago Centro", "direccion": "Av. Libertador Bernardo O'Higgins 1179", "region": "RM", "lat": -33.4580, "lng": -70.6519},
    {"comuna": "Providencia",     "nombre": "Salcobrand Providencia",        "direccion": "Av. Providencia 1234",               "region": "RM", "lat": -33.4326, "lng": -70.6203},
    {"comuna": "Las Condes",      "nombre": "Salcobrand Las Condes",          "direccion": "Av. Apoquindo 4775",                 "region": "RM", "lat": -33.4099, "lng": -70.5791},
    {"comuna": "Maipú",           "nombre": "Blue Express Maipú",            "direccion": "Av. 5 de Abril 650",                 "region": "RM", "lat": -33.5100, "lng": -70.7565},
    {"comuna": "La Florida",      "nombre": "Salcobrand La Florida",         "direccion": "Av. Vicuña Mackenna 7110",           "region": "RM", "lat": -33.5199, "lng": -70.5924},
    {"comuna": "Ñuñoa",           "nombre": "Blue Express Ñuñoa",            "direccion": "Av. Irarrázaval 1850",               "region": "RM", "lat": -33.4567, "lng": -70.6004},
    {"comuna": "San Miguel",      "nombre": "Salcobrand San Miguel",         "direccion": "Gran Avenida 3010",                  "region": "RM", "lat": -33.4982, "lng": -70.6477},
    {"comuna": "Puente Alto",     "nombre": "Blue Express Puente Alto",      "direccion": "Av. Concha y Toro 1205",             "region": "RM", "lat": -33.6104, "lng": -70.5759},
    {"comuna": "Quilicura",       "nombre": "Salcobrand Quilicura",          "direccion": "Av. Manuel Antonio Matta 601",       "region": "RM", "lat": -33.3535, "lng": -70.7278},
    {"comuna": "Peñalolén",       "nombre": "Blue Express Peñalolén",        "direccion": "Av. Grecia 8901",                    "region": "RM", "lat": -33.4792, "lng": -70.5450},
    {"comuna": "La Reina",        "nombre": "Salcobrand La Reina",           "direccion": "Av. Ossa 1212",                      "region": "RM", "lat": -33.4464, "lng": -70.5602},
    {"comuna": "Vitacura",        "nombre": "Blue Express Vitacura",         "direccion": "Av. Vitacura 4380",                  "region": "RM", "lat": -33.3997, "lng": -70.5980},
    {"comuna": "Lo Barnechea",    "nombre": "Salcobrand Lo Barnechea",       "direccion": "Av. La Dehesa 2345",                 "region": "RM", "lat": -33.3636, "lng": -70.5190},
    {"comuna": "El Bosque",       "nombre": "Blue Express El Bosque",        "direccion": "Av. José Joaquín Pérez 555",         "region": "RM", "lat": -33.5616, "lng": -70.6732},
    {"comuna": "Recoleta",        "nombre": "Salcobrand Recoleta",           "direccion": "Av. Recoleta 2130",                  "region": "RM", "lat": -33.4150, "lng": -70.6410},
    {"comuna": "Renca",           "nombre": "Blue Express Renca",            "direccion": "Av. Renca 1020",                     "region": "RM", "lat": -33.3968, "lng": -70.6955},
    {"comuna": "Cerrillos",       "nombre": "Blue Express Cerrillos",        "direccion": "Av. Pedro Aguirre Cerda 9001",       "region": "RM", "lat": -33.4907, "lng": -70.7138},
    {"comuna": "San Bernardo",    "nombre": "Blue Express San Bernardo",     "direccion": "Freire 602",                         "region": "RM", "lat": -33.5931, "lng": -70.7027},
    {"comuna": "Talagante",       "nombre": "Salcobrand Talagante",          "direccion": "Erasmo Escala 550",                  "region": "RM", "lat": -33.6616, "lng": -70.9264},

    # ── VALPARAÍSO ─────────────────────────────────────────────────────────
    {"comuna": "Valparaíso",      "nombre": "Blue Express Valparaíso",       "direccion": "Av. Pedro Montt 2145",               "region": "V",  "lat": -33.0472, "lng": -71.6127},
    {"comuna": "Viña del Mar",    "nombre": "Blue Express Viña del Mar",     "direccion": "Av. Valparaíso 1680",                "region": "V",  "lat": -33.0153, "lng": -71.5501},
    {"comuna": "Quilpué",         "nombre": "Salcobrand Quilpué",            "direccion": "Vergara 500",                        "region": "V",  "lat": -33.0532, "lng": -71.4415},
    {"comuna": "Quillota",        "nombre": "Blue Express Quillota",         "direccion": "O'Higgins 480",                      "region": "V",  "lat": -32.8834, "lng": -71.2498},
    {"comuna": "San Antonio",     "nombre": "Blue Express San Antonio",      "direccion": "Ramón Barros Luco 305",              "region": "V",  "lat": -33.5952, "lng": -71.6227},

    # ── O'HIGGINS ──────────────────────────────────────────────────────────
    {"comuna": "Rancagua",        "nombre": "Blue Express Rancagua",         "direccion": "San Martín 455",                     "region": "VI", "lat": -34.1703, "lng": -70.7444},
    {"comuna": "San Fernando",    "nombre": "Salcobrand San Fernando",       "direccion": "Valdivia 510",                       "region": "VI", "lat": -34.5862, "lng": -70.9895},

    # ── MAULE ──────────────────────────────────────────────────────────────
    {"comuna": "Talca",           "nombre": "Blue Express Talca",            "direccion": "2 Norte 1230",                       "region": "VII","lat": -35.4264, "lng": -71.6554},
    {"comuna": "Curicó",          "nombre": "Salcobrand Curicó",             "direccion": "Prat 680",                           "region": "VII","lat": -34.9830, "lng": -71.2394},
    {"comuna": "Linares",         "nombre": "Blue Express Linares",          "direccion": "Independencia 420",                  "region": "VII","lat": -35.8455, "lng": -71.5973},

    # ── BIOBÍO ─────────────────────────────────────────────────────────────
    {"comuna": "Concepción",      "nombre": "Blue Express Concepción",       "direccion": "Av. Prat 560",                       "region": "VIII","lat": -36.8270, "lng": -73.0498},
    {"comuna": "Talcahuano",      "nombre": "Salcobrand Talcahuano",         "direccion": "Colón 550",                          "region": "VIII","lat": -36.7217, "lng": -73.1174},
    {"comuna": "Los Ángeles",     "nombre": "Blue Express Los Ángeles",      "direccion": "Valdivia 310",                       "region": "VIII","lat": -37.4722, "lng": -72.3527},
    {"comuna": "Chillán",         "nombre": "Blue Express Chillán",          "direccion": "18 de Septiembre 455",               "region": "XVI", "lat": -36.6068, "lng": -72.1032},

    # ── ARAUCANÍA ──────────────────────────────────────────────────────────
    {"comuna": "Temuco",          "nombre": "Blue Express Temuco",           "direccion": "Av. Caupolicán 125",                 "region": "IX", "lat": -38.7396, "lng": -72.5987},
    {"comuna": "Padre Las Casas", "nombre": "Salcobrand Padre Las Casas",    "direccion": "Av. Carrera Pinto 1100",             "region": "IX", "lat": -38.7688, "lng": -72.5871},
    {"comuna": "Villarrica",      "nombre": "Blue Express Villarrica",       "direccion": "Henríquez 201",                      "region": "IX", "lat": -39.2790, "lng": -72.2256},
    {"comuna": "Pucón",           "nombre": "Salcobrand Pucón",              "direccion": "O'Higgins 605",                      "region": "IX", "lat": -39.2726, "lng": -71.9771},

    # ── LOS RÍOS ───────────────────────────────────────────────────────────
    {"comuna": "Valdivia",        "nombre": "Blue Express Valdivia",         "direccion": "Yungay 735",                         "region": "XIV","lat": -39.8142, "lng": -73.2459},

    # ── LOS LAGOS ──────────────────────────────────────────────────────────
    {"comuna": "Puerto Montt",    "nombre": "Blue Express Puerto Montt",     "direccion": "Av. Diego Portales 1050",            "region": "X",  "lat": -41.4718, "lng": -72.9360},
    {"comuna": "Castro",          "nombre": "Blue Express Castro",           "direccion": "Blanco 289",                         "region": "X",  "lat": -42.4782, "lng": -73.7619},
    {"comuna": "Osorno",          "nombre": "Blue Express Osorno",           "direccion": "Ramírez 970",                        "region": "X",  "lat": -40.5742, "lng": -73.1387},

    # ── COQUIMBO ───────────────────────────────────────────────────────────
    {"comuna": "La Serena",       "nombre": "Blue Express La Serena",        "direccion": "Balmaceda 2399",                     "region": "IV", "lat": -29.9027, "lng": -71.2519},
    {"comuna": "Coquimbo",        "nombre": "Salcobrand Coquimbo",           "direccion": "Aldunate 380",                       "region": "IV", "lat": -29.9544, "lng": -71.3432},
    {"comuna": "Ovalle",          "nombre": "Blue Express Ovalle",           "direccion": "Vicuña Mackenna 230",                "region": "IV", "lat": -30.6028, "lng": -71.2006},

    # ── ATACAMA ────────────────────────────────────────────────────────────
    {"comuna": "Copiapó",         "nombre": "Blue Express Copiapó",          "direccion": "Los Carrera 780",                    "region": "III","lat": -27.3668, "lng": -70.3321},

    # ── ANTOFAGASTA ────────────────────────────────────────────────────────
    {"comuna": "Antofagasta",     "nombre": "Blue Express Antofagasta",      "direccion": "Prat 460",                           "region": "II", "lat": -23.6500, "lng": -70.3954},
    {"comuna": "Calama",          "nombre": "Blue Express Calama",           "direccion": "Ramírez 2050",                       "region": "II", "lat": -22.4562, "lng": -68.9322},

    # ── TARAPACÁ ───────────────────────────────────────────────────────────
    {"comuna": "Iquique",         "nombre": "Blue Express Iquique",          "direccion": "Patricio Lynch 480",                 "region": "I",  "lat": -20.2133, "lng": -70.1503},

    # ── ARICA Y PARINACOTA ─────────────────────────────────────────────────
    {"comuna": "Arica",           "nombre": "Blue Express Arica",            "direccion": "Av. Maipú 1120",                     "region": "XV", "lat": -18.4783, "lng": -70.3126},

    # ── MAGALLANES ─────────────────────────────────────────────────────────
    {"comuna": "Punta Arenas",    "nombre": "Blue Express Punta Arenas",     "direccion": "Av. Bulnes 590",                     "region": "XII","lat": -53.1638, "lng": -70.9171},

    # ── AYSÉN ──────────────────────────────────────────────────────────────
    {"comuna": "Coyhaique",       "nombre": "Blue Express Coyhaique",        "direccion": "Bilbao 230",                         "region": "XI", "lat": -45.5752, "lng": -72.0662},
]


def buscar_puntos(comuna: str, limite: int = 5) -> List[Dict]:
    """
    Busca puntos Blue Express por nombre de comuna.
    Devuelve los `limite` primeros resultados por relevancia.
    """
    if not comuna or not comuna.strip():
        return _PUNTOS[:limite]

    query = comuna.strip().lower()

    # Orden: coincidencia exacta → contiene → resto
    exactos   = [p for p in _PUNTOS if p["comuna"].lower() == query]
    contienen = [p for p in _PUNTOS if query in p["comuna"].lower() and p not in exactos]
    resto     = [p for p in _PUNTOS if p not in exactos and p not in contienen]

    resultados = (exactos + contienen + resto)[:limite]
    return resultados
