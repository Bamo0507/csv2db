-- Cuales son las 5 cartas mas caras actualmente en el mercado (holofoil)?
SELECT 
c.Nombre AS top5_cartas, 
c.Pokedex_numb AS pokedex,
c.Set_name AS set_name,
c.Rarity AS rarity,
p.Avg_Foil AS precio_foil,
p.TCG_Price_Date AS fecha
FROM Precios_Cartas AS p
JOIN Cartas AS c ON p.Carta_id = c.Id
JOIN (
    SELECT
    p.Carta_id,
    MAX(TCG_Price_Date) AS max_date
    FROM Precios_Cartas AS p
    GROUP BY p.Carta_id
) AS latest ON p.Carta_id = latest.Carta_id AND p.TCG_Price_Date = latest.max_date
WHERE 
p.Avg_Foil IS NOT NULL 
ORDER BY precio_foil DESC
LIMIT 5;

-- Cuantas cartas tienen un precio de mercado en holofoil mayor a 100?
SELECT
c.Nombre AS cartas_mas_100,
c.Pokedex_numb AS pokedex,
c.Set_name AS set_name,
c.Rarity AS rarity,
p.Avg_Foil AS precio_foil,
p.TCG_Price_Date AS fecha
FROM Precios_Cartas AS p
JOIN Cartas AS c ON p.Carta_id = c.Id
-- Jalar las cartas mas recientes 
JOIN (
    SELECT
    p.Carta_id,
    MAX(TCG_Price_Date) AS max_date
    FROM Precios_Cartas AS p
    GROUP BY p.Carta_id
) AS latest ON p.Carta_id = latest.Carta_id AND p.TCG_Price_Date = latest.max_date
WHERE p.Avg_Foil > 100
ORDER BY precio_foil DESC;

-- Cual es el precio promedio de una carta en holofoil en la ultima actualizacion?
SELECT
AVG(Avg_Foil) AS precio_promedio_holofoil
FROM Precios_Cartas AS p
JOIN (
    SELECT
    p.Carta_id,
    MAX(TCG_Price_Date) AS max_date
    FROM Precios_Cartas AS p
    GROUP BY p.Carta_id
) AS latest ON p.Carta_id = latest.Carta_id AND p.TCG_Price_Date = latest.max_date;

-- Cuales son las cartas qeu han bajado de precio en la ultima actualizacion?
SELECT
c.Nombre AS cartas_bajaron_precio,
c.Pokedex_numb AS pokedex,
c.Rarity AS rarity,
p_feb.Avg_Foil AS precio_feb,
p_mar.Avg_Foil AS precio_mar,
p_feb.Avg_Foil - p_mar.Avg_Foil AS diferencia,
'Holo' AS tipo
FROM Precios_Cartas AS p_feb
JOIN Precios_Cartas AS p_mar
ON p_feb.Carta_id = p_mar.Carta_id
AND EXTRACT(YEAR FROM p_feb.TCG_Price_Date) = EXTRACT(YEAR FROM p_mar.TCG_Price_Date)
AND EXTRACT(MONTH FROM p_feb.TCG_Price_Date) = 2
AND EXTRACT(MONTH FROM p_mar.TCG_Price_Date) = 3
JOIN Cartas AS c ON p_feb.Carta_id = c.Id
WHERE p_feb.Avg_Foil > p_mar.Avg_Foil 
AND p_feb.Avg_Foil IS NOT NULL 
AND p_mar.Avg_Foil IS NOT NULL

UNION ALL

SELECT
c.Nombre AS cartas_bajaron_precio,
c.Pokedex_numb AS pokedex,
c.Rarity AS rarity,
p_feb.Avg_Normal AS precio_feb,
p_mar.Avg_Normal AS precio_mar,
p_feb.Avg_Normal - p_mar.Avg_Normal AS diferencia,
'Normal' AS tipo
FROM Precios_Cartas AS p_feb
JOIN Precios_Cartas AS p_mar
ON p_feb.Carta_id = p_mar.Carta_id
AND EXTRACT(YEAR FROM p_feb.TCG_Price_Date) = EXTRACT(YEAR FROM p_mar.TCG_Price_Date)
AND EXTRACT(MONTH FROM p_feb.TCG_Price_Date) = 2
AND EXTRACT(MONTH FROM p_mar.TCG_Price_Date) = 3
JOIN Cartas AS c ON p_feb.Carta_id = c.Id
WHERE p_feb.Avg_Normal > p_mar.Avg_Normal 
AND p_feb.Avg_Normal IS NOT NULL 
AND p_mar.Avg_Normal IS NOT NULL

UNION ALL

SELECT
c.Nombre AS cartas_bajaron_precio,
c.Pokedex_numb AS pokedex,
c.Rarity AS rarity,
p_feb.Avg_Reverse AS precio_feb,
p_mar.Avg_Reverse AS precio_mar,
p_feb.Avg_Reverse - p_mar.Avg_Reverse AS diferencia,
'Reverse' AS tipo
FROM Precios_Cartas AS p_feb
JOIN Precios_Cartas AS p_mar
ON p_feb.Carta_id = p_mar.Carta_id
AND EXTRACT(YEAR FROM p_feb.TCG_Price_Date) = EXTRACT(YEAR FROM p_mar.TCG_Price_Date)
AND EXTRACT(MONTH FROM p_feb.TCG_Price_Date) = 2
AND EXTRACT(MONTH FROM p_mar.TCG_Price_Date) = 3
JOIN Cartas AS c ON p_feb.Carta_id = c.Id
WHERE p_feb.Avg_Reverse > p_mar.Avg_Reverse 
AND p_feb.Avg_Reverse IS NOT NULL 
AND p_mar.Avg_Reverse IS NOT NULL

