-- 1. Procesar una venta y actualizar automáticamente el stock de productos
-- Este procedimiento permite registrar una venta y actualiza automáticamente el stock
DELIMITER //

CREATE PROCEDURE ProcesarVenta(
    IN p_fecha DATE,
    IN p_id_empleado INT,
    IN p_id_cliente INT,
    IN p_total DECIMAL(10, 2),
    IN p_productos JSON -- Ejemplo: '[{"id_producto":1, "cantidad": 10}, {"id_producto":2, "cantidad": 5}]'
)
BEGIN
    DECLARE v_id_venta INT;
    DECLARE v_cantidad INT;
    DECLARE v_id_producto INT;

    -- Variables de control de cursor
    DECLARE done INT DEFAULT 0;

    -- Cursor para recorrer los productos
    DECLARE cur CURSOR FOR 
        SELECT JSON_UNQUOTE(JSON_EXTRACT(value, '$.id_producto')), 
               JSON_UNQUOTE(JSON_EXTRACT(value, '$.cantidad'))
        FROM JSON_TABLE(p_productos, '$[*]' COLUMNS (value JSON PATH '$')) AS producto;

    -- Manejador para salir del cursor cuando termine
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    -- Insertar la venta en la tabla Ventas
    INSERT INTO Ventas (fecha, id_empleado, id_cliente, total)
    VALUES (p_fecha, p_id_empleado, p_id_cliente, p_total);
    
    -- Obtener el ID de la venta recién creada
    SET v_id_venta = LAST_INSERT_ID();

    -- Abrir el cursor
    OPEN cur;

    -- Loop para procesar cada producto vendido
    read_loop: LOOP
        FETCH cur INTO v_id_producto, v_cantidad;

        -- Verificar si el cursor ha terminado
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Insertar el detalle de la venta
        INSERT INTO Detalles_venta (id_venta, id_producto, cantidad)
        VALUES (v_id_venta, v_id_producto, v_cantidad);

        -- Actualizar la cantidad del producto en inventario
        UPDATE Productos 
        SET cantidad = cantidad - v_cantidad
        WHERE id_producto = v_id_producto;
    END LOOP;

    -- Cerrar el cursor
    CLOSE cur;
END //

DELIMITER ;


-- 2. Registrar un nuevo proveedor
-- Este procedimiento permite registrar un nuevo proveedor
DELIMITER //

CREATE PROCEDURE RegistrarProveedor(
    IN p_nombre VARCHAR(255),
    IN p_telefono VARCHAR(15),
    IN p_correo VARCHAR(255),
    IN p_id_ubicacion INT
)
BEGIN
    INSERT INTO Proveedores (nombre, telefono, correo, id_ubicacion)
    VALUES (p_nombre, p_telefono, p_correo, p_id_ubicacion);
END //

DELIMITER ;

-- 3. Registrar un nuevo empleado
-- Este procedimiento permite registrar un nuevo empleado
DELIMITER //

CREATE PROCEDURE RegistrarEmpleado(
    IN p_nombre VARCHAR(255),
    IN p_edad INT,
    IN p_id_cargo INT,
    IN p_salario DECIMAL(10, 2),
    IN p_telefono VARCHAR(15),
    IN p_fecha_contratacion DATE
)
BEGIN
    INSERT INTO Empleados (nombre, edad, id_cargo, salario, telefono, fecha_contratacion)
    VALUES (p_nombre, p_edad, p_id_cargo, p_salario, p_telefono, p_fecha_contratacion);
END //

DELIMITER ;

-- 4. Actualizar el estado de una máquina
-- Este procedimiento actualiza el estado de una máquina específica
DELIMITER //

CREATE PROCEDURE ActualizarEstadoMaquina(
    IN p_id_maquina INT,
    IN p_nuevo_estado INT
)
BEGIN
    UPDATE Maquinas
    SET id_estado = p_nuevo_estado
    WHERE id_maquina = p_id_maquina;
END //

DELIMITER ;

-- 5. Actualizar el estado de equipo de trabajo
DELIMITER //

CREATE PROCEDURE ActualizarEstadoEquipo(
    IN p_id_equipo INT,
    IN p_nuevo_estado INT
)
BEGIN
    UPDATE Equipos_de_trabajo
    SET id_estado = p_nuevo_estado
    WHERE id_equipo = p_id_equipo;
END //

DELIMITER ;

-- 6. Registrar una compra y actualizar el inventario
-- Este procedimiento registra una nueva compra y actualiza el inventario de los activos
DELIMITER //

