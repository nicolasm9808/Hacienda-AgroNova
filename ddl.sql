CREATE DATABASE IF NOT EXISTS Hacienda_AgroNova;

USE Hacienda_AgroNova;

-- Tabla Especies
CREATE TABLE IF NOT EXISTS Especies (
    id_especie INT PRIMARY KEY,
    especie VARCHAR(100) NOT NULL UNIQUE
);

-- Tabla Estados_animales
CREATE TABLE IF NOT EXISTS Estados_animales (
    id_estado_animal INT PRIMARY KEY,
    estado VARCHAR(100) NOT NULL UNIQUE
);

-- Tabla Animales
CREATE TABLE IF NOT EXISTS Animales (
    id_animal INT PRIMARY KEY,
    id_especie INT NOT NULL,
    FOREIGN KEY (id_especie) REFERENCES Especies (id_especie),
    edad INT CHECK(edad >= 0),
    id_estado_animal INT NOT NULL,
    FOREIGN KEY (id_estado_animal) REFERENCES Estados_animales (id_estado_animal)
);

-- Tabla Estados_cultivo
CREATE TABLE IF NOT EXISTS Estados_cultivo (
    id_estado_cultivo INT PRIMARY KEY,
    estado VARCHAR(100) NOT NULL UNIQUE
);

-- Tabla Cultivos
CREATE TABLE IF NOT EXISTS Cultivos (
    id_cultivo INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    areas_hectareas DECIMAL(10, 2) NOT NULL CHECK(areas_hectareas > 0),
    id_estado_cultivo INT NOT NULL,
    FOREIGN KEY (id_estado_cultivo) REFERENCES Estados_cultivo (id_estado_cultivo),
    fecha_siembra DATE NOT NULL
);

-- Tabla Producciones
CREATE TABLE IF NOT EXISTS Producciones (
    id_produccion INT PRIMARY KEY,
    costo DECIMAL(10, 2) NOT NULL CHECK(costo >= 0),
    fecha DATE NOT NULL
);

-- Tabla Cultivos_para_produccion
CREATE TABLE IF NOT EXISTS Cultivos_para_produccion (
    id INT PRIMARY KEY,
    id_produccion INT NOT NULL,
    FOREIGN KEY (id_produccion) REFERENCES Producciones (id_produccion),
    id_cultivo INT NOT NULL,
    FOREIGN KEY (id_cultivo) REFERENCES Cultivos (id_cultivo)
);

-- Tabla Animales_para_produccion
CREATE TABLE IF NOT EXISTS Animales_para_produccion (
    id INT PRIMARY KEY,
    id_produccion INT NOT NULL,
    FOREIGN KEY (id_produccion) REFERENCES Producciones (id_produccion),
    id_animal INT NOT NULL,
    FOREIGN KEY (id_animal) REFERENCES Animales (id_animal),
    cantidad INT NOT NULL CHECK(cantidad >= 0)
);

-- Tabla Tipos_producto
CREATE TABLE IF NOT EXISTS Tipos_producto (
    id_tipo_producto INT PRIMARY KEY,
    tipo VARCHAR(100) NOT NULL
);

-- Tabla Productos
CREATE TABLE IF NOT EXISTS Productos (
    id_producto INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    id_tipo_producto INT NOT NULL,
    FOREIGN KEY (id_tipo_producto) REFERENCES Tipos_producto (id_tipo_producto),
    precio DECIMAL(10, 2) NOT NULL CHECK(precio >= 0),
    cantidad INT NOT NULL CHECK(cantidad >= 0)
);

-- Tabla Productos_de_produccion
CREATE TABLE IF NOT EXISTS Productos_de_produccion (
    id INT PRIMARY KEY,
    id_produccion INT NOT NULL,
    FOREIGN KEY (id_produccion) REFERENCES Producciones (id_produccion),
    id_producto INT NOT NULL,
    FOREIGN KEY (id_producto) REFERENCES Productos (id_producto),
    cantidad INT NOT NULL CHECK(cantidad >= 0)
);

