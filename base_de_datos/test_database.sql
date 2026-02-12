-- Script para SQL Server Express 22

-- Crear la base de datos si no existe (opcional, si no se especifica una base de datos existente)
-- USE master;
-- GO
-- IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'MiBaseDeDatosVentas')
-- CREATE DATABASE MiBaseDeDatosVentas;
-- GO
-- USE MiBaseDeDatosVentas;
-- GO

-- Tabla Productos
CREATE TABLE Productos (
    ProductoID INT IDENTITY(1,1) PRIMARY KEY,
    Nombre NVARCHAR(255) NOT NULL,
    Precio DECIMAL(10, 2) NOT NULL CHECK (Precio >= 0),
    SKU NVARCHAR(50) UNIQUE NOT NULL,
    Stock INT NOT NULL CHECK (Stock >= 0)
);

-- Tabla Ventas
CREATE TABLE Ventas (
    VentaID INT IDENTITY(1,1) PRIMARY KEY, -- Folio de la venta
    Fecha DATETIME NOT NULL DEFAULT GETDATE(),
    TotalProductosVendidos INT NOT NULL CHECK (TotalProductosVendidos >= 0),
    TotalVenta DECIMAL(10, 2) NOT NULL CHECK (TotalVenta >= 0)
);

-- Tabla Detalles de Venta
CREATE TABLE DetallesDeVenta (
    DetalleVentaID INT IDENTITY(1,1) PRIMARY KEY,
    VentaID INT NOT NULL,
    ProductoID INT NOT NULL,
    PrecioUnitario DECIMAL(10, 2) NOT NULL CHECK (PrecioUnitario >= 0),
    Cantidad INT NOT NULL CHECK (Cantidad > 0),
    TotalDetalle AS (Cantidad * PrecioUnitario), -- Columna calculada
    CONSTRAINT FK_DetalleVenta_Venta FOREIGN KEY (VentaID) REFERENCES Ventas(VentaID) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT FK_DetalleVenta_Producto FOREIGN KEY (ProductoID) REFERENCES Productos(ProductoID) ON DELETE NO ACTION ON UPDATE NO ACTION
);

-- Notas sobre TotalProductosVendidos y TotalVenta en la tabla Ventas:
-- Estas columnas (TotalProductosVendidos, TotalVenta) son sumas de datos de la tabla DetallesDeVenta.
-- No pueden ser columnas calculadas directamente de otras tablas en SQL Server de esta manera.
-- Se recomienda mantener estas columnas actualizadas mediante:
-- 1. TRIGGERS: Crear AFTER INSERT, UPDATE, DELETE triggers en la tabla DetallesDeVenta
--    que recalcule y actualice los campos correspondientes en la tabla Ventas.
-- 2. Lógica en la aplicación: Realizar el cálculo y la actualización en el código de la aplicación
--    cuando se realizan operaciones en DetallesDeVenta.

-- Ejemplo de un trigger para actualizar TotalProductosVendidos y TotalVenta en la tabla Ventas
-- Este es un ejemplo básico para INSERT, se necesitarían triggers similares para UPDATE y DELETE.
/*
CREATE TRIGGER TR_UpdateVentaTotals_Insert
ON DetallesDeVenta
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE V
    SET
        TotalProductosVendidos = (SELECT SUM(Cantidad) FROM DetallesDeVenta WHERE VentaID = V.VentaID),
        TotalVenta = (SELECT SUM(TotalDetalle) FROM DetallesDeVenta WHERE VentaID = V.VentaID)
    FROM Ventas AS V
    INNER JOIN INSERTED AS I ON V.VentaID = I.VentaID;
END;
GO
*/