-- 1. Inventario total de productos por locación
SELECT l.nombre AS locacion, p.nombre AS producto, 
       (SELECT pl.cantidad FROM Productos_en_locacion pl 
        WHERE pl.id_producto = p.id_producto 
        AND pl.id_locacion = l.id_locacion) AS cantidad_disponible
FROM Productos p
JOIN Locaciones_almacenamiento l ON EXISTS 
    (SELECT 1 FROM Productos_en_locacion pl 
     WHERE pl.id_producto = p.id_producto AND pl.id_locacion = l.id_locacion);

-- 2. Productos que están agotados en alguna locación
SELECT l.nombre AS locacion, p.nombre AS producto
FROM Productos p
JOIN Locaciones_almacenamiento l ON EXISTS 
    (SELECT 1 FROM Productos_en_locacion pl 
     WHERE pl.id_producto = p.id_producto AND pl.id_locacion = l.id_locacion AND pl.cantidad = 0);

-- 3. Productos con cantidad menor a cierto umbral
SELECT p.nombre AS producto, 
       (SELECT SUM(pl.cantidad) 
        FROM Productos_en_locacion pl 
        WHERE pl.id_producto = p.id_producto) AS total_disponible
FROM Productos p
WHERE (SELECT SUM(pl.cantidad) 
       FROM Productos_en_locacion pl 
       WHERE pl.id_producto = p.id_producto) < 10;

-- 4. Productos que ocupan más espacio que la capacidad disponible de las locaciones
SELECT l.nombre AS locacion, 
       (SELECT SUM(pl.cantidad) 
        FROM Productos_en_locacion pl 
        WHERE pl.id_locacion = l.id_locacion) AS cantidad_total, 
        l.capacidad_maxima, 
        l.capacidad_disponible
FROM Locaciones_almacenamiento l
WHERE (SELECT SUM(pl.cantidad) 
       FROM Productos_en_locacion pl 
       WHERE pl.id_locacion = l.id_locacion) > l.capacidad_disponible;

-- 5. Costo total de producción por mes
SELECT mes, 
       (SELECT SUM(p.costo) 
        FROM Producciones p 
        WHERE DATE_FORMAT(p.fecha, '%Y-%m') = mes) AS costo_total
FROM (SELECT DISTINCT DATE_FORMAT(p.fecha, '%Y-%m') AS mes FROM Producciones p) AS meses;

-- 6. Animales involucrados en la producción por mes
SELECT mes, 
       (SELECT COUNT(ap.id_animal) 
        FROM Animales_para_produccion ap 
        JOIN Producciones p ON p.id_produccion = ap.id_produccion 
        WHERE DATE_FORMAT(p.fecha, '%Y-%m') = mes) AS cantidad_animales
FROM (SELECT DISTINCT DATE_FORMAT(p.fecha, '%Y-%m') AS mes FROM Producciones p) AS meses;

-- 7. Cultivos con mayor producción por hectárea en el último año
SELECT c.nombre AS cultivo, ROUND(SUM(cp.id_cultivo) / c.areas_hectareas, 2) AS produccion_por_hectarea
FROM Cultivos_para_produccion cp
JOIN Cultivos c ON cp.id_cultivo = c.id_cultivo
WHERE cp.id_produccion IN (
      SELECT p.id_produccion 
      FROM Producciones p 
      WHERE YEAR(p.fecha) = YEAR(CURRENT_DATE)
      )
GROUP BY c.id_cultivo
ORDER BY produccion_por_hectarea DESC;

-- 8. Ventas por empleado en el último mes
SELECT e.nombre AS empleado, 
       (SELECT COUNT(v.id_venta) 
        FROM Ventas v 
        WHERE v.id_empleado = e.id_empleado 
        AND MONTH(v.fecha) = MONTH(CURRENT_DATE) 
        AND YEAR(v.fecha) = YEAR(CURRENT_DATE)) AS ventas_realizadas,
       (SELECT SUM(v.total) 
        FROM Ventas v 
        WHERE v.id_empleado = e.id_empleado 
        AND MONTH(v.fecha) = MONTH(CURRENT_DATE) 
        AND YEAR(v.fecha) = YEAR(CURRENT_DATE)) AS total_ventas
FROM Empleados e;

-- 9. Clientes con mayor volumen de compras en el último año
SELECT c.nombre AS cliente, 
       (SELECT SUM(v.total) 
        FROM Ventas v 
        WHERE v.id_cliente = c.id_cliente 
        AND v.fecha BETWEEN DATE_SUB(CURRENT_DATE, INTERVAL 1 YEAR) AND CURRENT_DATE) AS total_compras
FROM Clientes c
ORDER BY total_compras DESC 
LIMIT 10;

-- 10. Ventas por mes
SELECT mes, 
       (SELECT SUM(v.total) 
        FROM Ventas v 
        WHERE DATE_FORMAT(v.fecha, '%Y-%m') = mes) AS total_ventas