CREATE PROCEDURE RegistrarCompra(
    IN p_fecha DATE,
    IN p_id_proveedor INT,
    IN p_total DECIMAL(10, 2),
    IN p_detalles JSON -- Ejemplo: '[{"id_activo":1, "cantidad": 10, "precio_unitario": 15.50}]'
)
BEGIN
    DECLARE v_id_compra INT;
    DECLARE v_cantidad INT;
    DECLARE v_id_activo INT;
    DECLARE v_precio_unitario DECIMAL(10,2);
    DECLARE done INT DEFAULT 0;

    -- Cursor para recorrer los detalles de la compra
    DECLARE cur CURSOR FOR 
        SELECT JSON_UNQUOTE(JSON_EXTRACT(value, '$.id_activo')), 
               JSON_UNQUOTE(JSON_EXTRACT(value, '$.cantidad')),
               JSON_UNQUOTE(JSON_EXTRACT(value, '$.precio_unitario'))
        FROM JSON_TABLE(p_detalles, '$[*]' COLUMNS (value JSON PATH '$')) AS detalle;

    -- Manejador para el fin del cursor
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    -- Insertar compra
    INSERT INTO Compras (fecha, id_proveedor, total)
    VALUES (p_fecha, p_id_proveedor, p_total);
    SET v_id_compra = LAST_INSERT_ID();

    -- Abrir el cursor
    OPEN cur;

    -- Procesar los detalles de la compra
    read_loop: LOOP
        FETCH cur INTO v_id_activo, v_cantidad, v_precio_unitario;

        -- Verificar si el cursor terminó
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Insertar detalles de la compra
        INSERT INTO Detalles_compra (id_compra, id_activo, precio_unitario, cantidad)
        VALUES (v_id_compra, v_id_activo, v_precio_unitario, v_cantidad);

        -- Actualizar inventario de activos/insumos
        UPDATE Activos_insumos
        SET cantidad = cantidad + v_cantidad
        WHERE id_activo = v_id_activo;
    END LOOP;

    -- Cerrar el cursor
    CLOSE cur;
END //

DELIMITER ;

-- 7. Registrar una nueva tarea
-- Este procedimiento registra una nueva tarea
DELIMITER //

CREATE PROCEDURE RegistrarTarea(
    IN p_descripcion_tarea TEXT,
    IN p_id_tipo_tarea INT,
    IN p_fecha DATE,
    IN p_id_estado INT
)
BEGIN
    INSERT INTO Tareas (descripcion_tarea, id_tipo_tarea, fecha, id_estado)
    VALUES (p_descripcion_tarea, p_id_tipo_tarea, p_fecha, p_id_estado);
END //

DELIMITER ;

-- 8. Asignar empleados a una tarea
-- Este procedimiento permite asignar empleados a una tarea
DELIMITER //

CREATE PROCEDURE AsignarEmpleadosATarea(
    IN p_id_tarea INT,
    IN p_empleados JSON -- Ejemplo: '[1, 2, 3]'
)
BEGIN
    DECLARE v_id_empleado INT;
    DECLARE done INT DEFAULT 0;

    -- Cursor para recorrer los empleados
    DECLARE cur CURSOR FOR 
        SELECT JSON_UNQUOTE(JSON_EXTRACT(value, '$'))
        FROM JSON_TABLE(p_empleados, '$[*]' COLUMNS (value JSON PATH '$')) AS empleado;

    -- Manejador para el fin del cursor
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    -- Abrir el cursor
    OPEN cur;

    -- Loop para procesar empleados
    read_loop: LOOP
        FETCH cur INTO v_id_empleado;

        -- Verificar si el cursor terminó
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Insertar relación empleado-tarea
        INSERT INTO Empleados_en_tarea (id_tarea, id_empleado)
        VALUES (p_id_tarea, v_id_empleado);
    END LOOP;

    -- Cerrar el cursor
    CLOSE cur;
END //

DELIMITER ;

-- 9. Asignar insumos a una tarea
-- Este procedimiento permite asignar insumos a una tarea
DELIMITER //

CREATE PROCEDURE AsignarInsumosATarea(
    IN p_id_tarea INT,
    IN p_insumos JSON -- Ejemplo: '[{"id_activo":1, "cantidad": 5}]'
)
BEGIN
    DECLARE v_id_activo INT;
    DECLARE v_cantidad INT;
    DECLARE done INT DEFAULT 0;

    -- Cursor para recorrer los insumos
    DECLARE cur CURSOR FOR 
        SELECT JSON_UNQUOTE(JSON_EXTRACT(value, '$.id_activo')), 
               JSON_UNQUOTE(JSON_EXTRACT(value, '$.cantidad'))
        FROM JSON_TABLE(p_insumos, '$[*]' COLUMNS (value JSON PATH '$')) AS insumo;

    -- Manejador para el fin del cursor
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    -- Abrir el cursor
    OPEN cur;

    -- Loop para procesar insumos
    read_loop: LOOP
        FETCH cur INTO v_id_activo, v_cantidad;

        -- Verificar si el cursor terminó
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Insertar insumo en tarea
        INSERT INTO Activos_en_tarea (id_tarea, id_activo, cantidad)
        VALUES (p_id_tarea, v_id_activo, v_cantidad);
    END LOOP;

    -- Cerrar el cursor
    CLOSE cur;
