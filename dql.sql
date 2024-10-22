-- 1. Inventario total de productos por locación
SELECT l.nombre AS locacion, p.nombre AS producto, pl.cantidad AS cantidad_disponible
FROM Productos_en_locacion pl
JOIN Productos p ON pl.id_producto = p.id_producto
JOIN Locaciones_almacenamiento l ON pl.id_locacion = l.id_locacion;

-- 2. Productos que están agotados en alguna locación
SELECT l.nombre AS locacion, p.nombre AS producto
FROM Productos_en_locacion pl
JOIN Productos p ON pl.id_producto = p.id_producto
JOIN Locaciones_almacenamiento l ON pl.id_locacion = l.id_locacion
WHERE pl.cantidad = 0;

-- 3. Productos con cantidad menor a cierto umbral
SELECT p.nombre AS producto, SUM(pl.cantidad) AS total_disponible
FROM Productos_en_locacion pl
JOIN Productos p ON pl.id_producto = p.id_producto
GROUP BY p.id_producto
HAVING SUM(pl.cantidad) < 10;

-- 4. Productos que ocupan más espacio que la capacidad disponible de las locaciones
SELECT l.nombre AS locacion, SUM(pl.cantidad) AS cantidad_total, l.capacidad_maxima, l.capacidad_disponible
FROM Productos_en_locacion pl
JOIN Locaciones_almacenamiento l ON pl.id_locacion = l.id_locacion
GROUP BY l.id_locacion
HAVING SUM(pl.cantidad) > l.capacidad_disponible;

-- 5. Producción mensual por tipo de cultivo
SELECT DATE_FORMAT(p.fecha, '%Y-%m') AS mes, c.nombre AS cultivo, COUNT(cp.id_cultivo) AS cantidad_producida
FROM Producciones p
JOIN Cultivos_para_produccion cp ON p.id_produccion = cp.id_produccion
JOIN Cultivos c ON cp.id_cultivo = c.id_cultivo
GROUP BY mes, c.id_cultivo;

-- 6. Costo total de producción por mes
SELECT DATE_FORMAT(p.fecha, '%Y-%m') AS mes, SUM(p.costo) AS costo_total
FROM Producciones p
GROUP BY mes;

-- 7. Animales involucrados en la producción por mes
SELECT DATE_FORMAT(p.fecha, '%Y-%m') AS mes, COUNT(ap.id_animal) AS cantidad_animales
FROM Producciones p
JOIN Animales_para_produccion ap ON p.id_produccion = ap.id_produccion
GROUP BY mes;

-- 8. Resumen mensual de costos de producción por tipo de producto
SELECT DATE_FORMAT(p.fecha, '%Y-%m') AS mes, tp.tipo AS tipo_producto, SUM(pr.precio * pp.cantidad) AS total_ventas
FROM Producciones p
JOIN Productos_de_produccion pp ON p.id_produccion = pp.id_produccion
JOIN Productos pr ON pp.id_producto = pr.id_producto
JOIN Tipos_producto tp ON pr.id_tipo_producto = tp.id_tipo_producto
GROUP BY mes, tp.tipo;

-- 9. Ventas por empleado en el último mes
SELECT e.nombre AS empleado, COUNT(v.id_venta) AS ventas_realizadas, SUM(v.total) AS total_ventas
FROM Ventas v
JOIN Empleados e ON v.id_empleado = e.id_empleado
WHERE MONTH(v.fecha) = MONTH(CURRENT_DATE) AND YEAR(v.fecha) = YEAR(CURRENT_DATE)
GROUP BY e.id_empleado;

-- 10. Clientes con mayor volumen de compras en el último año
SELECT c.nombre AS cliente, SUM(v.total) AS total_compras
FROM Ventas v
JOIN Clientes c ON v.id_cliente = c.id_cliente
WHERE v.fecha BETWEEN DATE_SUB(CURRENT_DATE, INTERVAL 1 YEAR) AND CURRENT_DATE
GROUP BY c.id_cliente
ORDER BY total_compras DESC
LIMIT 10;

-- 11. Ventas por mes
SELECT DATE_FORMAT(v.fecha, '%Y-%m') AS mes, SUM(v.total) AS total_ventas
FROM Ventas v
GROUP BY mes;