FROM (SELECT DISTINCT DATE_FORMAT(v.fecha, '%Y-%m') AS mes FROM Ventas v) AS meses;

-- 11. Comparación entre costos de producción y ventas por mes
SELECT p.mes, p.costo_produccion, v.total_ventas, (v.total_ventas - p.costo_produccion) AS ganancia
FROM (SELECT DATE_FORMAT(p.fecha, '%Y-%m') AS mes, SUM(p.costo) AS costo_produccion
      FROM Producciones p
      GROUP BY mes) p
JOIN (SELECT DATE_FORMAT(v.fecha, '%Y-%m') AS mes, SUM(v.total) AS total_ventas
      FROM Ventas v
      GROUP BY mes) v
ON p.mes = v.mes
ORDER BY ganancia DESC;

-- 12. Total de compras realizadas a proveedores en el último año
SELECT pr.nombre AS proveedor, 
       (SELECT SUM(c.total) 
        FROM Compras c 
        WHERE c.id_proveedor = pr.id_proveedor 
        AND c.fecha BETWEEN DATE_SUB(CURRENT_DATE, INTERVAL 1 YEAR) AND CURRENT_DATE) AS total_compras
FROM Proveedores pr
ORDER BY total_compras DESC;

-- 13. Detalles de productos con precio por encima de la media
SELECT p.nombre AS producto, p.precio
FROM Productos p
WHERE p.precio > (SELECT AVG(precio) FROM Productos);

-- 14. Beneficio neto mensual (ventas menos costos de producción y compras)
SELECT DATE_FORMAT(v.fecha, '%Y-%m') AS mes, GREATEST(0, SUM(v.total) - (SELECT IFNULL(SUM(p.costo), 0) 
FROM Producciones p 
WHERE DATE_FORMAT(p.fecha, '%Y-%m') = mes) - (SELECT IFNULL(SUM(c.total), 0) 
FROM Compras c 
WHERE DATE_FORMAT(c.fecha, '%Y-%m') = mes)
) AS beneficio_neto
FROM Ventas v
GROUP BY mes
ORDER BY mes DESC;

-- 15. Promedio de ingresos diarios por ventas en el último mes
SELECT ROUND(AVG(daily.total), 2) AS promedio_diario
FROM (
      SELECT DATE(v.fecha) AS dia, SUM(v.total) AS total
      FROM Ventas v
      WHERE MONTH(v.fecha) = MONTH(CURRENT_DATE) AND YEAR(v.fecha) = YEAR(CURRENT_DATE)
      GROUP BY dia
) daily;

-- 16. Costo total de compras por mes
SELECT mes, 
       (SELECT SUM(c.total) 
        FROM Compras c 
        WHERE DATE_FORMAT(c.fecha, '%Y-%m') = mes) AS costo_total_compras
FROM (SELECT DISTINCT DATE_FORMAT(c.fecha, '%Y-%m') AS mes FROM Compras c) AS meses;

-- 17. Costos operativos totales (producción + compras) por mes
SELECT prod.mes, (prod.costo_total + comp.costo_total_compras) AS costo_operativo_total
FROM (SELECT DATE_FORMAT(p.fecha, '%Y-%m') AS mes, SUM(p.costo) AS costo_total
      FROM Producciones p
      GROUP BY mes) prod
JOIN (SELECT DATE_FORMAT(c.fecha, '%Y-%m') AS mes, SUM(c.total) AS costo_total_compras
      FROM Compras c
      GROUP BY mes) comp ON prod.mes = comp.mes;

-- 18. Porcentaje de ventas por cliente en el último año
SELECT c.nombre AS cliente, ROUND((SUM(v.total) / (SELECT SUM(total) 
FROM Ventas 
WHERE fecha BETWEEN DATE_SUB(CURRENT_DATE, INTERVAL 1 YEAR) AND CURRENT_DATE)) * 100, 2) AS porcentaje_ventas
FROM Ventas v
JOIN Clientes c ON v.id_cliente = c.id_cliente
WHERE v.fecha BETWEEN DATE_SUB(CURRENT_DATE, INTERVAL 1 YEAR) AND CURRENT_DATE
GROUP BY c.id_cliente;

-- 19. Productos con margen de ganancia superior al promedio
SELECT p.nombre, ROUND(p.precio, 2) AS precio, ROUND(p.precio - (
      SELECT AVG(pr.costo)
      FROM Producciones pr
      WHERE pr.id_produccion IN (
            SELECT pdp.id_produccion
            FROM Productos_de_produccion pdp
            WHERE pdp.id_producto = p.id_producto)
), 2) AS margen_ganancia
FROM Productos p
HAVING margen_ganancia > (
      SELECT ROUND(AVG(
            p2.precio - (
            SELECT AVG(pr2.costo)
            FROM Producciones pr2
            WHERE pr2.id_produccion IN (
                  SELECT pdp2.id_produccion
                  FROM Productos_de_produccion pdp2
                  WHERE pdp2.id_producto = p2.id_producto)
      )), 2)
FROM Productos p2
);

