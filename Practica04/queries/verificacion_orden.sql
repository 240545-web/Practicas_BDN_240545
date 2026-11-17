SELECT ID, `key`, total_products, total_cost, status_string 
FROM tb_orders WHERE user_ID = 241970 ORDER BY ID DESC;
-- Te debe salir solo la 359 con 500.00 completed