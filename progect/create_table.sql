CREATE TABLE stock_dim (
    stock_id SERIAL PRIMARY KEY,
    ticker VARCHAR(10) NOT NULL,
    company_name VARCHAR(100) NOT NULL,
    sector VARCHAR(50),
    industry VARCHAR(50),
    ISIN VARCHAR(12)
);

CREATE TABLE trader_dim (
    trader_id SERIAL PRIMARY KEY,
    trader_name VARCHAR(100) NOT NULL,
    account_type VARCHAR(50),
    register_date DATE,
    location VARCHAR(100)
);

CREATE TABLE trades (
    trade_id SERIAL PRIMARY KEY,
    stock_id INT NOT NULL,
    trader_id INT NOT NULL,
    quantity INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    total_value DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (stock_id) REFERENCES stock_dim(stock_id),
    FOREIGN KEY (trader_id) REFERENCES trader_dim(trader_id)
);