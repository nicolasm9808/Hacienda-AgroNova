# Gestión de una Finca de Producción Agrícola

## Descripción del Proyecto

El proyecto **Gestión de una Finca de Producción Agrícola** está diseñado para gestionar y optimizar las operaciones relacionadas con la producción agrícola de una finca. La base de datos creada permite gestionar diversos aspectos de la finca, como la producción de cultivos y animales, el inventario de productos e insumos, la gestión de empleados, ventas, compras y la relación con clientes y proveedores.

### Funcionalidades principales:
- **Gestión de Cultivos y Animales**: Registro de las especies, estado y rendimiento de los cultivos y animales.
- **Control de Inventario**: Seguimiento del inventario de productos agrícolas, insumos y activos de la finca.
- **Manejo de Ventas y Compras**: Gestión de las ventas realizadas a clientes y compras a proveedores.
- **Asignación de Tareas**: Organización y seguimiento de tareas asignadas a empleados y equipos de trabajo.
- **Automatización con Procedimientos y Triggers**: Automatización de actualizaciones en inventarios, reportes y seguimiento de estado.
- **Reportes Financieros**: Generación de reportes de ventas, costos operativos y gastos, entre otros.

## Requisitos del Sistema

Para ejecutar este proyecto es necesario contar con el siguiente software instalado:

- **MySQL Server** versión 8.0 o superior.
- **Cliente MySQL Workbench** o cualquier cliente de base de datos SQL compatible.
- **Git** (opcional, si deseas clonar el repositorio directamente).
- **Sistema operativo**: Compatible con Windows, macOS y Linux.

## Instalación y Configuración

Sigue los pasos a continuación para instalar y configurar la base de datos del proyecto:

### 1. Clonar el proyecto (opcional):
Si tienes acceso a un repositorio, clona el proyecto:
```bash
git https://github.com/nicolasm9808/Hacienda-AgroNova.git
cd Hacienda-AgroNova
```

### 2. Crear la base de datos
Inicia sesión en tu cliente MySQL y ejecuta los siguientes comandos para crear la base de datos:
```sql
CREATE DATABASE Hacienda_AgroNova;
USE Hacienda_AgroNova;
```

### 3. Ejecutar el archivo `ddl.sql`
El archivo `ddl.sql` contiene todas las definiciones de las tablas. Cárgalo en MySQL para generar la estructura de la base de datos:
```bash
mysql -u usuario -p Hacienda_AgroNova < path/to/ddl.sql
```

### 4. Cargar datos iniciales con `dml.sql`
El archivo `dml.sql` contiene datos iniciales que poblarán las tablas. Ejecuta el siguiente comando:
```bash
mysql -u usuario -p Hacienda_AgroNova < path/to/dml.sql
```

### 5. Ejecución de procedimientos almacenados, funciones, triggers y eventos
Una vez creada la base de datos, puedes cargar los scripts adicionales para procedimientos, funciones y eventos:
```bash
mysql -u usuario -p Hacienda_AgroNova < path/to/dql_procedimientos.sql
mysql -u usuario -p Hacienda_AgroNova < path/to/dql_funciones.sql
mysql -u usuario -p Hacienda_AgroNova < path/to/dql_triggers.sql
mysql -u usuario -p Hacienda_AgroNova < path/to/dql_eventos.sql
```

## Estructura de la Base de Datos

### Tablas principales:
- **Empleados**: Gestiona la información del personal de la finca, incluyendo salarios y cargos.
- **Ventas**: Registro de las ventas realizadas a clientes.
- **Productos**: Almacena los productos agrícolas disponibles, con su inventario.
- **Tareas**: Lista las tareas asignadas a los empleados, equipos de trabajo y maquinaria.
- **Producciones**: Almacena los costos y detalles de cada proceso de producción (cultivos y animales).

