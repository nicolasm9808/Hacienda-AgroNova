-- 1. Actualizar inventario cuando se inserta una nueva venta
-- Este trigger resta automáticamente las cantidades vendidas del inventario de productos cuando se inserta una nueva venta.
CREATE TRIGGER ActualizarInventarioVenta
AFTER INSERT ON Detalles_venta
FOR EACH ROW
BEGIN
    UPDATE Productos
    SET cantidad = cantidad - NEW.cantidad
    WHERE id_producto = NEW.id_producto;
END;

-- 2. Registrar cambios en el salario de un empleado
-- Este trigger registra el cambio de salario en una tabla de historial cuando se actualiza el salario de un empleado.
CREATE TRIGGER RegistrarCambioSalario
AFTER UPDATE ON Empleados
FOR EACH ROW
BEGIN
    IF OLD.salario != NEW.salario THEN
        INSERT INTO Historial_salarios (id_empleado, salario_anterior, nuevo_salario, fecha_cambio)
        VALUES (NEW.id_empleado, OLD.salario, NEW.salario, CURDATE());
    END IF;
END;

-- 3. Verificar disponibilidad de maquinaria antes de asignarla a una tarea
-- Este trigger impide que una máquina que esté en mantenimiento o fuera de servicio se asigne a una tarea.
CREATE TRIGGER VerificarDisponibilidadMaquina
BEFORE INSERT ON Activos_en_tarea
FOR EACH ROW
BEGIN
    DECLARE v_estado INT;
    IF (SELECT id_estado FROM Maquinas WHERE id_activo = NEW.id_activo) != (SELECT id_estado FROM Estados WHERE estado = 'Disponible') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La máquina no está disponible para esta tarea.';
    END IF;
END;

-- 4. Registrar historial de cambios en las tareas
-- Este trigger guarda el historial de cambios en el estado de las tareas.
CREATE TRIGGER RegistrarHistorialTarea
AFTER UPDATE ON Tareas
FOR EACH ROW
BEGIN
    IF OLD.id_estado != NEW.id_estado THEN
        INSERT INTO Historial_tareas (id_tarea, estado_anterior, nuevo_estado, fecha_cambio)
        VALUES (NEW.id_tarea, OLD.id_estado, NEW.id_estado, CURDATE());
    END IF;
END;

-- 5. Verificar stock antes de insertar una venta
-- Este trigger impide registrar una venta si no hay suficiente stock disponible.
CREATE TRIGGER VerificarStockAntesVenta
BEFORE INSERT ON Detalles_venta
FOR EACH ROW
BEGIN
    IF (SELECT cantidad FROM Productos WHERE id_producto = NEW.id_producto) < NEW.cantidad THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stock insuficiente para la venta.';
    END IF;
END;

-- 6. Actualizar capacidad disponible de locaciones al insertar productos
-- Este trigger actualiza la capacidad disponible de una locación de almacenamiento cuando se agrega un nuevo producto.
CREATE TRIGGER ActualizarCapacidadLocacion
AFTER INSERT ON Productos_en_locacion
FOR EACH ROW
BEGIN
    UPDATE Locaciones_almacenamiento
    SET capacidad_disponible = capacidad_disponible - NEW.cantidad
    WHERE id_locacion = NEW.id_locacion;
END;

-- 7. Restaurar capacidad de locaciones al eliminar productos
-- Este trigger restaura la capacidad disponible de una locación cuando se elimina un producto.
CREATE TRIGGER RestaurarCapacidadLocacion
AFTER DELETE ON Productos_en_locacion
FOR EACH ROW
BEGIN
    UPDATE Locaciones_almacenamiento
    SET capacidad_disponible = capacidad_disponible + OLD.cantidad
    WHERE id_locacion = OLD.id_locacion;
END;

-- 8. Registrar cambios en el precio de productos
-- Este trigger registra un cambio de precio de productos en una tabla de historial cuando se actualiza el precio.
CREATE TRIGGER RegistrarCambioPrecioProducto
AFTER UPDATE ON Productos
FOR EACH ROW
BEGIN
    IF OLD.precio != NEW.precio THEN
        INSERT INTO Historial_precios (id_producto, precio_anterior, nuevo_precio, fecha_cambio)
        VALUES (NEW.id_producto, OLD.precio, NEW.precio, CURDATE());
    END IF;
END;

-- 9. Actualizar stock de insumos al registrar una compra
-- Este trigger actualiza automáticamente el stock de insumos cuando se inserta un nuevo detalle de compra.
CREATE TRIGGER ActualizarStockInsumoCompra
AFTER INSERT ON Detalles_compra
FOR EACH ROW
BEGIN
    UPDATE Insumos
    SET cantidad = cantidad + NEW.cantidad
    WHERE id_activo = NEW.id_activo;
END;

-- 10. Registrar historial de compras a proveedores
-- Este trigger registra la compra de insumos en una tabla de historial cada vez que se inserta una nueva compra.
CREATE TRIGGER RegistrarHistorialComprasProveedores
AFTER INSERT ON Compras
FOR EACH ROW
BEGIN
    INSERT INTO Historial_compras (id_proveedor, id_compra, fecha_compra, total_compra)
    VALUES (NEW.id_proveedor, NEW.id_compra, NEW.fecha, NEW.total);
END;

-- 11. Verificar vencimiento de insumos al actualizar stock
-- Este trigger verifica el vencimiento de insumos cuando se actualiza su cantidad, cambiando su estado si están vencidos.
CREATE TRIGGER VerificarVencimientoInsumos
AFTER UPDATE ON Insumos
FOR EACH ROW
BEGIN
    IF NEW.fecha_vencimiento <= CURDATE() THEN
        UPDATE Insumos
        SET id_estado = (SELECT id_estado FROM Estados WHERE estado = 'Vencido')
        WHERE id_insumo = NEW.id_insumo;
    END IF;
