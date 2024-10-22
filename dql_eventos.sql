-- 1. Generar un reporte mensual de ventas
-- Este evento genera un reporte de todas las ventas del mes anterior, programado para ejecutarse el primer día de cada mes.
CREATE EVENT GenerarReporteMensualVentas
ON SCHEDULE EVERY 1 MONTH
STARTS '2024-11-01 00:00:00'
DO
BEGIN
    INSERT INTO Reportes_ventas (mes, total_ventas)
    SELECT MONTH(CURDATE() - INTERVAL 1 MONTH), SUM(total)
    FROM Ventas
    WHERE MONTH(fecha) = MONTH(CURDATE() - INTERVAL 1 MONTH);
END;

-- 2. Generar un reporte mensual de producción
-- Este evento genera un reporte de la producción mensual el primer día de cada mes.
CREATE EVENT GenerarReporteMensualProduccion
ON SCHEDULE EVERY 1 MONTH
STARTS '2024-11-01 00:00:00'
DO
BEGIN
    INSERT INTO Reportes_produccion (mes, total_producido)
    SELECT MONTH(CURDATE() - INTERVAL 1 MONTH), SUM(cantidad)
    FROM Productos_de_produccion
    WHERE MONTH(fecha) = MONTH(CURDATE() - INTERVAL 1 MONTH);
END;

-- 3. Actualizar automáticamente el salario de empleados
-- Este evento ajusta los salarios de los empleados cada año, por ejemplo, un incremento del 5%.
CREATE EVENT AjustarSalarioAnualEmpleados
ON SCHEDULE EVERY 1 YEAR
STARTS '2024-01-01 00:00:00'
DO
BEGIN
    UPDATE Empleados
    SET salario = salario * 1.05;  -- Incrementa el salario en un 5%
END;

-- 4. Actualizar inventario de productos al final de cada día
-- Este evento verifica y ajusta automáticamente los productos que estén por agotarse en el inventario.
CREATE EVENT ActualizarInventarioProductosDiario
ON SCHEDULE EVERY 1 DAY
STARTS '2024-10-22 23:59:59'
DO
BEGIN
    UPDATE Productos
    SET cantidad = 0
    WHERE cantidad < 0;
END;

-- 5. Limpiar datos de productos antiguos en locaciones cada semana
-- Este evento elimina registros antiguos de productos en las locaciones, ejecutándose cada domingo.
CREATE EVENT LimpiarProductosAntiguosLocacion
ON SCHEDULE EVERY 1 WEEK
STARTS '2024-10-27 00:00:00'
DO
BEGIN
    DELETE FROM Productos_en_locacion
    WHERE DATEDIFF(CURDATE(), (SELECT fecha FROM Ventas WHERE id_producto = Productos_en_locacion.id_producto)) > 365;
END;

-- 6. Recalcular el rendimiento promedio de cultivos cada mes
-- Este evento recalcula el rendimiento promedio por hectárea para cada cultivo.
CREATE EVENT RecalcularRendimientoPromedioCultivos
ON SCHEDULE EVERY 1 MONTH
STARTS '2024-11-01 00:00:00'
DO
BEGIN
    UPDATE Cultivos
    SET rendimiento_hectarea = (SELECT RendimientoPromedioHectarea(Cultivos.id_cultivo));
END;

-- 7. Verificar y actualizar el estado de maquinaria cada semana
-- Este evento actualiza automáticamente el estado de las máquinas dependiendo de si han sido utilizadas en tareas de mantenimiento.
CREATE EVENT ActualizarEstadoMaquinariaSemanal
ON SCHEDULE EVERY 1 WEEK
STARTS '2024-10-22 00:00:00'
DO
BEGIN
    UPDATE Maquinas
    SET id_estado = (SELECT id_estado FROM Estados WHERE estado = 'Mantenimiento')
    WHERE id_maquina IN (SELECT id_activo FROM Activos_en_tarea WHERE id_tarea IN (SELECT id_tarea FROM Tareas WHERE id_tipo_tarea = 2));