-- 20. Productos más rentables por unidad en el último año
SELECT p.nombre,ROUND(p.precio - (SELECT AVG(pr.costo) 
FROM Producciones pr 
WHERE pr.id_produccion IN (SELECT pdp.id_produccion FROM Productos_de_produccion pdp
WHERE pdp.id_producto = p.id_producto)
AND pr.fecha BETWEEN DATE_SUB(CURRENT_DATE, INTERVAL 1 YEAR) AND CURRENT_DATE
), 2) AS rentabilidad_por_unidad
FROM Productos p
JOIN Detalles_venta dv ON p.id_producto = dv.id_producto
JOIN Ventas v ON dv.id_venta = v.id_venta
GROUP BY p.id_producto
ORDER BY rentabilidad_por_unidad DESC;

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
SELECT e.nombre AS empleado, ROUND(e.salario, 2) AS salario, COUNT(h.id_horario) AS dias_trabajados, ROUND((e.salario / 30) * COUNT(h.id_horario), 2) AS salario_mensual
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
SELECT DATE_FORMAT(p.fecha, '%Y-%m') AS mes, c.nombre AS cultivo, ROUND(SUM(cp.id_cultivo) / c.areas_hectareas, 2) AS rendimiento_por_hectarea
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
ORDER BY cantidad_producida DESC LIMIT 5;

-- 28. Historial de rendimiento de un cultivo específico por mes
SELECT DATE_FORMAT(p.fecha, '%Y-%m') AS mes, SUM(cp.id_cultivo) AS cantidad_producida
FROM Producciones p
JOIN Cultivos_para_produccion cp ON p.id_produccion = cp.id_produccion
WHERE cp.id_cultivo = (SELECT id_cultivo FROM Cultivos WHERE nombre = 'Trigo')
GROUP BY mes;

-- 29. Costo de producción total por hectárea de cultivo
SELECT c.nombre AS cultivo, ROUND(SUM(p.costo) / c.areas_hectareas, 2) AS costo_por_hectarea
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
SELECT e.especie, ROUND(AVG(a.edad),0) AS edad_promedio
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
ORDER BY total_ganancia DESC LIMIT 1;

-- 37. Ganancia total por tipo de producto
SELECT tp.tipo AS tipo_producto, ROUND(SUM(dv.cantidad * p.precio), 2) AS ganancia_total
FROM Detalles_venta dv
JOIN Productos p ON dv.id_producto = p.id_producto
JOIN Tipos_producto tp ON p.id_tipo_producto = tp.id_tipo_producto
GROUP BY tp.id_tipo_producto;

-- 38. Promedio de precios por tipo de producto
SELECT tp.tipo AS tipo_producto, ROUND(AVG(p.precio), 2) AS precio_promedio
FROM Productos p
JOIN Tipos_producto tp ON p.id_tipo_producto = tp.id_tipo_producto
GROUP BY tp.id_tipo_producto;

-- 39. Detalles de compras por proveedor y por producto
SELECT pr.nombre AS proveedor, a.nombre AS activo, SUM(dc.cantidad) AS cantidad_comprada
FROM Detalles_compra dc
JOIN Activos_insumos a ON dc.id_activo = a.id_activo
JOIN Compras c ON dc.id_compra = c.id_compra
JOIN Proveedores pr ON c.id_proveedor = pr.id_proveedor
GROUP BY pr.id_proveedor, a.id_activo;

-- 40. Insumos más comprados en el último año
SELECT ai.nombre AS insumo, SUM(dc.cantidad) AS cantidad_comprada
FROM Detalles_compra dc
JOIN Activos_insumos ai ON dc.id_activo = ai.id_activo
JOIN Compras c ON dc.id_compra = c.id_compra
WHERE c.fecha BETWEEN DATE_SUB(CURRENT_DATE, INTERVAL 1 YEAR) AND CURRENT_DATE
GROUP BY ai.id_activo
ORDER BY cantidad_comprada DESC LIMIT 10;

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
SELECT pr.nombre AS proveedor, ROUND(AVG(dc.precio_unitario), 2) AS precio_promedio
FROM Detalles_compra dc
JOIN Compras c ON dc.id_compra = c.id_compra
JOIN Proveedores pr ON c.id_proveedor = pr.id_proveedor
GROUP BY pr.id_proveedor;

-- 44. Maquinarias en buen estado con más de 5 unidades disponibles
SELECT m.descripcion, m.marca, m.modelo
FROM Maquinas m
JOIN Estados est ON m.id_estado = est.id_estado
WHERE est.estado = 'Bueno';

