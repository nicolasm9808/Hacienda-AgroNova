-- 1. Calcular el rendimiento promedio por hectárea de cada cultivo
-- Esta función calcula el rendimiento por hectárea basándose en la cantidad producida de un cultivo en relación a las hectáreas sembradas.
DELIMITER //

CREATE FUNCTION RendimientoPromedioHectarea(p_id_cultivo INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_rendimiento DECIMAL(10,2);
    SELECT IFNULL(SUM(pd.cantidad) / c.areas_hectareas, 0)
    INTO v_rendimiento
    FROM Productos_de_produccion pd
    JOIN Cultivos_para_produccion cp ON cp.id_produccion = pd.id_produccion
    JOIN Cultivos c ON cp.id_cultivo = c.id_cultivo
    WHERE c.id_cultivo = p_id_cultivo;
    RETURN v_rendimiento;
END //

DELIMITER ;

-- 2. Estimar el costo operativo total de la finca en un período de tiempo
-- Esta función suma los costos de producción dentro de un período de tiempo dado.
DELIMITER //

CREATE FUNCTION CostoOperativoTotal(p_fecha_inicio DATE, p_fecha_fin DATE)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_costo_total DECIMAL(10,2);
    SELECT IFNULL(SUM(costo), 0) INTO v_costo_total
    FROM Producciones
    WHERE fecha BETWEEN p_fecha_inicio AND p_fecha_fin;
    RETURN v_costo_total;
END //

DELIMITER ;

-- 3. Calcular la cantidad total de productos vendidos por cliente
-- Esta función devuelve la cantidad total de productos vendidos a un cliente en específico.
DELIMITER //

CREATE FUNCTION TotalProductosVendidosCliente(p_id_cliente INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_total INT;
    SELECT IFNULL(SUM(dv.cantidad), 0)
    INTO v_total
    FROM Ventas v
    JOIN Detalles_venta dv ON v.id_venta = dv.id_venta
    WHERE v.id_cliente = p_id_cliente;
    RETURN v_total;
END //

DELIMITER ;

-- 4. Calcular el ingreso total generado por un cliente
-- Esta función calcula el total de ingresos generados por un cliente específico.
DELIMITER //

CREATE FUNCTION IngresoTotalPorCliente(p_id_cliente INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_ingreso_total DECIMAL(10,2);
    SELECT IFNULL(SUM(v.total), 0)
    INTO v_ingreso_total
    FROM Ventas v
    WHERE v.id_cliente = p_id_cliente;
    RETURN v_ingreso_total;
END //

DELIMITER ;

-- 5. Calcular la cantidad de insumos disponibles en el inventario
-- Esta función devuelve la cantidad total de un insumo específico disponible en el inventario.
DELIMITER //

CREATE FUNCTION CantidadInsumoDisponible(p_id_insumo INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_cantidad INT;
    SELECT cantidad INTO v_cantidad
    FROM Insumos
    WHERE id_insumo = p_id_insumo;
    RETURN v_cantidad;
END //

DELIMITER ;

-- 6. Calcular el total de compras realizadas a un proveedor en un rango de fechas
-- Esta función devuelve el total de compras hechas a un proveedor en un período de tiempo determinado.
DELIMITER //

CREATE FUNCTION TotalComprasProveedor(p_id_proveedor INT, p_fecha_inicio DATE, p_fecha_fin DATE)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_total DECIMAL(10,2);
    SELECT IFNULL(SUM(total), 0)
    INTO v_total
    FROM Compras
    WHERE id_proveedor = p_id_proveedor
    AND fecha BETWEEN p_fecha_inicio AND p_fecha_fin;
    RETURN v_total;
END //

DELIMITER ;

-- 7. Calcular el costo promedio de los insumos comprados a un proveedor
-- Esta función calcula el costo promedio de insumos comprados a un proveedor específico.
DELIMITER //

CREATE FUNCTION CostoPromedioInsumosProveedor(p_id_proveedor INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_costo_promedio DECIMAL(10,2);
    SELECT IFNULL(AVG(dc.precio_unitario), 0)
    INTO v_costo_promedio
    FROM Detalles_compra dc
    JOIN Compras c ON dc.id_compra = c.id_compra
    WHERE c.id_proveedor = p_id_proveedor;
    RETURN v_costo_promedio;
END //

DELIMITER ;

-- 8. Calcular el costo de una producción basada en animales
-- Esta función calcula el costo total asociado a la producción relacionada con animales.
DELIMITER //

CREATE FUNCTION CostoProduccionAnimales(p_id_produccion INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_costo DECIMAL(10,2);
    SELECT IFNULL(SUM(a.costo), 0)
    INTO v_costo
    FROM Animales_para_produccion ap
    JOIN Animales a ON ap.id_animal = a.id_animal
    WHERE ap.id_produccion = p_id_produccion;
    RETURN v_costo;
END //

DELIMITER ;

-- 9. Calcular la cantidad de empleados asignados a una tarea
-- Esta función devuelve la cantidad de empleados asignados a una tarea específica.
DELIMITER //

CREATE FUNCTION EmpleadosAsignadosATarea(p_id_tarea INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_total_empleados INT;
    SELECT COUNT(*) INTO v_total_empleados
    FROM Empleados_en_tarea
    WHERE id_tarea = p_id_tarea;
    RETURN v_total_empleados;
END //

DELIMITER ;

-- 10. Calcular el costo total de los activos utilizados en una tarea
-- Esta función calcula el costo total de los activos utilizados en una tarea específica.
DELIMITER //

CREATE FUNCTION CostoTotalActivosEnTarea(p_id_tarea INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_costo_total DECIMAL(10,2);
    SELECT IFNULL(SUM(a.precio_unitario * ae.cantidad), 0)
    INTO v_costo_total
    FROM Activos_en_tarea ae
    JOIN Activos_insumos a ON ae.id_activo = a.id_activo
    WHERE ae.id_tarea = p_id_tarea;
    RETURN v_costo_total;
END //

DELIMITER ;

-- 11. Calcular la eficiencia de producción por animal
-- Esta función calcula la cantidad producida por cada animal utilizado en una producción.
DELIMITER //

CREATE FUNCTION EficienciaProduccionAnimal(p_id_produccion INT, p_id_animal INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_eficiencia DECIMAL(10,2);
    SELECT IFNULL(SUM(pd.cantidad) / SUM(ap.cantidad), 0)
    INTO v_eficiencia
    FROM Productos_de_produccion pd
    JOIN Animales_para_produccion ap ON pd.id_produccion = ap.id_produccion
    WHERE ap.id_produccion = p_id_produccion AND ap.id_animal = p_id_animal;
    RETURN v_eficiencia;
END //

DELIMITER ;

-- 12. Calcular el porcentaje de stock disponible de un producto
-- Esta función calcula el porcentaje de stock disponible en relación al máximo de un producto.
DELIMITER //

CREATE FUNCTION PorcentajeStockDisponible(p_id_producto INT)
RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE v_porcentaje DECIMAL(5,2);
    DECLARE v_max_cantidad INT;
    SELECT MAX(cantidad) INTO v_max_cantidad FROM Productos WHERE id_producto = p_id_producto;
    SELECT (cantidad / v_max_cantidad) * 100 INTO v_porcentaje
    FROM Productos
    WHERE id_producto = p_id_producto;
    RETURN v_porcentaje;
END //

DELIMITER ;

-- 13. Calcular el tiempo promedio de cultivo
-- Esta función calcula el tiempo promedio que toma un cultivo desde la siembra hasta la cosecha.
DELIMITER //

CREATE FUNCTION TiempoPromedioCultivo(p_id_cultivo INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_tiempo_promedio INT;
    SELECT AVG(DATEDIFF(CURDATE(), c.fecha_siembra))
    INTO v_tiempo_promedio
    FROM Cultivos c
    WHERE c.id_cultivo = p_id_cultivo;
    RETURN v_tiempo_promedio;
END //

DELIMITER ;

-- 14. Calcular el costo total de una tarea
-- Esta función calcula el costo total de una tarea combinando insumos, empleados y activos.
DELIMITER //

CREATE FUNCTION CostoTotalTarea(p_id_tarea INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_costo_total DECIMAL(10,2);
    SELECT IFNULL(SUM(ae.cantidad * ai.precio_unitario), 0) + 
           IFNULL(SUM(e.salario), 0) INTO v_costo_total
    FROM Activos_en_tarea ae
    JOIN Activos_insumos ai ON ae.id_activo = ai.id_activo
    JOIN Empleados_en_tarea et ON et.id_tarea = ae.id_tarea
    JOIN Empleados e ON et.id_empleado = e.id_empleado
    WHERE ae.id_tarea = p_id_tarea;
    RETURN v_costo_total;
END //

DELIMITER ;

-- 15. Calcular el costo total de producción de un cultivo específico
-- Esta función calcula el costo total de producción de un cultivo.
DELIMITER //

CREATE FUNCTION CostoTotalProduccionCultivo(p_id_cultivo INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_costo_total DECIMAL(10,2);
    SELECT IFNULL(SUM(p.costo), 0)
    INTO v_costo_total
    FROM Producciones p
    JOIN Cultivos_para_produccion cp ON p.id_produccion = cp.id_produccion
    WHERE cp.id_cultivo = p_id_cultivo;
    RETURN v_costo_total;
END //

DELIMITER ;

-- 16. Calcular el rendimiento total de los animales por producción
-- Esta función calcula la cantidad total producida por los animales en una producción.
DELIMITER //

CREATE FUNCTION RendimientoTotalAnimalesProduccion(p_id_produccion INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_rendimiento_total DECIMAL(10,2);
    SELECT IFNULL(SUM(pd.cantidad), 0)
    INTO v_rendimiento_total
    FROM Productos_de_produccion pd
    JOIN Animales_para_produccion ap ON pd.id_produccion = ap.id_produccion
    WHERE ap.id_produccion = p_id_produccion;
    RETURN v_rendimiento_total;
END //

DELIMITER ;

-- 17. Calcular el costo operativo de un cultivo por hectárea
-- Esta función calcula el costo operativo por hectárea de un cultivo específico.
DELIMITER //

CREATE FUNCTION CostoOperativoPorHectareaCultivo(p_id_cultivo INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_costo_operativo DECIMAL(10,2);
    SELECT IFNULL(SUM(p.costo) / c.areas_hectareas, 0)
    INTO v_costo_operativo
    FROM Producciones p
    JOIN Cultivos_para_produccion cp ON p.id_produccion = cp.id_produccion
    JOIN Cultivos c ON cp.id_cultivo = c.id_cultivo
    WHERE c.id_cultivo = p_id_cultivo;
    RETURN v_costo_operativo;
END //

DELIMITER ;

-- 18. Calcular la ganancia total por producción
-- Esta función calcula la ganancia obtenida en una producción en base a los productos vendidos.
DELIMITER //

CREATE FUNCTION GananciaTotalProduccion(p_id_produccion INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_ganancia_total DECIMAL(10,2);
    SELECT IFNULL(SUM(dv.cantidad * p.precio), 0)
    INTO v_ganancia_total
    FROM Detalles_venta dv
    JOIN Productos p ON dv.id_producto = p.id_producto
    WHERE p.id_producto IN (SELECT id_producto FROM Productos_de_produccion WHERE id_produccion = p_id_produccion);
    RETURN v_ganancia_total;
END //

DELIMITER ;

-- 19. Calcular el costo de insumos por hectárea de cultivo
-- Esta función calcula el costo total de insumos utilizados en un cultivo por hectárea.
DELIMITER //

CREATE FUNCTION CostoInsumosPorHectareaCultivo(p_id_cultivo INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_costo_insumos DECIMAL(10,2);
    SELECT IFNULL(SUM(ai.precio_unitario * ae.cantidad) / c.areas_hectareas, 0)
    INTO v_costo_insumos
    FROM Activos_en_tarea ae
    JOIN Activos_insumos ai ON ae.id_activo = ai.id_activo
    JOIN Tareas t ON t.id_tarea = ae.id_tarea
    JOIN Cultivos c ON t.id_tarea = c.id_cultivo
    WHERE c.id_cultivo = p_id_cultivo;
    RETURN v_costo_insumos;
END //

DELIMITER ;

-- 20. Calcular la duración promedio de las tareas
-- Esta función calcula la duración promedio de las tareas en la finca.
DELIMITER //

CREATE FUNCTION DuracionPromedioTareas()
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_duracion_promedio DECIMAL(10,2);
    SELECT IFNULL(AVG(TIMESTAMPDIFF(HOUR, t.hora_inicio, t.hora_fin)), 0)
    INTO v_duracion_promedio
    FROM Tareas t;
    RETURN v_duracion_promedio;
END //

DELIMITER ;