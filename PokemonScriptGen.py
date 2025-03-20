import pandas as pd

def format_value(value):
    if pd.isna(value) or value == "":  # Si es NaN o vacío, usar NULL
        return "NULL"
    
    if isinstance(value, float) and value.is_integer():  
        return str(int(value)) 
    
    value = str(value).strip() 
    
    value = value.replace("'", "''")

    return f"'{value}'" 


# Cargar datos 
modern_df = pd.read_csv('resources/modern_pkmn_cards_feb2025.csv', skiprows=1)
vintage_df = pd.read_csv('resources/vintage_pkmn_cards_feb2025.csv', skiprows=1)

modern_df_mar = pd.read_csv('resources/modern_pkmn_cards_mar2025.csv', skiprows=1)
vintage_df_mar = pd.read_csv('resources/vintage_pkmn_cards_mar2025.csv', skiprows=1)

# Comenzar a generar el script
columnas_datos_carta = [0, 1, 2, 3, 4, 10, 11, 12, 13, 14, 15, 16]
columnas_estadistica = [0, 5, 6, 7, 8, 9]
columnas_precios = [0, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26]

# ArrayLists
datos_cartas = []
estadisticas = []
precios = []

# Llenar datos de cartas
for i in range(len(modern_df)):
    valores_datos = modern_df.iloc[i, columnas_datos_carta]
    valores_estadistica = modern_df.iloc[i, columnas_estadistica]
    valores_precios = modern_df.iloc[i, columnas_precios]

    # Llenar datos
    datos_cartas.append(valores_datos)
    estadisticas.append(valores_estadistica)
    precios.append(valores_precios)

for i in range (len(vintage_df)):
    valores_datos = vintage_df.iloc[i, columnas_datos_carta]
    valores_estadistica = vintage_df.iloc[i, columnas_estadistica]
    valores_precios = vintage_df.iloc[i, columnas_precios]

    # Llenar datos
    datos_cartas.append(valores_datos)
    estadisticas.append(valores_estadistica)
    precios.append(valores_precios)

# Datos del mes presente de precios
for i in range(len(modern_df_mar)):
    valores_precios = modern_df_mar.iloc[i, columnas_precios]

    # Llenar datos
    precios.append(valores_precios)

for i in range (len(vintage_df_mar)):
    valores_precios = vintage_df_mar.iloc[i, columnas_precios]

    # Llenar datos
    precios.append(valores_precios)

# Generar script SQL
# Validar que el archivo este vacio
with open("scripts/dml.sql", "r") as file:
    contenido = file.read()

if not contenido:
    with open("scripts/dml.sql", "w") as dml:
        # INSERT para Cartas
        dml.write("INSERT INTO Cartas (Id, Nombre, Pokedex_numb, Supertype, Subtypes, Set_name, Realease_Date, Artist, Rarity, Small_Card_Img, HiRes_Card_Img, TCG_Player) VALUES\n")
        
        for i, carta in enumerate(datos_cartas):
            valores = [format_value(carta.iloc[col]) for col in range(12)]
            separator = "," if i < len(datos_cartas) - 1 else ""  # Última fila sin coma
            dml.write(f"({', '.join(valores)}){separator}\n")
        
        dml.write(";\n\n")

        # INSERT para Estadísticas de Cartas
        dml.write("INSERT INTO Estadistica_Cartas (Carta_Id, HP, Types, Attacks, Weaknesses, Retreat_Cost) VALUES\n")

        for i, estadistica in enumerate(estadisticas):
            valores = [format_value(estadistica.iloc[col]) for col in range(6)]
            separator = "," if i < len(estadisticas) - 1 else ""  # Última fila sin coma
            dml.write(f"({', '.join(valores)}){separator}\n")

        dml.write(";\n\n")

        # INSERT para Precios de Cartas
        dml.write("INSERT INTO Precios_Cartas (Carta_Id, TCG_Price_Date, Avg_Normal, Low_Normal, High_Normal, Avg_Reverse, Low_Reverse, High_Reverse, Avg_Foil, Low_Foil, High_Foil) VALUES\n")

        for i, precio in enumerate(precios):
            valores = [format_value(precio.iloc[col]) for col in range(11)]
            separator = "," if i < len(precios) - 1 else ""  # Última fila sin coma
            dml.write(f"({', '.join(valores)}){separator}\n")

        dml.write(";\n\n")
    print("Script generado con éxito")

else:
    print("El archivo ya contiene información, no se generará el script")