-- 45. Vehículos más utilizados en tareas en el último mes
SELECT v.marca, v.modelo, COUNT(at.id_tarea) AS veces_utilizado
FROM Vehiculos v
JOIN Activos_en_tarea at ON v.id_activo = at.id_activo
JOIN Tareas t ON at.id_tarea = t.id_tarea
WHERE MONTH(t.fecha) = MONTH(CURRENT_DATE) AND YEAR(t.fecha) = YEAR(CURRENT_DATE)
GROUP BY v.id_vehiculo
ORDER BY veces_utilizado DESC;

-- 46. Costo total de producción por mes
SELECT DATE_FORMAT(p.fecha, '%Y-%m') AS mes, SUM(p.costo) AS costo_total
FROM Producciones p
GROUP BY mes;

-- 47. Productos más rentables (precio de venta menos costo de producción)
SELECT p.nombre AS producto, ROUND((p.precio - AVG(pr.costo)), 2) AS margen_rentabilidad
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
SELECT p.nombre AS producto, SUM(dv.cantidad) AS ventas_totales, MAX(pl.cantidad) AS stock_disponible
FROM Detalles_venta dv
JOIN Productos p ON dv.id_producto = p.id_producto
JOIN Productos_en_locacion pl ON p.id_producto = pl.id_producto
GROUP BY p.id_producto
ORDER BY ventas_totales DESC, stock_disponible ASC;

-- 50. Desempeño de empleados en Tareas realizadas
SELECT e.nombre AS empleado, COUNT(et.id_tarea) AS tareas_completadas 
FROM Empleados e 
JOIN Empleados_en_tarea et ON e.id_empleado = et.id_empleado 
GROUP BY e.nombre;

-- 51. Promedio de gastos en compras mensuales
SELECT DATE_FORMAT(c.fecha, '%Y-%m') AS mes, ROUND(AVG(c.total), 2) AS promedio_compras
FROM Compras c
GROUP BY mes;

-- 52. Meses con el mayor costo en compras
SELECT DATE_FORMAT(c.fecha, '%Y-%m') AS mes, SUM(c.total) AS total_compras
FROM Compras c
GROUP BY mes
ORDER BY total_compras DESC LIMIT 3;

-- 53. Número de insumos comprados por tipo y proveedor en el último año
SELECT ti.tipo AS tipo_insumo, p.nombre AS proveedor, SUM(dc.cantidad) AS total_insumos
FROM Detalles_compra dc
JOIN Compras c ON dc.id_compra = c.id_compra
JOIN Activos_insumos ai ON dc.id_activo = ai.id_activo
JOIN Tipos_insumo ti ON ai.id_categoria = ti.id_tipo_insumo
JOIN Proveedores p ON c.id_proveedor = p.id_proveedor
WHERE c.fecha BETWEEN DATE_SUB(CURRENT_DATE, INTERVAL 1 YEAR) AND CURRENT_DATE
GROUP BY ti.tipo, p.nombre
ORDER BY total_insumos DESC;

-- 54. Costo total de compras agrupado por mes y proveedor
SELECT DATE_FORMAT(c.fecha, '%Y-%m') AS mes, p.nombre AS proveedor, SUM(c.total) AS total_compras
FROM Compras c
JOIN Proveedores p ON c.id_proveedor = p.id_proveedor
GROUP BY mes, p.nombre
ORDER BY total_compras DESC;

-- 55. Productos con mayor stock disponible por locación
SELECT l.nombre AS locacion, p.nombre AS producto, pl.cantidad AS cantidad_disponible
FROM Productos_en_locacion pl
JOIN Productos p ON pl.id_producto = p.id_producto
JOIN Locaciones_almacenamiento l ON pl.id_locacion = l.id_locacion
ORDER BY pl.cantidad DESC LIMIT 5;

-- 56. Total de stock por producto
SELECT p.nombre AS producto, SUM(pl.cantidad) AS total_stock
FROM Productos_en_locacion pl
JOIN Productos p ON pl.id_producto = p.id_producto
GROUP BY p.nombre
ORDER BY total_stock DESC;

-- 57. Insumos por agotarse (cantidad menor a 5 unidades)
SELECT ai.nombre AS insumo, SUM(i.cantidad) AS cantidad_disponible
FROM Insumos i
JOIN Activos_insumos ai ON i.id_activo = ai.id_activo
WHERE i.cantidad < 5
GROUP BY ai.nombre;

-- 58. Espacio restante disponible por locación
SELECT l.nombre AS locacion, GREATEST(l.capacidad_disponible - SUM(pl.cantidad), 0) AS espacio_restante
FROM Locaciones_almacenamiento l
JOIN Productos_en_locacion pl ON l.id_locacion = pl.id_locacion
GROUP BY l.id_locacion;

-- 59. Producción anual por tipo de cultivo
SELECT DATE_FORMAT(p.fecha, '%Y') AS ano, c.nombre AS cultivo, SUM(cp.id_cultivo) AS produccion_total
FROM Producciones p
JOIN Cultivos_para_produccion cp ON p.id_produccion = cp.id_produccion
JOIN Cultivos c ON cp.id_cultivo = c.id_cultivo
GROUP BY ano, c.nombre
ORDER BY produccion_total DESC;

