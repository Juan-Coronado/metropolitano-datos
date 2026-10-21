CREATE VIEW Vista_Usuarios_Tarjetas AS
SELECT 
    U.ID_Usuario, 
    U.Nombre_Usuario, 
    U.Apellido_Usuario, 
    T.ID_Tarjeta, 
    T.Tipo_Tarjeta, 
    T.Saldo, 
    T.FecEmision, 
    T.FecCaducidad, 
    T.EstadoTarjeta, 
    T.ReporteRobo
FROM Usuario U JOIN Tarjeta T ON U.ID_Usuario = T.ID_Usuario;
GO

CREATE VIEW Vista_Transacciones_Detalle AS
SELECT 
    T.ID_Transaccion, 
    T.FecTransaccion, 
    T.Monto, 
    PR.Tipo_Estacion_Recarga, 
    PR.EstadoPuntoRecarga, 
    MP.TipoPago, 
    MP.Proveedor_Servicios_Pago
FROM Transaccion T JOIN Punto_Recarga PR ON T.ID_Punto_Recarga = PR.ID_Punto_Recarga JOIN Metodo_Pago MP ON T.ID_Metodo_Pago = MP.ID_Metodo_Pago;
GO

CREATE VIEW Vista_Pagos_Pasajes_Detalle AS
SELECT 
    PP.ID_Pago_Pasaje, 
    PP.Tipo_Pasaje, 
    PP.Monto_Pasaje, 
    PP.FecPagoPasaje, 
    T.Tipo_Tarjeta, 
    T.Saldo, 
    E.Nombre_Estacion, 
    E.Direccion
FROM Pago_Pasaje PP JOIN Tarjeta T ON PP.ID_Tarjeta = T.ID_Tarjeta JOIN Estacion E ON PP.ID_Estacion = E.ID_Estacion;
GO

CREATE VIEW Vista_Empleados_Taquillas AS
SELECT 
    E.ID_Empleado, 
    E.Nombre, 
    E.Apellido, 
    ET.ID_Taquilla, 
    ET.Inicio_Turno, 
    ET.Fin_Turno
FROM Empleado E JOIN EmpleadoXTaquilla ET ON E.ID_Empleado = ET.ID_Empleado;
GO

CREATE VIEW Vista_Transacciones_Atendidas_Empleado AS
SELECT 
    E.ID_Empleado,
    E.Nombre AS Nombre_Empleado,
    E.Apellido AS Apellido_Empleado,
    T.ID_Transaccion,
    T.FecTransaccion,
    T.Monto,
    P.Tipo_Estacion_Recarga,
    P.EstadoPuntoRecarga
FROM Transaccion T JOIN Punto_Recarga P ON T.ID_Punto_Recarga = P.ID_Punto_Recarga LEFT JOIN Taquilla TA ON P.ID_Punto_Recarga = TA.ID_Punto_Recarga 
 LEFT JOIN EmpleadoXTaquilla ET ON TA.ID_Taquilla = ET.ID_Taquilla LEFT JOIN Empleado E ON ET.ID_Empleado = E.ID_Empleado;
GO