END;

-- 12. Actualizar cantidad de empleados asignados a una tarea
-- Este trigger actualiza la cantidad total de empleados asignados a una tarea al insertar o eliminar empleados de la tarea.
CREATE TRIGGER ActualizarCantidadEmpleadosEnTarea
AFTER INSERT OR DELETE ON Empleados_en_tarea
FOR EACH ROW
BEGIN
    DECLARE v_total INT;
    SET v_total = (SELECT COUNT(*) FROM Empleados_en_tarea WHERE id_tarea = NEW.id_tarea);
    
    UPDATE Tareas
    SET total_empleados = v_total
    WHERE id_tarea = NEW.id_tarea;
END;

-- 13. Bloquear inserciones de empleados menores de edad
-- Este trigger impide que se inserten empleados menores de 18 años.
CREATE TRIGGER BloquearEmpleadosMenoresDeEdad
BEFORE INSERT ON Empleados
FOR EACH ROW
BEGIN
    IF NEW.edad < 18 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede insertar empleados menores de 18 años.';
    END IF;
END;

-- 14. Actualizar el estado de cultivos después de la siembra
-- Este trigger actualiza automáticamente el estado de un cultivo a "En crecimiento" cuando se siembra.
CREATE TRIGGER ActualizarEstadoCultivoDespuesSiembra
AFTER INSERT ON Cultivos
FOR EACH ROW
BEGIN
    UPDATE Cultivos
    SET id_estado_cultivo = (SELECT id_estado_cultivo FROM Estados_cultivo WHERE estado = 'En crecimiento')
    WHERE id_cultivo = NEW.id_cultivo;
END;

-- 15. Prevenir eliminar productos con stock positivo
-- Este trigger impide que se eliminen productos si aún tienen stock positivo.
CREATE TRIGGER PrevenirEliminarProductosConStock
BEFORE DELETE ON Productos
FOR EACH ROW
BEGIN
    IF OLD.cantidad > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se pueden eliminar productos con stock disponible.';
    END IF;
END;

-- 16. Verificar duplicidad de proveedores por nombre y ubicación
-- Este trigger impide la inserción de proveedores duplicados con el mismo nombre y ubicación.
CREATE TRIGGER VerificarDuplicidadProveedor
BEFORE INSERT ON Proveedores
FOR EACH ROW
BEGIN
    IF (SELECT COUNT(*) FROM Proveedores WHERE nombre = NEW.nombre AND id_ubicacion = NEW.id_ubicacion) > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El proveedor ya existe en esta ubicación.';
    END IF;
END;

-- 17. Actualizar automáticamente el estado de equipos de trabajo
-- Este trigger actualiza el estado de equipos de trabajo a "En mantenimiento" cuando se asocian con una tarea de mantenimiento.
CREATE TRIGGER ActualizarEstadoEquipoTrabajo
AFTER INSERT ON Activos_en_tarea
FOR EACH ROW
BEGIN
    IF (SELECT id_tipo_tarea FROM Tareas WHERE id_tarea = NEW.id_tarea) = (SELECT id_tipo_tarea FROM Tipos_tarea WHERE tipo = 'Mantenimiento') THEN
        UPDATE Equipos_de_trabajo
        SET id_estado = (SELECT id_estado FROM Estados WHERE estado = 'En mantenimiento')
        WHERE id_activo = NEW.id_activo;
    END IF;
END;

-- 18. Registrar cambios en la ubicación de clientes
-- Este trigger guarda en una tabla de historial cualquier cambio en la ubicación de un cliente.
CREATE TRIGGER RegistrarCambioUbicacionCliente
AFTER UPDATE ON Clientes
FOR EACH ROW
BEGIN
    IF OLD.id_ubicacion != NEW.id_ubicacion THEN
        INSERT INTO Historial_cambios_ubicacion (id_cliente, ubicacion_anterior, nueva_ubicacion, fecha_cambio)
        VALUES (NEW.id_cliente, OLD.id_ubicacion, NEW.id_ubicacion, CURDATE());
    END IF;
END;

-- 19. Verificar cantidad mínima de empleados asignados a tareas críticas
-- Este trigger verifica que una tarea crítica tenga al menos 2 empleados asignados.
CREATE TRIGGER VerificarEmpleadosMinimosTareaCritica
BEFORE INSERT ON Empleados_en_tarea
FOR EACH ROW
BEGIN
    IF (SELECT id_tipo_tarea FROM Tareas WHERE id_tarea = NEW.id_tarea) = (SELECT id_tipo_tarea FROM Tipos_tarea WHERE tipo = 'Crítica') AND 
       (SELECT COUNT(*) FROM Empleados_en_tarea WHERE id_tarea = NEW.id_tarea) < 2 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Las tareas críticas deben tener al menos 2 empleados asignados.';
    END IF;
END;

-- 20. Actualizar estado de ventas después de ser completadas
-- Este trigger actualiza el estado de una venta a "Completada" cuando se registran todos los detalles de venta.
CREATE TRIGGER ActualizarEstadoVenta
AFTER INSERT ON Detalles_venta
FOR EACH ROW
BEGIN
    UPDATE Ventas
    SET id_estado = (SELECT id_estado FROM Estados_venta WHERE estado = 'Completada')
    WHERE id_venta = NEW.id_venta;
END;