-- 60. Detalle de ventas de productos por empleado
SELECT e.nombre AS empleado, p.nombre AS producto, SUM(dv.cantidad) AS cantidad_vendida
FROM Detalles_venta dv
JOIN Productos p ON dv.id_producto = p.id_producto
JOIN Ventas v ON dv.id_venta = v.id_venta
JOIN Empleados e ON v.id_empleado = e.id_empleado
GROUP BY e.id_empleado, p.id_producto;

-- 61. Animales involucrados en producción por especie
SELECT e.especie, COUNT(ap.id_animal) AS animales_involucrados_produccion
FROM Animales_para_produccion ap
JOIN Animales a ON ap.id_animal = a.id_animal
JOIN Especies e ON a.id_especie = e.id_especie
GROUP BY e.id_especie;

-- 62. Historial de producción de animales por mes
SELECT DATE_FORMAT(p.fecha, '%Y-%m') AS mes, e.especie, COUNT(ap.id_animal) AS animales_producidos
FROM Producciones p
JOIN Animales_para_produccion ap ON p.id_produccion = ap.id_produccion
JOIN Animales a ON ap.id_animal = a.id_animal
JOIN Especies e ON a.id_especie = e.id_especie
GROUP BY mes, e.especie;

-- 63. Clientes con más compras en los últimos 6 meses
SELECT c.nombre AS cliente, SUM(v.total) AS total_compras
FROM Ventas v
JOIN Clientes c ON v.id_cliente = c.id_cliente
WHERE v.fecha BETWEEN DATE_SUB(CURRENT_DATE, INTERVAL 6 MONTH) AND CURRENT_DATE
GROUP BY c.id_cliente
ORDER BY total_compras DESC LIMIT 10;

-- 64. Detalle de ventas por producto en el último año
SELECT p.nombre AS producto, SUM(dv.cantidad) AS total_vendido, SUM(dv.cantidad * p.precio) AS ganancia_total
FROM Detalles_venta dv
JOIN Productos p ON dv.id_producto = p.id_producto
JOIN Ventas v ON dv.id_venta = v.id_venta
WHERE v.fecha BETWEEN DATE_SUB(CURRENT_DATE, INTERVAL 1 YEAR) AND CURRENT_DATE
GROUP BY p.nombre
ORDER BY total_vendido DESC;

-- 65. Ventas por tipo de producto
SELECT tp.tipo AS tipo_producto, SUM(dv.cantidad) AS total_vendido
FROM Detalles_venta dv
JOIN Productos p ON dv.id_producto = p.id_producto
JOIN Tipos_producto tp ON p.id_tipo_producto = tp.id_tipo_producto
GROUP BY tp.id_tipo_producto
ORDER BY total_vendido DESC;

-- 66. Ventas por empleado en el último trimestre
SELECT e.nombre AS empleado, COUNT(v.id_venta) AS ventas_realizadas, SUM(v.total) AS total_ventas
FROM Ventas v
JOIN Empleados e ON v.id_empleado = e.id_empleado
WHERE v.fecha BETWEEN DATE_SUB(CURRENT_DATE, INTERVAL 3 MONTH) AND CURRENT_DATE
GROUP BY e.id_empleado;

-- 67. Beneficio bruto por tipo de producto en el último año
SELECT tp.tipo AS tipo_producto, SUM(dv.cantidad * p.precio) AS total_ingresos
FROM Detalles_venta dv
JOIN Productos p ON dv.id_producto = p.id_producto
JOIN Tipos_producto tp ON p.id_tipo_producto = tp.id_tipo_producto
JOIN Ventas v ON dv.id_venta = v.id_venta
WHERE v.fecha BETWEEN DATE_SUB(CURRENT_DATE, INTERVAL 1 YEAR) AND CURRENT_DATE
GROUP BY tp.id_tipo_producto;

-- 68. Ganancia total por venta en los últimos 6 meses
SELECT v.id_venta, SUM(dv.cantidad * p.precio) AS total_ganancia
FROM Detalles_venta dv
JOIN Productos p ON dv.id_producto = p.id_producto
JOIN Ventas v ON dv.id_venta = v.id_venta
WHERE v.fecha BETWEEN DATE_SUB(CURRENT_DATE, INTERVAL 6 MONTH) AND CURRENT_DATE
GROUP BY v.id_venta;

-- 69. Costo promedio de compras por tipo de activo
SELECT ca.nombre AS categoria, ROUND(AVG(dc.precio_unitario), 2) AS precio_promedio
FROM Detalles_compra dc
JOIN Activos_insumos a ON dc.id_activo = a.id_activo
JOIN Categorias ca ON a.id_categoria = ca.id_categoria
GROUP BY ca.id_categoria;