-- Tabla Locaciones_almacenamiento
CREATE TABLE IF NOT EXISTS Locaciones_almacenamiento (
    id_locacion INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    capacidad_maxima INT NOT NULL CHECK(capacidad_maxima > 0),
    capacidad_disponible INT NOT NULL CHECK(capacidad_disponible >= 0)
);

-- Tabla Productos_en_locacion
CREATE TABLE IF NOT EXISTS Productos_en_locacion (
    id INT PRIMARY KEY,
    id_locacion INT NOT NULL,
    FOREIGN KEY (id_locacion) REFERENCES Locaciones_almacenamiento (id_locacion),
    id_producto INT NOT NULL,
    FOREIGN KEY (id_producto) REFERENCES Productos (id_producto),
    cantidad INT NOT NULL CHECK(cantidad >= 0)
);

-- Tabla Tipos_tarea
CREATE TABLE IF NOT EXISTS Tipos_tarea (
    id_tipo_tarea INT PRIMARY KEY,
    tipo VARCHAR(100) NOT NULL UNIQUE
);

-- Tabla Estado_tarea
CREATE TABLE IF NOT EXISTS Estados_tarea (
    id_estado INT PRIMARY KEY,
    estado VARCHAR(100) NOT NULL UNIQUE
);

-- Tabla Tareas
CREATE TABLE IF NOT EXISTS Tareas (
    id_tarea INT PRIMARY KEY,
    descripcion_tarea TEXT NOT NULL,
    id_tipo_tarea INT NOT NULL,
    FOREIGN KEY (id_tipo_tarea) REFERENCES Tipos_tarea (id_tipo_tarea),
    fecha DATE NOT NULL,
    id_estado INT NOT NULL,
    FOREIGN KEY (id_estado) REFERENCES Estados_tarea (id_estado)
);

-- Tabla Tareas_de_producción
CREATE TABLE IF NOT EXISTS Tareas_de_producción (
    id INT PRIMARY KEY,
    id_producción INT NOT NULL,
    FOREIGN KEY (id_producción) REFERENCES Producciones (id_produccion),
    id_tarea INT NOT NULL,
    FOREIGN KEY (id_tarea) REFERENCES Tareas (id_tarea)
);

-- Tabla Categorias
CREATE TABLE IF NOT EXISTS Categorias (
    id_categoria INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE
);

-- Tabla Activos-insumos
CREATE TABLE IF NOT EXISTS Activos_insumos (
    id_activo INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    id_categoria INT NOT NULL,
    FOREIGN KEY (id_categoria) REFERENCES Categorias (id_categoria)
);

-- Tabla Activos_en_tarea
CREATE TABLE IF NOT EXISTS Activos_en_tarea (
    id INT PRIMARY KEY,
    id_tarea INT NOT NULL,
    FOREIGN KEY (id_tarea) REFERENCES Tareas (id_tarea),
    id_activo INT NOT NULL,
    FOREIGN KEY (id_activo) REFERENCES Activos_insumos (id_activo),
    cantidad INT NOT NULL CHECK(cantidad >= 0)
);

-- Tabla Tipos_vehículo
CREATE TABLE IF NOT EXISTS Tipos_vehiculo (
    id_tipo_vehiculo INT PRIMARY KEY,
    tipo VARCHAR(100) NOT NULL UNIQUE
);

-- Tabla Vehículos
CREATE TABLE IF NOT EXISTS Vehiculos (
    id_vehiculo INT PRIMARY KEY,
    id_activo INT NOT NULL UNIQUE,
    FOREIGN KEY (id_activo) REFERENCES Activos_insumos (id_activo),
    marca VARCHAR(100),
    modelo VARCHAR(100),
    id_tipo_vehiculo INT NOT NULL,
    FOREIGN KEY (id_tipo_vehiculo) REFERENCES Tipos_vehiculo (id_tipo_vehiculo)
);