-- 12. Detalle de ventas de productos por empleado
SELECT e.nombre AS empleado, p.nombre AS producto, SUM(dv.cantidad) AS cantidad_vendida
FROM Detalles_venta dv
JOIN Productos p ON dv.id_producto = p.id_producto
JOIN Ventas v ON dv.id_venta = v.id_venta
JOIN Empleados e ON v.id_empleado = e.id_empleado
GROUP BY e.id_empleado, p.id_producto;

-- 13. Total de compras realizadas a proveedores en el último año
SELECT pr.nombre AS proveedor, SUM(c.total) AS total_compras
FROM Compras c
JOIN Proveedores pr ON c.id_proveedor = pr.id_proveedor
WHERE c.fecha BETWEEN DATE_SUB(CURRENT_DATE, INTERVAL 1 YEAR) AND CURRENT_DATE
GROUP BY pr.id_proveedor
ORDER BY total_compras DESC;

-- 14. Detalles de compras por proveedor y por producto
SELECT pr.nombre AS proveedor, a.nombre AS activo, SUM(dc.cantidad) AS cantidad_comprada
FROM Detalles_compra dc
JOIN Activos_insumos a ON dc.id_activo = a.id_activo
JOIN Compras c ON dc.id_compra = c.id_compra
JOIN Proveedores pr ON c.id_proveedor = pr.id_proveedor
GROUP BY pr.id_proveedor, a.id_activo;

-- 15. Costo promedio de compras por tipo de activo
SELECT ca.nombre AS categoria, AVG(dc.precio_unitario) AS precio_promedio
FROM Detalles_compra dc
JOIN Activos_insumos a ON dc.id_activo = a.id_activo
JOIN Categorias ca ON a.id_categoria = ca.id_categoria
GROUP BY ca.id_categoria;

-- 16. Costo total de producción por mes
SELECT DATE_FORMAT(p.fecha, '%Y-%m') AS mes, SUM(p.costo) AS costo_total
FROM Producciones p
GROUP BY mes;

-- 17. Costo total de compras por mes
SELECT DATE_FORMAT(c.fecha, '%Y-%m') AS mes, SUM(c.total) AS costo_total_compras
FROM Compras c
GROUP BY mes;

-- 18. Costos operativos totales (producción + compras) por mes
SELECT prod.mes, (prod.costo_total + comp.costo_total_compras) AS costo_operativo_total
FROM (SELECT DATE_FORMAT(p.fecha, '%Y-%m') AS mes, SUM(p.costo) AS costo_total
      FROM Producciones p
      GROUP BY mes) prod
JOIN (SELECT DATE_FORMAT(c.fecha, '%Y-%m') AS mes, SUM(c.total) AS costo_total_compras
      FROM Compras c
      GROUP BY mes) comp
ON prod.mes = comp.mes;

-- 19. Desglose mensual de costos por categoría de activo
SELECT DATE_FORMAT(c.fecha, '%Y-%m') AS mes, ca.nombre AS categoria, SUM(dc.precio_unitario * dc.cantidad) AS costo_total
FROM Detalles_compra dc
JOIN Activos_insumos a ON dc.id_activo = a.id_activo
JOIN Categorias ca ON a.id_categoria = ca.id_categoria
JOIN Compras c ON dc.id_compra = c.id_compra
GROUP BY mes, ca.id_categoria;

-- 20. Empleados con más tareas asignadas en el último mes
SELECT e.nombre AS empleado, COUNT(te.id_tarea) AS tareas_asignadas
FROM Empleados_en_tarea te
JOIN Empleados e ON te.id_empleado = e.id_empleado
JOIN Tareas t ON te.id_tarea = t.id_tarea
WHERE MONTH(t.fecha) = MONTH(CURRENT_DATE) AND YEAR(t.fecha) = YEAR(CURRENT_DATE)
GROUP BY e.id_empleado
ORDER BY tareas_asignadas DESC;

-- 21. Desempeño mensual de empleados por tareas completadas
SELECT e.nombre AS empleado, COUNT(t.id_tarea) AS tareas_completadas
FROM Empleados_en_tarea et
JOIN Empleados e ON et.id_empleado = e.id_empleado
JOIN Tareas t ON et.id_tarea = t.id_tarea
JOIN Estados_tarea est ON t.id_estado = est.id_estado
WHERE est.estado = 'Completada'
GROUP BY e.id_empleado
ORDER BY tareas_completadas DESC;