-- 70. Desglose mensual de costos por categoría de activo
SELECT DATE_FORMAT(c.fecha, '%Y-%m') AS mes, ca.nombre AS categoria, SUM(dc.precio_unitario * dc.cantidad) AS costo_total
FROM Detalles_compra dc
JOIN Activos_insumos a ON dc.id_activo = a.id_activo
JOIN Categorias ca ON a.id_categoria = ca.id_categoria
JOIN Compras c ON dc.id_compra = c.id_compra
GROUP BY mes, ca.id_categoria;

-- 71. Empleados con más ventas en los últimos 6 meses
SELECT e.nombre AS empleado, COUNT(v.id_venta) AS total_ventas, SUM(v.total) AS total_ingresos
FROM Ventas v
JOIN Empleados e ON v.id_empleado = e.id_empleado
WHERE v.fecha BETWEEN DATE_SUB(CURRENT_DATE, INTERVAL 6 MONTH) AND CURRENT_DATE
GROUP BY e.id_empleado
ORDER BY total_ventas DESC;

-- 72. Empleados con menos tareas asignadas en el último trimestre
SELECT e.nombre AS empleado, COUNT(et.id_tarea) AS tareas_asignadas
FROM Empleados_en_tarea et
JOIN Empleados e ON et.id_empleado = e.id_empleado
JOIN Tareas t ON et.id_tarea = t.id_tarea
WHERE t.fecha BETWEEN DATE_SUB(CURRENT_DATE, INTERVAL 3 MONTH) AND CURRENT_DATE
GROUP BY e.id_empleado
ORDER BY tareas_asignadas ASC LIMIT 5;

-- 73. Resumen de horas trabajadas por empleado en el último mes
SELECT e.nombre AS empleado, SUM(TIMESTAMPDIFF(HOUR, h.hora_inicio, h.hora_fin)) AS horas_trabajadas
FROM Empleados e
JOIN Horarios h ON e.id_empleado = h.id_empleado
WHERE MONTH(h.hora_inicio) = MONTH(CURRENT_DATE) AND YEAR(h.hora_inicio) = YEAR(CURRENT_DATE)
GROUP BY e.id_empleado;

-- 74. Historial de tareas completadas por empleado
SELECT e.nombre AS empleado, COUNT(t.id_tarea) AS tareas_completadas
FROM Empleados_en_tarea et
JOIN Empleados e ON et.id_empleado = e.id_empleado
JOIN Tareas t ON et.id_tarea = t.id_tarea
JOIN Estados_tarea est ON t.id_estado = est.id_estado
WHERE est.estado = 'Completada'
GROUP BY e.id_empleado
ORDER BY tareas_completadas DESC;

-- 75. Equipos de trabajo en buen estado con más de 10 unidades
SELECT eq.descripcion, eq.cantidad, est.estado
FROM Equipos_de_trabajo eq
JOIN Estados est ON eq.id_estado = est.id_estado
WHERE est.estado = 'Bueno' AND eq.cantidad > 10;

-- 76. Vehículos utilizados en tareas en el último año
SELECT v.marca, v.modelo, COUNT(at.id_tarea) AS veces_utilizado
FROM Vehiculos v
JOIN Activos_en_tarea at ON v.id_activo = at.id_activo
JOIN Tareas t ON at.id_tarea = t.id_tarea
WHERE t.fecha BETWEEN DATE_SUB(CURRENT_DATE, INTERVAL 1 YEAR) AND CURRENT_DATE
GROUP BY v.id_vehiculo
ORDER BY veces_utilizado DESC;

-- 77. Maquinarias con estado en mantenimiento
SELECT m.descripcion, m.marca, m.modelo, est.estado
FROM Maquinas m
JOIN Estados est ON m.id_estado = est.id_estado
WHERE est.estado IN ('Mantenimiento');

-- 78. Empleados con el mayor Salario
SELECT nombre, salario 
FROM Empleados 
ORDER BY salario DESC LIMIT 5;

-- 79. Clientes que no han realizado compras en los últimos 6 meses
SELECT c.nombre AS cliente
FROM Clientes c
WHERE c.id_cliente NOT IN (
      SELECT DISTINCT v.id_cliente
      FROM Ventas v
      WHERE v.fecha BETWEEN DATE_SUB(CURRENT_DATE, INTERVAL 6 MONTH) AND CURRENT_DATE
);

-- 80. Proveedores con los que se han realizado más compras
SELECT p.nombre AS proveedor, COUNT(c.id_compra) AS total_compras, SUM(c.total) AS monto_total
FROM Proveedores p
JOIN Compras c ON p.id_proveedor = c.id_proveedor
GROUP BY p.id_proveedor
ORDER BY total_compras DESC;

-- 81. Historial de compras por proveedor
SELECT p.nombre AS proveedor, DATE_FORMAT(c.fecha, '%Y-%m') AS mes, SUM(c.total) AS monto_total
FROM Proveedores p
JOIN Compras c ON p.id_proveedor = c.id_proveedor
GROUP BY p.id_proveedor, mes
ORDER BY monto_total DESC;

