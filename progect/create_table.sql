CREATE TABLE stockDim (
    stockID SERIAL PRIMARY KEY,
    ticker VARCHAR(10) NOT NULL,
    companyName VARCHAR(100) NOT NULL,
    sector VARCHAR(50),
    industry VARCHAR(50),
    ISIN VARCHAR(12)
);

CREATE TABLE traderDim (
    traderID SERIAL PRIMARY KEY,
    traderName VARCHAR(100) NOT NULL,
    accountType VARCHAR(50),
    registerDate DATE,
    location VARCHAR(100)
);

CREATE TABLE trades (
    tradeID SERIAL PRIMARY KEY,
    stockID INT NOT NULL,
    traderID INT NOT NULL,
    quantity INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    totalValue DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (stockID) REFERENCES stockDim(stockID),
    FOREIGN KEY (traderID) REFERENCES traderDim(traderID)
);