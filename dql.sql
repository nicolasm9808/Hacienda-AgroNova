-- CONSULTAS AGRONOVA --

-- 1. Productos disponibles en stock.
SELECT nombre AS Nombre_Producto, ROUND(precio_venta, 2) AS Precio_Venta, ROUND(precio_compra, 2) AS Precio_Compra, cantidad AS Cantidad_Disponible 
FROM Productos 
WHERE cantidad > 0;
-- Muestra los productos disponibles en stock con precios redondeados a 2 decimales.

-- 2. Productos con precio superior a un monto.
SELECT nombre AS Nombre_Producto, ROUND(precio_venta, 2) AS Precio_Venta 
FROM Productos 
WHERE precio_venta > 1000;
-- Muestra los productos con un precio de venta superior a 1000.

-- 3. Total de ventas por producto.
SELECT p.nombre AS Nombre_Producto, SUM(dv.cantidad) AS Total_Vendido, ROUND(SUM(dv.cantidad * p.precio_venta), 2) AS Total_Ingresos 
FROM Detalles_venta dv
JOIN Productos p ON p.id_producto = dv.id_producto
GROUP BY p.nombre;
-- Muestra el total vendido y total de ingresos por producto.

-- 4. Productos con mayor margen de ganancia.
SELECT nombre AS Nombre_Producto, ROUND(precio_venta - precio_compra, 2) AS Margen_Ganancia 
FROM Productos 
WHERE precio_venta > precio_compra 
ORDER BY Margen_Ganancia DESC LIMIT 10;
-- Muestra los productos con mayor margen de ganancia.

-- 5. Promedio de precio de venta por categoría.
SELECT c.nombre AS Categoria, ROUND(AVG(p.precio_venta), 2) AS Promedio_Precio_Venta 
FROM Productos p
JOIN Categorias c ON c.id_categoria = p.id_categoria
GROUP BY c.nombre;
-- Muestra el promedio de precio de venta agrupado por categoría.

-- 6.Total de ventas realizadas en un periodo.
SELECT COUNT(*) AS Total_Ventas, ROUND(SUM(total), 2) AS Total_Ingresos 
FROM Ventas 
WHERE fecha BETWEEN '2024-01-01' AND '2024-12-31';
-- Muestra el total de ventas y total de ingresos en un periodo específico.

-- 7. Clientes que más compran.
SELECT cl.nombre AS Nombre_Cliente, COUNT(v.id_venta) AS Total_Ventas, ROUND(SUM(v.total), 2) AS Total_Ingresos 
FROM Clientes cl
JOIN Ventas v ON v.id_cliente = cl.id_cliente
GROUP BY cl.nombre
ORDER BY Total_Ingresos DESC LIMIT 5;
-- Muestra los cinco clientes que más compran y el total de ingresos.

-- 8. Ventas diarias en el último mes.
SELECT DATE(fecha) AS Fecha, ROUND(SUM(total), 2) AS Total_Ventas 
FROM Ventas 
WHERE fecha >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
GROUP BY DATE(fecha);
-- Muestra las ventas diarias en el último mes.

-- 9. Productos más vendidos.
SELECT p.nombre AS Nombre_Producto, SUM(dv.cantidad) AS Total_Vendidos 
FROM Detalles_venta dv
JOIN Productos p ON p.id_producto = dv.id_producto
GROUP BY p.nombre
ORDER BY Total_Vendidos DESC LIMIT 10;
-- Muestra los productos más vendidos.

-- 10. Ventas por región.
SELECT r.nombre AS Region, COUNT(v.id_venta) AS Total_Ventas, ROUND(SUM(v.total), 2) AS Total_Ingresos 
FROM Ventas v
JOIN Regiones r ON r.id_region = v.id_region
GROUP BY r.nombre;
-- Muestra las ventas y total de ingresos por región.

-- 11. Clientes que nunca han comprado.
SELECT cl.nombre AS Nombre_Cliente 
FROM Clientes cl
LEFT JOIN Ventas v ON v.id_cliente = cl.id_cliente
WHERE v.id_venta IS NULL;
-- Muestra los clientes que nunca han realizado una compra.

-- 12. Top 10 clientes por monto de compras.
SELECT cl.nombre AS Nombre_Cliente, ROUND(SUM(v.total), 2) AS Total_Compras 
FROM Clientes cl
JOIN Ventas v ON v.id_cliente = cl.id_cliente
GROUP BY cl.nombre
ORDER BY Total_Compras DESC LIMIT 10;
-- Muestra los diez clientes con mayor monto de compras.