-- 82. Productos con más ventas en relación al stock actual
SELECT p.nombre AS producto, SUM(dv.cantidad) AS ventas_totales, ROUND((SUM(dv.cantidad) / SUM(pl.cantidad)) * 100, 2) AS porcentaje_ventas_vs_stock
FROM Detalles_venta dv
JOIN Productos p ON dv.id_producto = p.id_producto
JOIN Productos_en_locacion pl ON p.id_producto = pl.id_producto
GROUP BY p.id_producto
ORDER BY porcentaje_ventas_vs_stock DESC;

-- 83. Empleados con mejor desempeño (mayor número de tareas completadas y menor cantidad de errores)
SELECT e.nombre, COUNT(t.id_tarea) AS tareas_completadas
FROM Empleados e
JOIN Empleados_en_tarea et ON e.id_empleado = et.id_empleado
JOIN Tareas t ON et.id_tarea = t.id_tarea
WHERE t.id_estado = (SELECT id_estado FROM Estados_tarea WHERE estado = 'Completada')
GROUP BY e.id_empleado
ORDER BY tareas_completadas DESC LIMIT 5;

-- 84. Ingresos anuales totales agrupados por cliente
SELECT c.nombre AS cliente, ROUND(SUM(v.total), 2) AS total_ingresos
FROM Ventas v
JOIN Clientes c ON v.id_cliente = c.id_cliente
WHERE YEAR(v.fecha) = YEAR(CURRENT_DATE)
GROUP BY c.id_cliente;

-- 85. Total de compras de insumos por categoría en el último año
SELECT ci.nombre AS categoria, SUM(dc.precio_unitario * dc.cantidad) AS total_compras
FROM Detalles_compra dc
JOIN Activos_insumos ai ON dc.id_activo = ai.id_activo
JOIN Categorias ci ON ai.id_categoria = ci.id_categoria
WHERE dc.id_compra IN (
    SELECT c.id_compra FROM Compras c WHERE YEAR(c.fecha) = YEAR(CURRENT_DATE)
)
GROUP BY ci.id_categoria;

-- 86. Ingresos mensuales de ventas por producto y empleado
SELECT e.nombre AS empleado, p.nombre AS producto, DATE_FORMAT(v.fecha, '%Y-%m') AS mes, SUM(dv.cantidad * p.precio) AS ingresos_totales
FROM Detalles_venta dv
JOIN Productos p ON dv.id_producto = p.id_producto
JOIN Ventas v ON dv.id_venta = v.id_venta
JOIN Empleados e ON v.id_empleado = e.id_empleado
GROUP BY e.id_empleado, p.id_producto, mes;

-- 87. Vehículos que más han participado en producción en el último trimestre
SELECT v.marca, v.modelo, COUNT(at.id_tarea) AS veces_utilizado
FROM Vehiculos v
JOIN Activos_en_tarea at ON v.id_activo = at.id_activo
JOIN Tareas t ON at.id_tarea = t.id_tarea
WHERE t.fecha BETWEEN DATE_SUB(CURRENT_DATE, INTERVAL 3 MONTH) AND CURRENT_DATE
GROUP BY v.id_vehiculo
ORDER BY veces_utilizado DESC;

-- 88. Resumen mensual de costos de producción por tipo de producto
SELECT DATE_FORMAT(p.fecha, '%Y-%m') AS mes, tp.tipo AS tipo_producto, SUM(pr.precio * pp.cantidad) AS total_ventas
FROM Producciones p
JOIN Productos_de_produccion pp ON p.id_produccion = pp.id_produccion
JOIN Productos pr ON pp.id_producto = pr.id_producto
JOIN Tipos_producto tp ON pr.id_tipo_producto = tp.id_tipo_producto
GROUP BY mes, tp.tipo;

-- 89. Animales con mayor producción por especie en el último trimestre
SELECT e.especie, COUNT(ap.id_animal) AS animales_producidos
FROM Animales_para_produccion ap
JOIN Animales a ON ap.id_animal = a.id_animal
JOIN Especies e ON a.id_especie = e.id_especie
JOIN Producciones p ON ap.id_produccion = p.id_produccion
WHERE p.fecha BETWEEN DATE_SUB(CURRENT_DATE, INTERVAL 3 MONTH) AND CURRENT_DATE
GROUP BY e.especie
ORDER BY animales_producidos DESC;

-- 90. Costo total de producción por mes.
SELECT DATE_FORMAT(p.fecha, '%Y-%m') AS mes, SUM(p.costo) AS costo_total
FROM Producciones p
GROUP BY mes;

-- 91. Cantidad de animales por especie
SELECT es.especie, COUNT(a.id_animal) AS cantidad_animales 
FROM Especies es 
LEFT JOIN Animales a ON es.id_especie = a.id_especie 
GROUP BY es.especie;