-- 22. Salario total mensual por empleado
SELECT e.nombre AS empleado, e.salario, COUNT(h.id_horario) AS dias_trabajados, 
       (e.salario / 30) * COUNT(h.id_horario) AS salario_mensual
FROM Empleados e
JOIN Horarios h ON e.id_empleado = h.id_empleado
GROUP BY e.id_empleado;

-- 23. Empleados con más horas trabajadas en el último mes
SELECT e.nombre AS empleado, SUM(TIMESTAMPDIFF(HOUR, h.hora_inicio, h.hora_fin)) AS horas_totales
FROM Empleados e
JOIN Horarios h ON e.id_empleado = h.id_empleado
WHERE MONTH(h.hora_inicio) = MONTH(CURRENT_DATE) AND YEAR(h.hora_inicio) = YEAR(CURRENT_DATE)
GROUP BY e.id_empleado
ORDER BY horas_totales DESC;

-- 24. Empleados que han trabajado más de 8 horas en un solo día
SELECT e.nombre AS empleado, h.id_dia, SUM(TIMESTAMPDIFF(HOUR, h.hora_inicio, h.hora_fin)) AS horas_trabajadas
FROM Empleados e
JOIN Horarios h ON e.id_empleado = h.id_empleado
GROUP BY e.id_empleado, h.id_dia
HAVING horas_trabajadas > 8;

-- 25. Empleados que no han trabajado en los últimos 7 días
SELECT e.nombre AS empleado
FROM Empleados e
WHERE e.id_empleado NOT IN (
    SELECT DISTINCT h.id_empleado
    FROM Horarios h
    WHERE h.hora_inicio BETWEEN DATE_SUB(CURRENT_DATE, INTERVAL 7 DAY) AND CURRENT_DATE
);

-- 26. Rendimiento promedio por hectárea de los cultivos por mes
SELECT DATE_FORMAT(p.fecha, '%Y-%m') AS mes, c.nombre AS cultivo, SUM(cp.id_cultivo) / c.areas_hectareas AS rendimiento_por_hectarea
FROM Producciones p
JOIN Cultivos_para_produccion cp ON p.id_produccion = cp.id_produccion
JOIN Cultivos c ON cp.id_cultivo = c.id_cultivo
GROUP BY mes, c.id_cultivo;

-- 27. Cultivos con mejor rendimiento en los últimos 6 meses
SELECT c.nombre AS cultivo, SUM(cp.id_cultivo) AS cantidad_producida
FROM Producciones p
JOIN Cultivos_para_produccion cp ON p.id_produccion = cp.id_produccion
JOIN Cultivos c ON cp.id_cultivo = c.id_cultivo
WHERE p.fecha BETWEEN DATE_SUB(CURRENT_DATE, INTERVAL 6 MONTH) AND CURRENT_DATE
GROUP BY c.id_cultivo
ORDER BY cantidad_producida DESC
LIMIT 5;

-- 28. Historial de rendimiento de un cultivo específico por mes
SELECT DATE_FORMAT(p.fecha, '%Y-%m') AS mes, SUM(cp.id_cultivo) AS cantidad_producida
FROM Producciones p
JOIN Cultivos_para_produccion cp ON p.id_produccion = cp.id_produccion
WHERE cp.id_cultivo = (SELECT id_cultivo FROM Cultivos WHERE nombre = 'Maíz')
GROUP BY mes;

-- 29. Costo de producción total por hectárea de cultivo
SELECT c.nombre AS cultivo, SUM(p.costo) / c.areas_hectareas AS costo_por_hectarea
FROM Producciones p
JOIN Cultivos_para_produccion cp ON p.id_produccion = cp.id_produccion
JOIN Cultivos c ON cp.id_cultivo = c.id_cultivo
GROUP BY c.id_cultivo;

-- 30. Total de hectáreas sembradas por estado del cultivo
SELECT ec.estado AS estado_cultivo, SUM(c.areas_hectareas) AS total_hectareas
FROM Cultivos c
JOIN Estados_cultivo ec ON c.id_estado_cultivo = ec.id_estado_cultivo
GROUP BY ec.id_estado_cultivo;