### Relaciones entre tablas:
- **Ventas** y **Detalles_venta**: La tabla `Ventas` contiene información de las ventas, mientras que `Detalles_venta` desglosa los productos vendidos.
- **Productos** y **Insumos**: La tabla `Productos` se relaciona con los insumos utilizados en la producción.
- **Cultivos** y **Producciones**: Los cultivos están vinculados a los registros de producción.

## Ejemplos de Consultas

A continuación se presentan algunos ejemplos de consultas que se pueden ejecutar en la base de datos:

### Consulta básica: Listar el inventario total de productos por locación.
```sql
SELECT l.nombre AS locacion, p.nombre AS producto, pl.cantidad AS cantidad_disponible
FROM Productos_en_locacion pl
JOIN Productos p ON pl.id_producto = p.id_producto
JOIN Locaciones_almacenamiento l ON pl.id_locacion = l.id_locacion;
```

### Consulta avanzada: Desglose mensual de costos por categoría de activo.
```sql
SELECT DATE_FORMAT(c.fecha, '%Y-%m') AS mes, ca.nombre AS categoria, SUM(dc.precio_unitario * dc.cantidad) AS costo_total
FROM Detalles_compra dc
JOIN Activos_insumos a ON dc.id_activo = a.id_activo
JOIN Categorias ca ON a.id_categoria = ca.id_categoria
JOIN Compras c ON dc.id_compra = c.id_compra
GROUP BY mes, ca.id_categoria;
```

### Consulta de inventario: Ver productos con stock bajo.
```sql
SELECT nombre, cantidad FROM Productos
WHERE cantidad <= 10;
```

## Procedimientos, Funciones, Triggers y Eventos

### Procedimientos:
- **`ProcesarVenta`**: Registra una venta y actualiza el inventario de productos automáticamente.
- **`RegistrarProveedor`**: Inserta un nuevo proveedor en la base de datos.
  
### Funciones:
- **`RendimientoPromedioHectarea`**: Calcula el rendimiento promedio por hectárea para un cultivo específico.
- **`CostoOperativoTotal`**: Calcula el costo operativo total de la finca en un periodo de tiempo.

### Triggers:
- **`ActualizarInventarioVenta`**: Resta automáticamente el inventario de productos cuando se realiza una venta.
- **`RegistrarCambioSalario`**: Registra cambios en el salario de los empleados en un historial.

### Eventos:
- **`GenerarReporteMensualVentas`**: Genera un reporte mensual de ventas.
- **`ActualizarCapacidadLocacionesSemanal`**: Actualiza la capacidad disponible de las locaciones semanalmente.

## Roles de Usuario y Permisos

Se han definido cinco roles de usuario en el sistema:

1. **Administrador**: Acceso completo a todas las tablas, permisos para crear y modificar usuarios.
2. **Vendedor**: Permisos para registrar ventas y consultar el inventario.
3. **Contador**: Acceso a reportes financieros y registros de ventas, sin acceso a gestión de producción.
4. **Supervisor de Producción**: Permisos para gestionar cultivos, animales y tareas de producción.
5. **Gerente de Inventario**: Permisos para gestionar el inventario de productos y activos.

### Crear usuarios y asignar roles:
```sql
CREATE USER 'vendedor'@'localhost' IDENTIFIED BY 'vendedor_password';
GRANT SELECT, INSERT, UPDATE ON Hacienda_AgroNova.Ventas TO 'vendedor'@'localhost';
```

## Licencia y Contacto

Este proyecto fue desarrollado en equipo. Para más información o para reportar problemas con la implementación, contacta a:

**Nombre**: Luis Nicolás Méndez
**Correo**: nicolas-mendez@hotmail.com 
**LinkedIn**: [linkedin](https://www.linkedin.com/in/luis-nicol%C3%A1s-m%C3%A9ndez-palacios-935047233/)

**Nombre**: Alexis Rafael Hernández
**Correo**: alexismar1228@gmail.com 
**LinkedIn**: [linkedin](https://www.linkedin.com/in/alexis-hern%C3%A1ndez-28d12a/)