-- 13. Clientes con más de una compra.
SELECT cl.nombre AS Nombre_Cliente 
FROM Clientes cl
JOIN Ventas v ON v.id_cliente = cl.id_cliente
GROUP BY cl.nombre
HAVING COUNT(v.id_venta) > 1;
-- Muestra los clientes que han realizado más de una compra.

-- 14. Clientes activos en el último año.
SELECT cl.nombre AS Nombre_Cliente 
FROM Clientes cl
JOIN Ventas v ON v.id_cliente = cl.id_cliente
WHERE v.fecha >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
GROUP BY cl.nombre;
-- Muestra los clientes que han realizado compras en el último año.

-- 15. Promedio de gasto por cliente.
SELECT ROUND(AVG(v.total), 2) AS Promedio_Gasto 
FROM Ventas v;
-- Muestra el promedio de gasto por cliente.

--16. Proveedores que suministran más de un producto.
SELECT pr.nombre AS Nombre_Proveedor, COUNT(p.id_producto) AS Total_Productos 
FROM Proveedores pr
JOIN Productos p ON p.id_proveedor = pr.id_proveedor
GROUP BY pr.nombre
HAVING Total_Productos > 1;
-- Muestra los proveedores que suministran más de un producto.

-- 17. Top 5 proveedores por monto total de compras.
SELECT pr.nombre AS Nombre_Proveedor, ROUND(SUM(c.total), 2) AS Total_Compras 
FROM Compras c
JOIN Proveedores pr ON pr.id_proveedor = c.id_proveedor
GROUP BY pr.nombre
ORDER BY Total_Compras DESC LIMIT 5;
-- Muestra los cinco proveedores con mayor monto total de compras.

-- 18. Compras por proveedor en el último año.
SELECT pr.nombre AS Nombre_Proveedor, ROUND(SUM(c.total), 2) AS Total_Compras 
FROM Compras c
JOIN Proveedores pr ON pr.id_proveedor = c.id_proveedor
WHERE c.fecha >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
GROUP BY pr.nombre;
-- Muestra las compras realizadas a cada proveedor en el último año.

-- 19. Cantidad de productos comprados por proveedor.
SELECT pr.nombre AS Nombre_Proveedor, SUM(dc.cantidad) AS Total_Productos 
FROM Detalles_compra dc
JOIN Compras c ON c.id_compra = dc.id_compra
JOIN Proveedores pr ON pr.id_proveedor = c.id_proveedor
GROUP BY pr.nombre;
-- Muestra la cantidad total de productos comprados a cada proveedor.

-- 20. Proveedores que no han realizado ventas.
SELECT 
pr.nombre AS Nombre_Proveedor 
FROM Proveedores pr
LEFT JOIN Productos p ON p.id_proveedor = pr.id_proveedor
LEFT JOIN Ventas v ON v.id_producto = p.id_producto
WHERE v.id_venta IS NULL;
-- Muestra los proveedores que no han tenido ventas.

-- 21. Total de compras por mes.
SELECT MONTH(fecha) AS Mes, ROUND(SUM(total), 2) AS Total_Compras 
FROM Compras 
GROUP BY MONTH(fecha);
-- Muestra el total de compras agrupado por mes.

-- 22. Número total de productos en inventario.
SELECT COUNT(*) AS Total_Productos 
FROM Productos 
WHERE cantidad > 0;
-- Muestra el número total de productos en inventario.

-- 23. Costo total de inventario de productos.
SELECT ROUND(SUM(cantidad * precio_compra), 2) AS Costo_Total_Inventario 
FROM Productos;
-- Muestra el costo total del inventario.

-- 24. Número total de clientes registrados.
SELECT COUNT(*) AS Total_Clientes 
FROM Clientes;
-- Muestra el número total de clientes registrados.

-- 25. Total de ventas por año.
SELECT YEAR(fecha) AS Año, ROUND(SUM(total), 2) AS Total_Ventas 
FROM Ventas 
GROUP BY YEAR(fecha);
-- Muestra el total de ventas agrupado por año.

-- 26. Total de gastos por mes.
SELECT MONTH(fecha) AS Mes, ROUND(SUM(monto), 2) AS Total_Gastos 
FROM Gastos 
GROUP BY MONTH(fecha);
-- Muestra el total de gastos agrupado por mes.