-- Tabla Tipos:insumo
CREATE TABLE IF NOT EXISTS Tipos_insumo (
    id_tipo_insumo INT PRIMARY KEY,
    tipo VARCHAR(100) NOT NULL UNIQUE
);

-- Tabla Unidades_medida
CREATE TABLE IF NOT EXISTS Unidades_medida (
    id_unidad_medida INT PRIMARY KEY,
    unidad VARCHAR(100) NOT NULL UNIQUE
);

-- Tabla Insumos
CREATE TABLE IF NOT EXISTS Insumos (
    id_insumo INT PRIMARY KEY,
    id_activo INT NOT NULL UNIQUE,
    FOREIGN KEY (id_activo) REFERENCES Activos_insumos (id_activo),
    id_unidad_medida INT NOT NULL,
    FOREIGN KEY (id_unidad_medida) REFERENCES Unidades_medida (id_unidad_medida),
    id_tipo_insumo INT NOT NULL,
    FOREIGN KEY (id_tipo_insumo) REFERENCES Tipos_insumo (id_tipo_insumo),
    fecha_vencimiento DATE,
    cantidad INT CHECK(cantidad >= 0)
);

-- Tabla Estado
CREATE TABLE IF NOT EXISTS Estados (
    id_estado INT PRIMARY KEY,
    estado VARCHAR(100) NOT NULL UNIQUE
);

-- Tabla Equipos_de_trabajo
CREATE TABLE IF NOT EXISTS Equipos_de_trabajo (
    id_equipo INT PRIMARY KEY,
    id_activo INT NOT NULL UNIQUE,
    FOREIGN KEY (id_activo) REFERENCES Activos_insumos (id_activo),
    descripcion TEXT,
    id_estado INT NOT NULL,
    FOREIGN KEY (id_estado) REFERENCES Estados (id_estado),
    cantidad INT CHECK(cantidad >= 0)
);

-- Tabla Maquinas
CREATE TABLE IF NOT EXISTS Maquinas (
    id_maquina INT PRIMARY KEY,
    id_activo INT NOT NULL UNIQUE,
    FOREIGN KEY (id_activo) REFERENCES Activos_insumos (id_activo),
    descripcion TEXT,
    marca VARCHAR(100),
    modelo VARCHAR(100),
    id_estado INT NOT NULL,
    FOREIGN KEY (id_estado) REFERENCES Estados (id_estado)
);

-- Tabla Departamentos
CREATE TABLE IF NOT EXISTS Departamentos (
    id_departamento INT PRIMARY KEY,
    departamento VARCHAR(100) NOT NULL UNIQUE
);

-- Tabla Municipios
CREATE TABLE IF NOT EXISTS Municipios (
    id_municipio INT PRIMARY KEY,
    municipio VARCHAR(100) NOT NULL UNIQUE,
    id_departamento INT NOT NULL,
    FOREIGN KEY (id_departamento) REFERENCES Departamentos (id_departamento)
);

-- Tabla Ubicaciones
CREATE TABLE IF NOT EXISTS Ubicaciones (
    id_ubicacion INT PRIMARY KEY,
    direccion VARCHAR(255) NOT NULL,
    id_municipio INT NOT NULL,
    FOREIGN KEY (id_municipio) REFERENCES Municipios (id_municipio)
);

-- Tabla Tipos_cliente
CREATE TABLE IF NOT EXISTS Tipos_cliente (
    id_tipo_cliente INT PRIMARY KEY,
    tipo VARCHAR(100) NOT NULL UNIQUE
);

-- Tabla Clientes
CREATE TABLE IF NOT EXISTS Clientes (
    id_cliente INT PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    telefono VARCHAR(15) CHECK(LENGTH(telefono) >= 7),
    correo VARCHAR(255) CHECK(correo LIKE '%_@__%.__%'),
    id_ubicacion INT NOT NULL,
    FOREIGN KEY (id_ubicacion) REFERENCES Ubicaciones (id_ubicacion),
    id_tipo_cliente INT NOT NULL,
    FOREIGN KEY (id_tipo_cliente) REFERENCES Tipos_cliente (id_tipo_cliente)
);