-- 92. Clientes con mayor volumen de compras en relación al total de ventas
SELECT c.nombre, ROUND((SUM(v.total) / (
	SELECT SUM(v2.total) 
	FROM Ventas v2 
	WHERE YEAR(v2.fecha) = YEAR(CURRENT_DATE) 
)) * 100, 2) AS porcentaje_total
FROM Clientes c
JOIN Ventas v ON c.id_cliente = v.id_cliente
WHERE YEAR(v.fecha) = YEAR(CURRENT_DATE)
GROUP BY c.id_cliente;

-- 93. Productos más rentables por unidad en el último trimestre
SELECT 
    p.nombre, 
    ROUND(p.precio - (
        SELECT AVG(pr.costo) 
        FROM Producciones pr 
        WHERE pr.id_produccion IN (
            SELECT pdp.id_produccion 
            FROM Productos_de_produccion pdp 
            WHERE pdp.id_producto = p.id_producto)
	), 2) AS rentabilidad_por_unidad
FROM Productos p
JOIN Detalles_venta dv ON p.id_producto = dv.id_producto
JOIN Ventas v ON dv.id_venta = v.id_venta
WHERE v.fecha BETWEEN DATE_SUB(CURRENT_DATE, INTERVAL 3 MONTH) AND CURRENT_DATE
GROUP BY p.id_producto
ORDER BY rentabilidad_por_unidad DESC;

-- 94. Empleados con mejor desempeño basado en ventas y tareas completadas
SELECT e.nombre, COUNT(v.id_venta) AS ventas, COUNT(t.id_tarea) AS tareas_completadas
FROM Empleados e
LEFT JOIN Ventas v ON e.id_empleado = v.id_empleado
LEFT JOIN Empleados_en_tarea et ON e.id_empleado = et.id_empleado
LEFT JOIN Tareas t ON et.id_tarea = t.id_tarea
WHERE t.id_estado = (SELECT id_estado FROM Estados_tarea WHERE estado = 'Completada')
GROUP BY e.id_empleado
ORDER BY ventas DESC, tareas_completadas DESC;

-- 95. Proveedores con mayor porcentaje de compras respecto al total
SELECT p.nombre AS proveedor, 
      ROUND((SUM(c.total) / (
            SELECT SUM(c2.total) 
            FROM Compras c2 
            WHERE YEAR(c2.fecha) = YEAR(CURRENT_DATE)
      )) * 100, 2) AS porcentaje_total
FROM Proveedores p
JOIN Compras c ON p.id_proveedor = c.id_proveedor
GROUP BY p.id_proveedor
ORDER BY porcentaje_total DESC;

-- 96. Tareas por el respectivo tipo
SELECT tt.tipo AS tipo_tarea, COUNT(t.id_tarea) AS cantidad_tareas 
FROM Tipos_tarea tt 
JOIN Tareas t ON tt.id_tipo_tarea = t.id_tipo_tarea 
GROUP BY tt.tipo;

-- 97. Empleados con salarios más altos en relación al promedio
SELECT MONTH(fecha) AS Mes, ROUND(SUM(total), 2) AS Total_Ventas 
FROM Ventas 
GROUP BY MONTH(fecha)
ORDER BY Total_Ventas ASC LIMIT 5;

-- 98. Tareas que se han completado más rápido de lo previsto
SELECT t.descripcion_tarea, t.fecha, TIMESTAMPDIFF(DAY, t.fecha, NOW()) AS dias_transcurridos
FROM Tareas t
JOIN Estados_tarea est ON t.id_estado = est.id_estado
WHERE est.estado = 'Completada'
ORDER BY dias_transcurridos ASC LIMIT 10;

-- 99. Comparación de costos de producción con ingresos por ventas para los cultivos más vendidos
SELECT c.nombre AS cultivo, SUM(pr.costo) AS costo_produccion, SUM(dv.cantidad * p.precio) AS total_ventas, (SUM(dv.cantidad * p.precio) - SUM(pr.costo)) AS ganancia_neta
FROM Producciones pr
JOIN Cultivos_para_produccion cp ON pr.id_produccion = cp.id_produccion
JOIN Cultivos c ON cp.id_cultivo = c.id_cultivo
JOIN Productos_de_produccion pp ON pr.id_produccion = pp.id_produccion
JOIN Productos p ON pp.id_producto = p.id_producto
JOIN Detalles_venta dv ON p.id_producto = dv.id_producto
GROUP BY c.id_cultivo
ORDER BY ganancia_neta DESC;

-- 100. Producción mensual por tipo de cultivo
SELECT DATE_FORMAT(p.fecha, '%Y-%m') AS mes, c.nombre AS cultivo, COUNT(cp.id_cultivo) AS cantidad_producida
FROM Producciones p
JOIN Cultivos_para_produccion cp ON p.id_produccion = cp.id_produccion
JOIN Cultivos c ON cp.id_cultivo = c.id_cultivo
GROUP BY mes, c.id_cultivo;