END;

-- 8. Ajustar el stock de insumos cada fin de mes
-- Este evento ajusta el stock de insumos al final de cada mes en función de los consumos registrados.
CREATE EVENT AjustarStockInsumosMensual
ON SCHEDULE EVERY 1 MONTH
STARTS '2024-11-01 00:00:00'
DO
BEGIN
    UPDATE Insumos
    SET cantidad = cantidad - (SELECT IFNULL(SUM(cantidad), 0) FROM Activos_en_tarea WHERE id_activo = Insumos.id_activo);
END;

-- 9. Archivar registros de ventas antiguos cada trimestre
-- Este evento mueve las ventas antiguas a una tabla de archivo para evitar sobrecarga en la tabla principal.
CREATE EVENT ArchivarVentasAntiguasTrimestral
ON SCHEDULE EVERY 3 MONTH
STARTS '2024-12-01 00:00:00'
DO
BEGIN
    INSERT INTO Ventas_archivo
    SELECT * FROM Ventas
    WHERE fecha < CURDATE() - INTERVAL 1 YEAR;
    
    DELETE FROM Ventas WHERE fecha < CURDATE() - INTERVAL 1 YEAR;
END;

-- 10. Enviar recordatorios de pago a proveedores mensualmente
-- Este evento genera recordatorios automáticos para pagos pendientes a proveedores.
CREATE EVENT RecordatorioPagoProveedores
ON SCHEDULE EVERY 1 MONTH
STARTS '2024-11-01 08:00:00'
DO
BEGIN
    INSERT INTO Recordatorios (mensaje, fecha_envio)
    SELECT CONCAT('Pago pendiente al proveedor ', nombre), CURDATE()
    FROM Proveedores
    WHERE id_proveedor IN (SELECT id_proveedor FROM Compras WHERE total > 0 AND fecha < CURDATE() - INTERVAL 30 DAY);
END;

-- 11. Limpiar datos temporales de insumos cada fin de semana
-- Este evento limpia registros temporales de insumos utilizados en las tareas.
CREATE EVENT LimpiarDatosTemporalesInsumos
ON SCHEDULE EVERY 1 WEEK
STARTS '2024-10-27 23:59:59'
DO
BEGIN
    DELETE FROM Activos_en_tarea WHERE DATEDIFF(CURDATE(), fecha) > 7;
END;

-- 12. Verificar vencimiento de insumos mensualmente
-- Este evento revisa los insumos que están próximos a vencer y actualiza su estado.
CREATE EVENT VerificarVencimientoInsumos
ON SCHEDULE EVERY 1 MONTH
STARTS '2024-11-01 00:00:00'
DO
BEGIN
    UPDATE Insumos
    SET id_estado = (SELECT id_estado FROM Estados WHERE estado = 'Vencido')
    WHERE fecha_vencimiento <= CURDATE() + INTERVAL 1 MONTH;
END;

-- 13. Generar reporte de gastos de empleados cada trimestre
-- Este evento genera un reporte de todos los gastos asociados a salarios y bonificaciones de los empleados.
CREATE EVENT GenerarReporteGastosEmpleadosTrimestral
ON SCHEDULE EVERY 3 MONTH
STARTS '2024-12-01 00:00:00'
DO
BEGIN
    INSERT INTO Reportes_gastos_empleados (trimestre, total_gastos)
    SELECT QUARTER(CURDATE()), SUM(salario)
    FROM Empleados;
END;

-- 14. Actualizar disponibilidad de locaciones de almacenamiento
-- Este evento actualiza la capacidad disponible de cada locación al final de cada semana.
CREATE EVENT ActualizarCapacidadLocacionesSemanal
ON SCHEDULE EVERY 1 WEEK
STARTS '2024-10-27 00:00:00'
DO
BEGIN
    UPDATE Locaciones_almacenamiento
    SET capacidad_disponible = capacidad_maxima - (SELECT IFNULL(SUM(cantidad), 0) FROM Productos_en_locacion WHERE id_locacion = Locaciones_almacenamiento.id_locacion);