END //

DELIMITER ;

-- 10. Registrar una producción de cultivos
-- Este procedimiento registra una nueva producción de cultivos
DELIMITER //

CREATE PROCEDURE RegistrarProduccionCultivo(
    IN p_id_cultivo INT,
    IN p_costo DECIMAL(10,2),
    IN p_fecha DATE
)
BEGIN
    DECLARE v_id_produccion INT;

    -- Insertar producción
    INSERT INTO Producciones (costo, fecha)
    VALUES (p_costo, p_fecha);
    SET v_id_produccion = LAST_INSERT_ID();

    -- Relacionar con el cultivo
    INSERT INTO Cultivos_para_produccion (id_produccion, id_cultivo)
    VALUES (v_id_produccion, p_id_cultivo);
END //

DELIMITER ;


-- 11. Asignar vehículos a una tarea
-- Este procedimiento asigna vehículos a una tarea específica.
DELIMITER //

CREATE PROCEDURE AsignarVehiculoATarea(
    IN p_id_tarea INT,
    IN p_id_vehiculo INT
)
BEGIN
    INSERT INTO Activos_en_tarea (id_tarea, id_activo, cantidad)
    VALUES (p_id_tarea, (SELECT id_activo FROM Vehiculos WHERE id_vehiculo = p_id_vehiculo), 1);
END //

DELIMITER ;

-- 12. Actualizar la cantidad de insumos en el inventario
-- Este procedimiento permite actualizar manualmente la cantidad de insumos en el inventario.
DELIMITER //

CREATE PROCEDURE ActualizarCantidadInsumo(
    IN p_id_insumo INT,
    IN p_nueva_cantidad INT
)
BEGIN
    UPDATE Insumos
    SET cantidad = p_nueva_cantidad
    WHERE id_insumo = p_id_insumo;
END //

DELIMITER ;

-- 13. Registrar un mantenimiento de equipo de trabajo
-- Este procedimiento registra una tarea de mantenimiento y actualiza el estado del equipo de trabajo.
DELIMITER //

CREATE PROCEDURE RegistrarMantenimientoEquipo(
    IN p_id_equipo INT,
    IN p_descripcion TEXT,
    IN p_fecha DATE,
    IN p_nuevo_estado INT
)
BEGIN
    DECLARE v_id_tarea INT;

    -- Registrar la tarea de mantenimiento
    INSERT INTO Tareas (descripcion_tarea, id_tipo_tarea, fecha, id_estado)
    VALUES (p_descripcion, 2, p_fecha, p_nuevo_estado);  -- Suponiendo que el tipo 2 es mantenimiento
    SET v_id_tarea = LAST_INSERT_ID();

    -- Actualizar estado del equipo de trabajo
    UPDATE Equipos_de_trabajo
    SET id_estado = p_nuevo_estado
    WHERE id_equipo = p_id_equipo;

    -- Registrar el equipo en la tarea
    INSERT INTO Activos_en_tarea (id_tarea, id_activo, cantidad)
    VALUES (v_id_tarea, (SELECT id_activo FROM Equipos_de_trabajo WHERE id_equipo = p_id_equipo), 1);
END //

DELIMITER ;

-- 14. Registrar una venta de productos agrícolas
-- Este procedimiento es específico para registrar ventas de productos agrícolas.
DELIMITER //

