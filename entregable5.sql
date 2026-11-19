-- Pre-entrega 5: Consultas con JOINs para el proyecto
-- Proyecto: RetailPro
-- Archivo: m5_consultas_joins.sql
-- Base de Datos: Ventas_Tech_DB

USE Ventas_Tech_DB;
GO


-- Consulta 1: Vista base del proyecto (INNER JOIN)
-- Propósito: Unir la tabla de ventas con clientes, productos y categorías

SELECT 
    v.id_venta,
    v.fecha_venta AS fecha,
    nombre AS cliente,
    ciudad,
    nombre_producto AS descripcion_producto,
    cat.nombre_categoria AS categoria,
    cantidad,
    precio AS precio_unitario,
    (cantidad * precio) AS total_venta
FROM ventas v
INNER JOIN clientes c ON v.id_cliente = c.id_cliente
INNER JOIN productos p ON v.id_producto = p.id_producto
INNER JOIN categorias cat ON p.id_categoria = cat.id_categoria;
-- Hallazgo: La vista integra toda la operación comercial cruzando ventas, clientes, productos y categorías, dejando listo el modelo para analizar facturación por ciudad y categoría en Power BI.



-- Consulta 2: Clientes sin ventas (LEFT JOIN)
-- Propósito: Detectar clientes registrados que aún no realizaron ninguna compra 

SELECT 
    nombre,
    email,
    fecha_registro
FROM clientes c
LEFT JOIN ventas v ON c.id_cliente = v.id_cliente
WHERE v.id_venta IS NULL;
-- Hallazgo: Aparecieron 0 clientes sin ventas; el 100% de los clientes registrados ya realizó al menos una compra, por lo que CRM debe enfocarse en fidelización de clientes.


-- Consulta 3: Productos sin ventas (LEFT JOIN)
-- Propósito: Identificar artículos del catálogo que no tienen movimiento registrado 

SELECT 
    p.nombre_producto,
    cat.nombre_categoria AS categoria,
    precio
FROM productos p
INNER JOIN categorias cat ON p.id_categoria = cat.id_categoria
LEFT JOIN ventas v ON p.id_producto = v.id_producto
WHERE v.id_venta IS NULL;
-- Hallazgo: Aparecieron 0 productos sin ventas; el 100% de los artículos del catálogo registra movimiento comercial activo


-- Consulta 4: Consolidado por origen / volumen (UNION ALL)
-- Propósito: Comparar el total facturado entre dos segmentos de compra distintos 

SELECT 
    canal, 
    SUM(total) AS total_canal
FROM (
    SELECT 
        v.fecha_venta, 
        (v.cantidad * p.precio) AS total, 
        'Pedidos Multi-unidad' AS canal
    FROM ventas v
    INNER JOIN productos p ON v.id_producto = p.id_producto
    WHERE v.cantidad > 1

    UNION ALL

    SELECT 
        v.fecha_venta, 
        (v.cantidad * p.precio) AS total, 
        'Pedidos Unitarios' AS canal
    FROM ventas v
    INNER JOIN productos p ON v.id_producto = p.id_producto
    WHERE v.cantidad = 1
) AS consolidado
GROUP BY canal;
-- Hallazgo: Al consolidar ambos segmentos sin eliminar registros duplicados, se observa claramente qué modalidad de compra aporta mayor volumen de ingresos a la empresa.