-- 31. Animales por especie y estado
SELECT e.especie, ea.estado, COUNT(a.id_animal) AS cantidad_animales
FROM Animales a
JOIN Especies e ON a.id_especie = e.id_especie
JOIN Estados_animales ea ON a.id_estado_animal = ea.id_estado_animal
GROUP BY e.especie, ea.estado;

-- 32. Edad promedio de los animales por especie
SELECT e.especie, AVG(a.edad) AS edad_promedio
FROM Animales a
JOIN Especies e ON a.id_especie = e.id_especie
GROUP BY e.especie;

-- 33. Especies de animales con la mayor cantidad de animales enfermos
SELECT e.especie, COUNT(a.id_animal) AS cantidad_enfermos
FROM Animales a
JOIN Especies e ON a.id_especie = e.id_especie
JOIN Estados_animales ea ON a.id_estado_animal = ea.id_estado_animal
WHERE ea.estado = 'Enfermo'
GROUP BY e.especie
ORDER BY cantidad_enfermos DESC;

-- 34. Historial de estado de animales por especie
SELECT DATE_FORMAT(p.fecha, '%Y-%m') AS mes, e.especie, ea.estado, COUNT(a.id_animal) AS cantidad_animales
FROM Producciones p
JOIN Animales_para_produccion ap ON p.id_produccion = ap.id_produccion
JOIN Animales a ON ap.id_animal = a.id_animal
JOIN Especies e ON a.id_especie = e.id_especie
JOIN Estados_animales ea ON a.id_estado_animal = ea.id_estado_animal
GROUP BY mes, e.especie, ea.estado;

-- 35. Productos más vendidos en el último mes
SELECT p.nombre AS producto, SUM(dv.cantidad) AS cantidad_vendida
FROM Detalles_venta dv
JOIN Productos p ON dv.id_producto = p.id_producto
JOIN Ventas v ON dv.id_venta = v.id_venta
WHERE MONTH(v.fecha) = MONTH(CURRENT_DATE) AND YEAR(v.fecha) = YEAR(CURRENT_DATE)
GROUP BY p.id_producto
ORDER BY cantidad_vendida DESC LIMIT 10;

-- 36. Producto con mayor ganancia en el último trimestre
SELECT p.nombre AS producto, SUM(dv.cantidad * p.precio) AS total_ganancia
FROM Detalles_venta dv
JOIN Productos p ON dv.id_producto = p.id_producto
JOIN Ventas v ON dv.id_venta = v.id_venta
WHERE v.fecha BETWEEN DATE_SUB(CURRENT_DATE, INTERVAL 3 MONTH) AND CURRENT_DATE
GROUP BY p.id_producto
ORDER BY total_ganancia DESC
LIMIT 1;

-- 37. Ganancia total por tipo de producto
SELECT tp.tipo AS tipo_producto, SUM(dv.cantidad * p.precio) AS ganancia_total
FROM Detalles_venta dv
JOIN Productos p ON dv.id_producto = p.id_producto
JOIN Tipos_producto tp ON p.id_tipo_producto = tp.id_tipo_producto
GROUP BY tp.id_tipo_producto;

-- 38. Promedio de precios por tipo de producto
SELECT tp.tipo AS tipo_producto, AVG(p.precio) AS precio_promedio
FROM Productos p
JOIN Tipos_producto tp ON p.id_tipo_producto = tp.id_tipo_producto
GROUP BY tp.id_tipo_producto;

-- 39. Detalles de productos con precio por encima de la media
SELECT p.nombre AS producto, p.precio
FROM Productos p
WHERE p.precio > (SELECT AVG(precio) FROM Productos);

-- 40. Insumos más comprados en el último año
SELECT ai.nombre AS insumo, SUM(dc.cantidad) AS cantidad_comprada
FROM Detalles_compra dc
JOIN Activos_insumos ai ON dc.id_activo = ai.id_activo
JOIN Compras c ON dc.id_compra = c.id_compra
WHERE c.fecha BETWEEN DATE_SUB(CURRENT_DATE, INTERVAL 1 YEAR) AND CURRENT_DATE
GROUP BY ai.id_activo
ORDER BY cantidad_comprada DESC
LIMIT 10;