END;

-- 15. Enviar recordatorios de renovación de contratos cada mes
-- Este evento verifica los contratos que están próximos a vencer y envía recordatorios automáticos.
CREATE EVENT RecordatorioRenovacionContratos
ON SCHEDULE EVERY 1 MONTH
STARTS '2024-11-01 08:00:00'
DO
BEGIN
    INSERT INTO Recordatorios (mensaje, fecha_envio)
    SELECT CONCAT('Renovación de contrato para el empleado ', nombre), CURDATE()
    FROM Empleados
    WHERE fecha_contratacion <= CURDATE() - INTERVAL 1 YEAR;
END;

-- 16. Generar reporte de costos operativos mensualmente
-- Este evento genera un reporte mensual de costos operativos de la finca.
CREATE EVENT GenerarReporteCostosOperativosMensual
ON SCHEDULE EVERY 1 MONTH
STARTS '2024-11-01 00:00:00'
DO
BEGIN
    INSERT INTO Reportes_costos_operativos (mes, total_costos)
    SELECT MONTH(CURDATE() - INTERVAL 1 MONTH), SUM(costo)
    FROM Producciones
    WHERE fecha BETWEEN CURDATE() - INTERVAL 1 MONTH AND CURDATE();
END;

-- 17. Verificar stock bajo y generar alertas
-- Este evento verifica el stock bajo de productos y genera alertas para reposición.
CREATE EVENT VerificarStockBajo
ON SCHEDULE EVERY 1 DAY
STARTS '2024-10-22 08:00:00'
DO
BEGIN
    INSERT INTO Alertas (mensaje, fecha_alerta)
    SELECT CONCAT('Stock bajo para el producto ', nombre), CURDATE()
    FROM Productos
    WHERE cantidad <= 10;
END;

-- 18. Limpiar registros de logs antiguos trimestralmente
-- Este evento limpia los registros de logs de operaciones antiguas para optimizar el espacio.
CREATE EVENT LimpiarLogsAntiguos
ON SCHEDULE EVERY 3 MONTH
STARTS '2024-12-01 00:00:00'
DO
BEGIN
    DELETE FROM Logs WHERE fecha < CURDATE() - INTERVAL 1 YEAR;
END;

-- 19. Actualizar el estado de tareas pendientes semanalmente
-- Este evento actualiza el estado de tareas que aún no se han completado dentro de un plazo determinado.
CREATE EVENT ActualizarEstadoTareasPendientes
ON SCHEDULE EVERY 1 WEEK
STARTS '2024-10-27 00:00:00'
DO
BEGIN
    UPDATE Tareas
    SET id_estado = (SELECT id_estado FROM Estados_tarea WHERE estado = 'Atrasada')
    WHERE fecha < CURDATE() AND id_estado != (SELECT id_estado FROM Estados_tarea WHERE estado = 'Completada');
END;

-- 20. Verificar el rendimiento de empleados mensualmente
-- Este evento revisa el rendimiento de los empleados y genera un reporte mensual.
CREATE EVENT VerificarRendimientoEmpleados
ON SCHEDULE EVERY 1 MONTH
STARTS '2024-11-01 00:00:00'
DO
BEGIN
    INSERT INTO Reportes_rendimiento_empleados (mes, id_empleado, rendimiento)
    SELECT MONTH(CURDATE()), e.id_empleado, COUNT(t.id_tarea) AS tareas_completadas
    FROM Empleados e
    LEFT JOIN Empleados_en_tarea et ON e.id_empleado = et.id_empleado
    LEFT JOIN Tareas t ON et.id_tarea = t.id_tarea
    WHERE t.id_estado = (SELECT id_estado FROM Estados_tarea WHERE estado = 'Completada')
    GROUP BY e.id_empleado;
END;