-- Tabla Proveedores
CREATE TABLE IF NOT EXISTS Proveedores (
    id_proveedor INT PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    telefono VARCHAR(15),
    correo VARCHAR(255),
    id_ubicacion INT NOT NULL,
    FOREIGN KEY (id_ubicacion) REFERENCES Ubicaciones (id_ubicacion)
);

-- Tabla Compras
CREATE TABLE IF NOT EXISTS Compras (
    id_compra INT PRIMARY KEY,
    fecha DATE NOT NULL,
    total DECIMAL(10, 2) NOT NULL CHECK(total >= 0),
    id_proveedor INT NOT NULL,
    FOREIGN KEY (id_proveedor) REFERENCES Proveedores (id_proveedor)
);

-- Tabla Detalles_compra
CREATE TABLE IF NOT EXISTS Detalles_compra (
    id INT PRIMARY KEY,
    id_compra INT NOT NULL,
    FOREIGN KEY (id_compra) REFERENCES Compras (id_compra),
    id_activo INT NOT NULL,
    FOREIGN KEY (id_activo) REFERENCES Activos_insumos (id_activo),
    precio_unitario DECIMAL(10,2) NOT NULL CHECK(precio_unitario >= 0),
    cantidad INT NOT NULL CHECK(cantidad >= 0)
);

-- Tabla Cargos
CREATE TABLE IF NOT EXISTS Cargos (
    id_cargo INT PRIMARY KEY,
    cargo VARCHAR(100) NOT NULL UNIQUE
);

-- Tabla Empleados
CREATE TABLE IF NOT EXISTS Empleados (
    id_empleado INT PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    edad INT CHECK(edad >= 18),
    id_cargo INT NOT NULL,
    FOREIGN KEY (id_cargo) REFERENCES Cargos (id_cargo),
    salario DECIMAL(10, 2) NOT NULL CHECK(salario >= 0),
    telefono VARCHAR(255),
    fecha_contratacion DATE NOT NULL
);

-- Tabla Dias_semana
CREATE TABLE IF NOT EXISTS Dias_semana (
    id_dia INT PRIMARY KEY,
    dia VARCHAR(100) NOT NULL UNIQUE
);

-- Tabla Horarios
CREATE TABLE IF NOT EXISTS Horarios (
    id_horario INT PRIMARY KEY,
    id_empleado INT NOT NULL,
    FOREIGN KEY (id_empleado) REFERENCES Empleados (id_empleado),
    id_dia INT NOT NULL,
    FOREIGN KEY (id_dia) REFERENCES Dias_semana (id_dia),
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL
);

-- Tabla Empleados_en_tarea
CREATE TABLE IF NOT EXISTS Empleados_en_tarea (
    id INT PRIMARY KEY,
    id_tarea INT NOT NULL,
    FOREIGN KEY (id_tarea) REFERENCES Tareas (id_tarea),
    id_empleado INT NOT NULL,
    FOREIGN KEY (id_empleado) REFERENCES Empleados (id_empleado)
);

-- Tabla Ventas
CREATE TABLE IF NOT EXISTS Ventas (
    id_venta INT PRIMARY KEY,
    fecha DATE NOT NULL,
    id_empleado INT NOT NULL,
    FOREIGN KEY (id_empleado) REFERENCES Empleados (id_empleado),
    id_cliente INT NOT NULL,
    FOREIGN KEY (id_cliente) REFERENCES Clientes (id_cliente),
    total DECIMAL(10,2) NOT NULL
);

-- Detalles_venta
CREATE TABLE IF NOT EXISTS Detalles_venta (
    id INT PRIMARY KEY,
    id_venta INT NOT NULL,
    FOREIGN KEY (id_venta) REFERENCES Ventas (id_venta),
    id_producto INT NOT NULL,
    FOREIGN KEY (id_producto) REFERENCES Productos (id_producto),
    cantidad INT NOT NULL CHECK(cantidad >= 0)
);