-- 41. Insumos con más compras por proveedor
SELECT pr.nombre AS proveedor, ai.nombre AS insumo, SUM(dc.cantidad) AS cantidad_comprada
FROM Detalles_compra dc
JOIN Activos_insumos ai ON dc.id_activo = ai.id_activo
JOIN Compras c ON dc.id_compra = c.id_compra
JOIN Proveedores pr ON c.id_proveedor = pr.id_proveedor
GROUP BY pr.id_proveedor, ai.id_activo
ORDER BY cantidad_comprada DESC;

-- 42. Proveedores con mayor número de compras en el último año
SELECT pr.nombre AS proveedor, COUNT(c.id_compra) AS total_compras, SUM(c.total) AS monto_total
FROM Compras c
JOIN Proveedores pr ON c.id_proveedor = pr.id_proveedor
WHERE c.fecha BETWEEN DATE_SUB(CURRENT_DATE, INTERVAL 1 YEAR) AND CURRENT_DATE
GROUP BY pr.id_proveedor
ORDER BY monto_total DESC;

-- 43. Precio promedio de insumos comprados por proveedor
SELECT pr.nombre AS proveedor, AVG(dc.precio_unitario) AS precio_promedio
FROM Detalles_compra dc
JOIN Compras c ON dc.id_compra = c.id_compra
JOIN Proveedores pr ON c.id_proveedor = pr.id_proveedor
GROUP BY pr.id_proveedor;

-- 44. Maquinarias en buen estado con más de 5 unidades disponibles
SELECT m.descripcion, m.marca, m.modelo, eq.cantidad
FROM Maquinas m
JOIN Equipos_de_trabajo eq ON m.id_activo = eq.id_activo
JOIN Estados est ON eq.id_estado = est.id_estado
WHERE est.estado = 'Bueno' AND eq.cantidad > 5;

-- 45. Vehículos más utilizados en tareas en el último mes
SELECT v.marca, v.modelo, COUNT(at.id_tarea) AS veces_utilizado
FROM Vehiculos v
JOIN Activos_en_tarea at ON v.id_activo = at.id_activo
JOIN Tareas t ON at.id_tarea = t.id_tarea
WHERE MONTH(t.fecha) = MONTH(CURRENT_DATE) AND YEAR(t.fecha) = YEAR(CURRENT_DATE)
GROUP BY v.id_vehiculo
ORDER BY veces_utilizado DESC;

-- 46. Beneficio neto mensual (ventas menos costos de producción y compras)
SELECT DATE_FORMAT(v.fecha, '%Y-%m') AS mes, (SUM(v.total) - (SELECT SUM(p.costo) 
FROM Producciones p WHERE DATE_FORMAT(p.fecha, '%Y-%m') = mes)- (SELECT SUM(c.total) FROM Compras c WHERE DATE_FORMAT(c.fecha, '%Y-%m') = mes)) AS beneficio_neto
FROM Ventas v
GROUP BY mes
ORDER BY mes DESC;

-- 47. Productos más rentables (precio de venta menos costo de producción)
SELECT p.nombre AS producto, (p.precio - AVG(pr.costo)) AS margen_rentabilidad
FROM Productos p
JOIN Productos_de_produccion pp ON p.id_producto = pp.id_producto
JOIN Producciones pr ON pp.id_produccion = pr.id_produccion
GROUP BY p.id_producto
ORDER BY margen_rentabilidad DESC LIMIT 10;

-- 48. Empleados con salarios por encima del promedio
SELECT e.nombre, e.salario
FROM Empleados e
WHERE e.salario > (SELECT AVG(salario) FROM Empleados);

-- 49. Productos con mayor cantidad de ventas y menor stock disponible
SELECT p.nombre AS producto, SUM(dv.cantidad) AS ventas_totales, pl.cantidad AS stock_disponible
FROM Detalles_venta dv
JOIN Productos p ON dv.id_producto = p.id_producto
JOIN Productos_en_locacion pl ON p.id_producto = pl.id_producto
GROUP BY p.id_producto
ORDER BY ventas_totales DESC, stock_disponible ASC;

-- 50. Vehículos que necesitan mantenimiento (según estado)
SELECT v.marca, v.modelo, est.estado
FROM Vehiculos v
JOIN Activos_insumos ai ON v.id_activo = ai.id_activo
JOIN Equipos_de_trabajo eq ON ai.id_activo = eq.id_activo
JOIN Estados est ON eq.id_estado = est.id_estado
WHERE est.estado = 'Necesita Mantenimiento';