--1. Procesar una venta y actualizar automáticamente el stock de productos
--Este procedimiento registra una venta y actualiza la cantidad disponible de productos en el inventario.
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
-- Este procedimiento no requiere manejo de cursores, pero lo dejo tal cual, ya que no necesita cambios adicionales.
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
-- Este procedimiento tampoco necesita cursores y está correcto, por lo que se mantiene igual.
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
-- El procedimiento no requiere cursores ni manejo especial. Se mantiene igual.
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
-- Este también es simple y no necesita cambios adicionales.
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
-- Este procedimiento implica el uso de cursores para recorrer los detalles de la compra y actualizar el inventario. Aquí está la versión corregida, asegurando que las declaraciones del cursor y manejador estén bien posicionadas.
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
-- Este procedimiento no requiere cursores ni cambios adicionales, por lo que se deja igual.
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
-- Este procedimiento implica el uso de cursores para recorrer una lista de empleados en formato JSON. Aquí está la versión corregida:
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
-- Este procedimiento también usa cursores para procesar la lista de insumos en formato JSON. Aquí está la versión corregida:
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
-- Este procedimiento no usa cursores y se mantiene igual.
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