ORDER BY diferencia DESC;

-- Que tipo de Pokemon tiene el precio promedio mas alto en holofoil?
SELECT
e.Types AS tipo_pokemon,
AVG(p.Avg_Foil) AS precio_promedio_holofoil
FROM Estadistica_Cartas AS e
JOIN Precios_Cartas AS p ON e.Carta_id = p.Carta_id
JOIN (
    SELECT
    p.Carta_id,
    MAX(TCG_Price_Date) AS max_date
    FROM Precios_Cartas AS p
    GROUP BY p.Carta_id
) AS latest ON p.Carta_id = latest.Carta_id AND p.TCG_Price_Date = latest.max_date
WHERE p.Avg_Foil IS NOT NULL
GROUP BY e.Types
HAVING e.Types IS NOT NULL; -- Devolvio un type [null] por lo que se agrego el HAVING

-- Cual es la diferencia de precio entre la carta mas cara, y la mas barata en holofoil?
WITH latest AS (
  SELECT p.*
  FROM Precios_Cartas p
  JOIN (
    SELECT Carta_id, 
    MAX(TCG_Price_Date) AS max_date
    FROM Precios_Cartas
    GROUP BY Carta_id
  ) AS sub ON p.Carta_id = sub.Carta_id 
  AND p.TCG_Price_Date = sub.max_date
),
max_price AS (
  SELECT *
  FROM latest
  WHERE Avg_Foil = (SELECT MAX(Avg_Foil) FROM latest WHERE Avg_Foil IS NOT NULL)
),
min_price AS (
  SELECT *
  FROM latest
  WHERE Avg_Foil = (SELECT MIN(Avg_Foil) FROM latest WHERE Avg_Foil IS NOT NULL)
)
SELECT
  c_max.Nombre AS carta_mas_cara,
  c_min.Nombre AS carta_mas_barata,
  max_price.Avg_Foil AS precio_cara,
  min_price.Avg_Foil AS precio_barata,
  max_price.Avg_Foil - min_price.Avg_Foil AS diferencia
FROM
(max_price JOIN Cartas AS c_max ON max_price.Carta_id = c_max.Id),
(min_price JOIN Cartas AS c_min ON min_price.Carta_id = c_min.Id);

-- Cuantas cartas tienen precios disponibles en todas las condiciones (normal, reverse, holofoil)?
SELECT
COUNT(DISTINCT p.Carta_id) AS cartas_con_todos_los_precios
FROM Precios_Cartas AS p
WHERE
p.Avg_Normal IS NOT NULL
AND p.Avg_Reverse IS NOT NULL
AND p.Avg_Foil IS NOT NULL;

-- Cual fue la fecha mas reciente de actualizacion de precios?
SELECT
MAX(TCG_Price_Date) AS fecha_mas_reciente
FROM Precios_Cartas;

-- Cuales son las 3 cartas con la mayor diferencia entre el precio mas alto y el mas bajo en holofoil?
SELECT
c.Nombre AS top3_diferencia,
c.Pokedex_numb AS pokedex,
c.Set_name AS set_name,
c.Rarity AS rarity,
p.High_Foil AS precio_alto,
p.Low_Foil AS precio_bajo,
p.High_Foil - p.Low_Foil AS diferencia
FROM Precios_Cartas AS p
JOIN Cartas AS c ON p.Carta_id = c.Id
JOIN (
    SELECT
    p.Carta_id,
    MAX(TCG_Price_Date) AS max_date
    FROM Precios_Cartas AS p
    GROUP BY p.Carta_id
) AS latest ON p.Carta_id = latest.Carta_id AND p.TCG_Price_Date = latest.max_date
WHERE p.High_Foil IS NOT NULL
AND p.Low_Foil IS NOT NULL
ORDER BY diferencia DESC
LIMIT 3;

-- Cual es la carta mas cara de cada tipo de Pokemon?
SELECT DISTINCT ON (e.Types)
c.Nombre AS carta_mas_cara,
e.Types AS tipo_pokemon,
v.tipo AS tipo_carta,
v.precio AS precio
FROM Precios_Cartas p
JOIN Cartas c ON p.Carta_id = c.Id
JOIN Estadistica_Cartas e ON p.Carta_id = e.Carta_id
CROSS JOIN LATERAL (
VALUES
('Foil', p.Avg_Foil),
('Normal', p.Avg_Normal),
('Reverse', p.Avg_Reverse)
) 
AS v(tipo, precio)
JOIN (
    SELECT
    p.Carta_id,
    MAX(TCG_Price_Date) AS max_date
    FROM Precios_Cartas AS p
    GROUP BY p.Carta_id
) AS latest ON p.Carta_id = latest.Carta_id AND p.TCG_Price_Date = latest.max_date
WHERE p.TCG_Price_DATE = (SELECT MAX(TCG_Price_DATE) FROM Precios_Cartas)
AND v.precio IS NOT NULL
AND e.Types IS NOT NULL
ORDER BY e.Types, v.precio DESC;