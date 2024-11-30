INSERT INTO stockDim (ticker, companyName, sector, industry, ISIN) VALUES
('AAPL', 'Apple', 'Technology', 'Consumer Electronics', 'US0378331005'),
('GOOGL', 'Alphabet.', 'Communication Services', 'Internet Content', 'US02079K3059'),
('AMZN', 'Amazon.com.', 'Consumer Discretionary', 'Internet Retail', 'US0231351067'),
('MSFT', 'Microsoft', 'Technology', 'Software', 'US5949181045'),
('TSLA', 'Tesla', 'Consumer Discretionary', 'Automobile Manufacturers', 'US88160R1014');

INSERT INTO traderDim (traderName, accountType, registerDate, location) VALUES
('John Doe', 'Personal', '2022-01-15', 'New York'),
('Jane Smith', 'Brokerage', '2021-05-20', 'Los Angeles'),
('Alice Johnson', 'Personal', '2020-11-10', 'Chicago'),
('Bob Brown', 'Institutional', '2022-03-30', 'Houston'),
('Charlie White', 'Personal', '2023-02-01', 'Seattle');

INSERT INTO trades (stockID, traderID, quantity, price, totalValue) VALUES
(1, 1, 10, 150.00, 1500.00),
(2, 2, 5, 2800.00, 14000.00),
(3, 3, 20, 3200.00, 64000.00),
(4, 4, 15, 250.00, 3750.00),
(5, 5, 8, 700.00, 5600.00);
