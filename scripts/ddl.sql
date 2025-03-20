CREATE TABLE Cartas (
    Id VARCHAR(50) PRIMARY KEY NOT NULL,
    Nombre VARCHAR(100) NOT NULL,
    Pokedex_numb INT,
    Supertype VARCHAR(50),
    Subtypes VARCHAR(50),
    Set_name VARCHAR(50),
    Realease_Date DATE NOT NULL,
    Artist VARCHAR(80),
    Rarity VARCHAR(50),
    Small_Card_Img VARCHAR(255) NOT NULL,
    HiRes_Card_Img VARCHAR(255) NOT NULL,
    TCG_Player VARCHAR(255)
);

CREATE TABLE Estadistica_Cartas (
    Id SERIAL PRIMARY KEY NOT NULL,
    Carta_id VARCHAR(50) NOT NULL REFERENCES Cartas(Id),
    HP int, 
    Types VARCHAR(50),
    Attacks VARCHAR(255),
    Weaknesses VARCHAR(80),
    Retreat_Cost INT
);

CREATE TABLE Precios_Cartas (
    Id SERIAL PRIMARY KEY NOT NULL,
    Carta_id VARCHAR(50) NOT NULL REFERENCES Cartas(Id),
    TCG_Price_Date DATE,

    Avg_Normal Numeric(10,2),
    Low_Normal Numeric(10,2),
    High_Normal Numeric(10,2),

    Avg_Reverse Numeric(10,2),
    Low_Reverse Numeric(10,2),
    High_Reverse Numeric(10,2),

    Avg_Foil Numeric(10,2),
    Low_Foil Numeric(10,2),
    High_Foil Numeric(10,2)
);