CREATE PROCEDURE RegistrarVentaProducto(
    IN p_fecha DATE,
    IN p_id_empleado INT,
    IN p_id_cliente INT,
    IN p_total DECIMAL(10, 2),
    IN p_productos JSON -- Ejemplo: '[{"id_producto":1, "cantidad": 10}]'
)
BEGIN
    DECLARE v_id_venta INT;
    DECLARE v_id_producto INT;
    DECLARE v_cantidad INT;
    DECLARE done INT DEFAULT 0;

    -- Cursor para productos
    DECLARE cur CURSOR FOR
        SELECT JSON_UNQUOTE(JSON_EXTRACT(value, '$.id_producto')),
               JSON_UNQUOTE(JSON_EXTRACT(value, '$.cantidad'))
        FROM JSON_TABLE(p_productos, '$[*]' COLUMNS (value JSON PATH '$')) AS producto;

    -- Manejador de cursor
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    -- Insertar venta
    INSERT INTO Ventas (fecha, id_empleado, id_cliente, total)
    VALUES (p_fecha, p_id_empleado, p_id_cliente, p_total);
    SET v_id_venta = LAST_INSERT_ID();

    -- Abrir cursor
    OPEN cur;

    -- Procesar cada producto
    read_loop: LOOP
        FETCH cur INTO v_id_producto, v_cantidad;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Insertar detalle de venta
        INSERT INTO Detalles_venta (id_venta, id_producto, cantidad)
        VALUES (v_id_venta, v_id_producto, v_cantidad);

        -- Actualizar inventario
        UPDATE Productos
        SET cantidad = cantidad - v_cantidad
        WHERE id_producto = v_id_producto;
    END LOOP;

    -- Cerrar cursor
    CLOSE cur;
END //

DELIMITER ;

-- 15. Registrar un nuevo cliente
-- Este procedimiento permite registrar un cliente con su información básica.
DELIMITER //

CREATE PROCEDURE RegistrarCliente(
    IN p_nombre VARCHAR(255),
    IN p_telefono VARCHAR(15),
    IN p_correo VARCHAR(255),
    IN p_id_ubicacion INT,
    IN p_id_tipo_cliente INT
)
BEGIN
    INSERT INTO Clientes (nombre, telefono, correo, id_ubicacion, id_tipo_cliente)
    VALUES (p_nombre, p_telefono, p_correo, p_id_ubicacion, p_id_tipo_cliente);
END //

DELIMITER ;

-- 16. Generar reporte de ventas por fecha
-- Este procedimiento genera un reporte de todas las ventas en un rango de fechas.
DELIMITER //

CREATE PROCEDURE ReporteVentasPorFecha(
    IN p_fecha_inicio DATE,
    IN p_fecha_fin DATE
)
BEGIN
    SELECT V.id_venta, V.fecha, V.total, C.nombre AS cliente, E.nombre AS empleado
    FROM Ventas V
    JOIN Clientes C ON V.id_cliente = C.id_cliente
    JOIN Empleados E ON V.id_empleado = E.id_empleado
    WHERE V.fecha BETWEEN p_fecha_inicio AND p_fecha_fin
    ORDER BY V.fecha;
END //

DELIMITER ;

-- 17. Generar reporte de compras por proveedor
-- Este procedimiento genera un reporte de todas las compras hechas a un proveedor específico.
DELIMITER //

CREATE PROCEDURE ReporteComprasPorProveedor(
    IN p_id_proveedor INT
)
BEGIN
    SELECT C.id_compra, C.fecha, C.total, P.nombre AS proveedor
    FROM Compras C
    JOIN Proveedores P ON C.id_proveedor = P.id_proveedor
    WHERE P.id_proveedor = p_id_proveedor
    ORDER BY C.fecha;
END //

DELIMITER ;

-- 18. Registrar un nuevo cultivo
-- Este procedimiento inserta un nuevo cultivo en la base de datos.
DELIMITER //

CREATE PROCEDURE RegistrarCultivo(
    IN p_nombre VARCHAR(100),
    IN p_areas_hectareas DECIMAL(10,2),
    IN p_id_estado_cultivo INT,
    IN p_fecha_siembra DATE
)
BEGIN
    INSERT INTO Cultivos (nombre, areas_hectareas, id_estado_cultivo, fecha_siembra)
    VALUES (p_nombre, p_areas_hectareas, p_id_estado_cultivo, p_fecha_siembra);
END //

DELIMITER ;

-- 19. Actualizar precio de producto
-- Este procedimiento permite actualizar el precio de un producto.
DELIMITER //

CREATE PROCEDURE ActualizarPrecioProducto(
    IN p_id_producto INT,
    IN p_nuevo_precio DECIMAL(10,2)
)
BEGIN
    UPDATE Productos
    SET precio = p_nuevo_precio
    WHERE id_producto = p_id_producto;
END //

DELIMITER ;

-- 20. Actualizar ubicación de un cliente
-- Este procedimiento permite cambiar la ubicación de un cliente.
DELIMITER //

CREATE PROCEDURE ActualizarUbicacionCliente(
    IN p_id_cliente INT,
    IN p_nueva_ubicacion INT
)
BEGIN
    UPDATE Clientes
    SET id_ubicacion = p_nueva_ubicacion
    WHERE id_cliente = p_id_cliente;
END //

DELIMITER ;