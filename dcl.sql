-- Definición de usuarios
-- 1. Administrador
GRANT ALL PRIVILEGES ON Hacienda_AgroNova.* TO 'admin'@'localhost' IDENTIFIED BY 'admin_password';

-- 2. Vendedor
GRANT SELECT, INSERT, UPDATE ON Hacienda_AgroNova.Ventas TO 'vendedor'@'localhost' IDENTIFIED BY 'vendedor_password';
GRANT SELECT, INSERT, UPDATE ON Hacienda_AgroNova.Detalles_venta TO 'vendedor'@'localhost';
GRANT SELECT ON Hacienda_AgroNova.Productos TO 'vendedor'@'localhost';

-- 3. Contador
GRANT SELECT ON Hacienda_AgroNova.Ventas TO 'contador'@'localhost' IDENTIFIED BY 'contador_password';
GRANT SELECT ON Hacienda_AgroNova.Detalles_venta TO 'contador'@'localhost';
GRANT SELECT ON Hacienda_AgroNova.Compras TO 'contador'@'localhost';
GRANT SELECT ON Hacienda_AgroNova.Reportes_* TO 'contador'@'localhost';

-- 4. Supervisor de Producción
GRANT SELECT, INSERT, UPDATE ON Hacienda_AgroNova.Producciones TO 'supervisor_produccion'@'localhost' IDENTIFIED BY 'sup_prod_password';
GRANT SELECT, INSERT, UPDATE ON Hacienda_AgroNova.Tareas TO 'supervisor_produccion'@'localhost';
GRANT SELECT, INSERT, UPDATE ON Hacienda_AgroNova.Cultivos TO 'supervisor_produccion'@'localhost';
GRANT SELECT, INSERT, UPDATE ON Hacienda_AgroNova.Animales TO 'supervisor_produccion'@'localhost';
GRANT SELECT, INSERT, UPDATE ON Hacienda_AgroNova.Insumos TO 'supervisor_produccion'@'localhost';

-- 5. Gerente de Inventario
GRANT SELECT, INSERT, UPDATE ON Hacienda_AgroNova.Productos TO 'gerente_inventario'@'localhost' IDENTIFIED BY 'gerente_inventario_password';
GRANT SELECT, INSERT, UPDATE ON Hacienda_AgroNova.Insumos TO 'gerente_inventario'@'localhost';
GRANT SELECT, INSERT, UPDATE ON Hacienda_AgroNova.Activos_insumos TO 'gerente_inventario'@'localhost';
GRANT SELECT, INSERT, UPDATE ON Hacienda_AgroNova.Locaciones_almacenamiento TO 'gerente_inventario'@'localhost';
GRANT SELECT, INSERT, UPDATE ON Hacienda_AgroNova.Productos_en_locacion TO 'gerente_inventario'@'localhost';
