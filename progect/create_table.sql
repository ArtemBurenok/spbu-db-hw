CREATE TABLE StockDim (
    StockID SERIAL PRIMARY KEY,
    Ticker VARCHAR(10) NOT NULL,
    CompanyName VARCHAR(100) NOT NULL,
    Sector VARCHAR(50),
    Industry VARCHAR(50),
    ISIN VARCHAR(12)
);

CREATE TABLE TraderDim (
    TraderID SERIAL PRIMARY KEY,
    TraderName VARCHAR(100) NOT NULL,
    AccountType VARCHAR(50),
    RegisterDate DATE,
    Location VARCHAR(100)
);

CREATE TABLE Trades (
    TradeID SERIAL PRIMARY KEY,
    StockID INT NOT NULL,
    TraderID INT NOT NULL,
    Quantity INT NOT NULL,
    Price DECIMAL(10, 2) NOT NULL,
    TotalValue DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (StockID) REFERENCES StockDim(StockID),
    FOREIGN KEY (TraderID) REFERENCES TraderDim(TraderID)
);