-- 27. Comparación de ingresos y gastos por mes.
SELECT MONTH(fecha) AS Mes, ROUND(SUM(v.total), 2) AS Total_Ingresos, ROUND(SUM(g.monto), 2) AS Total_Gastos 
FROM Ventas v
LEFT JOIN Gastos g ON MONTH(v.fecha) = MONTH(g.fecha)
GROUP BY MONTH(v.fecha);
-- Muestra la comparación de ingresos y gastos agrupados por mes.

-- 28. Top 5 gastos más altos.
SELECT descripcion AS Descripcion_Gasto, ROUND(monto, 2) AS Monto 
FROM Gastos 
ORDER BY monto DESC LIMIT 5;
-- Muestra los cinco gastos más altos.

-- 29. Total de gastos por categoría.
SELECT c.nombre AS Categoria, ROUND(SUM(g.monto), 2) AS Total_Gastos 
FROM Gastos g
JOIN Categorias_Gastos c ON c.id_categoria = g.id_categoria
GROUP BY c.nombre;
-- Muestra el total de gastos agrupado por categoría.

-- 30. Ingresos y gastos totales.
SELECT ROUND(SUM(v.total), 2) AS Total_Ingresos, ROUND(SUM(g.monto), 2) AS Total_Gastos 
FROM Ventas v, Gastos g;
-- Muestra los ingresos y gastos totales.

-- 31. Cantidad total de productos en inventario.
SELECT SUM(cantidad) AS Total_Productos 
FROM Productos;
-- Muestra la cantidad total de productos en el inventario.

-- 32. Productos que requieren reabastecimiento.
SELECT nombre AS Nombre_Producto, cantidad AS Cantidad_Disponible 
FROM Productos 
WHERE cantidad < 10;
-- Muestra los productos que requieren reabastecimiento.

-- 33. Historial de producción por producto.
SELECT p.nombre AS Nombre_Producto, SUM(op.cantidad) AS Total_Producido 
FROM Ordenes_Produccion op
JOIN Productos p ON p.id_producto = op.id_producto
GROUP BY p.nombre;
-- Muestra el historial de producción por producto.

-- 34. Costo total de producción.
SELECT ROUND(SUM(op.costo_total), 2) AS Costo_Total_Produccion 
FROM Ordenes_Produccion op;
-- Muestra el costo total de producción.

-- 35. Producción por mes.
SELECT MONTH(fecha) AS Mes, ROUND(SUM(cantidad), 2) AS Total_Produccion 
FROM Ordenes_Produccion 
GROUP BY MONTH(fecha);
-- Muestra la producción agrupada por mes.

-- 36. Análisis de venta por horario.
SELECT HOUR(fecha) AS Hora, ROUND(SUM(total), 2) AS Total_Ventas 
FROM Ventas 
GROUP BY HOUR(fecha);
-- Muestra el análisis de ventas por hora.

-- 37. Clientes que han realizado más de una compra.
SELECT cl.nombre AS Nombre_Cliente 
FROM Clientes cl
JOIN Ventas v ON v.id_cliente = cl.id_cliente
GROUP BY cl.nombre
HAVING COUNT(v.id_venta) > 1;
-- Muestra los clientes que han realizado más de una compra.

-- 38. Ventas en el último año.
SELECT YEAR(fecha) AS Año, ROUND(SUM(total), 2) AS Total_Ventas 
FROM Ventas 
WHERE fecha >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
GROUP BY YEAR(fecha);
-- Muestra las ventas realizadas en el último año.

-- 39. Cantidad de productos vendidos por categoría.
SELECT c.nombre AS Categoria, SUM(dv.cantidad) AS Total_Vendidos 
FROM Detalles_venta dv
JOIN Productos p ON p.id_producto = dv.id_producto
JOIN Categorias c ON c.id_categoria = p.id_categoria
GROUP BY c.nombre;
-- Muestra la cantidad de productos vendidos agrupados por categoría.

-- 40. Clientes que han realizado compras en el último mes.
SELECT cl.nombre AS Nombre_Cliente 
FROM Clientes cl
JOIN Ventas v ON v.id_cliente = cl.id_cliente
WHERE v.fecha >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
GROUP BY cl.nombre;
-- Muestra los clientes que han realizado compras en el último mes.

-- 41. Total de ganancias del último año.
SELECT YEAR(fecha) AS Año, ROUND(SUM(total - (SELECT SUM(monto) FROM Gastos WHERE YEAR(fecha) = YEAR(v.fecha))), 2) AS Ganancias 
FROM Ventas v 
WHERE fecha >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
GROUP BY YEAR(fecha);
-- Muestra las ganancias totales del último año.

-- 42. 