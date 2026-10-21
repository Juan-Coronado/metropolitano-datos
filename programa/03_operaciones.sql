CREATE PROCEDURE sp_CrearUsuario @DNI VARCHAR(8),@Nombre_Usuario VARCHAR(50),@Apellido_Usuario VARCHAR(50),@Correo VARCHAR(50),@Telefono VARCHAR(15) AS
INSERT Usuario(DNI,Nombre_Usuario,Apellido_Usuario,Correo,Telefono) VALUES(@DNI,@Nombre_Usuario,@Apellido_Usuario,@Correo,@Telefono);
GO
CREATE PROCEDURE sp_CrearTarjeta @ID_Usuario INT,@Tipo_Tarjeta VARCHAR(20),@Saldo DECIMAL(10,2),@FecEmision DATETIME,@FecCaducidad DATETIME,@EstadoTarjeta BIT AS
INSERT Tarjeta(ID_Usuario,Tipo_Tarjeta,Saldo,FecEmision,FecCaducidad,EstadoTarjeta) VALUES(@ID_Usuario,@Tipo_Tarjeta,@Saldo,@FecEmision,@FecCaducidad,@EstadoTarjeta);
GO
CREATE PROCEDURE sp_ConsultarSaldo @ID_Tarjeta INT AS SELECT Saldo FROM Tarjeta WHERE ID_Tarjeta=@ID_Tarjeta;
GO
-- El trigger aplica el saldo una sola vez; no se duplica aqui la recarga.
CREATE PROCEDURE sp_RecargarSaldo @ID_Tarjeta INT,@Monto DECIMAL(10,2),@ID_Metodo_Pago INT,@ID_Punto_Recarga INT AS
INSERT Transaccion(ID_Tarjeta,Monto,ID_Metodo_Pago,ID_Punto_Recarga,FecTransaccion) VALUES(@ID_Tarjeta,@Monto,@ID_Metodo_Pago,@ID_Punto_Recarga,GETDATE());
GO
CREATE PROCEDURE sp_PagarPasaje @ID_Tarjeta INT,@Tipo_Pasaje VARCHAR(20),@Monto_Pasaje DECIMAL(10,2),@ID_Estacion INT,@ID_Bus INT AS
INSERT Pago_Pasaje(ID_Tarjeta,Tipo_Pasaje,Monto_Pasaje,ID_Estacion,ID_BusAlimentador,FecPagoPasaje) VALUES(@ID_Tarjeta,@Tipo_Pasaje,@Monto_Pasaje,@ID_Estacion,@ID_Bus,GETDATE());
GO
CREATE PROCEDURE sp_ReportarRobo @ID_Tarjeta INT AS UPDATE Tarjeta SET ReporteRobo=1 WHERE ID_Tarjeta=@ID_Tarjeta;
GO
CREATE PROCEDURE usp_Actualizar_Usuario @ID_Usuario INT,@DNI VARCHAR(8),@Nombre VARCHAR(50),@Apellido VARCHAR(50),@Correo VARCHAR(50),@Telefono VARCHAR(15) AS
UPDATE Usuario SET DNI=@DNI,Nombre_Usuario=@Nombre,Apellido_Usuario=@Apellido,Correo=@Correo,Telefono=@Telefono WHERE ID_Usuario=@ID_Usuario;
GO
CREATE PROCEDURE usp_Buscar_discapacitados @Nombre VARCHAR(50)='%' AS
SELECT U.ID_Usuario,U.Nombre_Usuario,T.ID_Tarjeta,TD.TipoDiscapacidad FROM Usuario U JOIN Tarjeta T ON U.ID_Usuario=T.ID_Usuario JOIN Tarjeta_Discapacitados TD ON T.ID_Tarjeta=TD.ID_Tarjeta WHERE U.Nombre_Usuario LIKE '%'+@Nombre+'%';
GO
CREATE PROCEDURE usp_ObtenerTransaccionesPorEstacionYRangoFecha @ID_Estacion INT,@FechaInicio DATE,@FechaFin DATE AS
SELECT TR.ID_Transaccion,TR.Monto,U.Nombre_Usuario,PR.ID_Estacion FROM Transaccion TR JOIN Tarjeta T ON TR.ID_Tarjeta=T.ID_Tarjeta JOIN Usuario U ON T.ID_Usuario=U.ID_Usuario JOIN Punto_Recarga PR ON TR.ID_Punto_Recarga=PR.ID_Punto_Recarga WHERE PR.ID_Estacion=@ID_Estacion AND TR.FecTransaccion BETWEEN @FechaInicio AND @FechaFin;
GO
CREATE PROCEDURE usp_ObtenerTransaccionesPorPuntoRecargaYTipoPago @ID_Punto_Recarga INT,@TipoPago VARCHAR(20) AS
SELECT TR.ID_Transaccion,TR.Monto,U.Nombre_Usuario,MP.TipoPago FROM Transaccion TR JOIN Tarjeta T ON TR.ID_Tarjeta=T.ID_Tarjeta JOIN Usuario U ON T.ID_Usuario=U.ID_Usuario JOIN Metodo_Pago MP ON TR.ID_Metodo_Pago=MP.ID_Metodo_Pago WHERE TR.ID_Punto_Recarga=@ID_Punto_Recarga AND MP.TipoPago=@TipoPago;
GO
CREATE FUNCTION dbo.fn_Saldo(@ID_Tarjeta INT) RETURNS DECIMAL(10,2) AS BEGIN
 RETURN (SELECT Saldo FROM dbo.Tarjeta WHERE ID_Tarjeta=@ID_Tarjeta);
END;
GO
CREATE TRIGGER trig_AfterInsert_Transaccion ON Transaccion AFTER INSERT AS BEGIN
 SET NOCOUNT ON;
 IF EXISTS(SELECT 1 FROM inserted I JOIN Punto_Recarga P ON P.ID_Punto_Recarga=I.ID_Punto_Recarga WHERE P.EstadoPuntoRecarga<>'Operativo') THROW 51000,'Punto de recarga no operativo',1;
 ;WITH Montos AS(SELECT ID_Tarjeta,SUM(Monto) Monto FROM inserted GROUP BY ID_Tarjeta)
 UPDATE T WITH(UPDLOCK) SET Saldo=T.Saldo+M.Monto FROM Tarjeta T JOIN Montos M ON T.ID_Tarjeta=M.ID_Tarjeta WHERE T.ReporteRobo=0 AND T.EstadoTarjeta=1 AND T.FecCaducidad>GETDATE();
 IF @@ROWCOUNT<>(SELECT COUNT(DISTINCT ID_Tarjeta) FROM inserted) THROW 51000,'Tarjeta bloqueada o vencida',1;
END;
GO
CREATE TRIGGER trig_AfterInsert_PagoPasaje ON Pago_Pasaje AFTER INSERT AS BEGIN
 SET NOCOUNT ON;
 ;WITH Montos AS(SELECT ID_Tarjeta,SUM(Monto_Pasaje) Monto FROM inserted GROUP BY ID_Tarjeta)
 UPDATE T WITH(UPDLOCK) SET Saldo=T.Saldo-M.Monto FROM Tarjeta T JOIN Montos M ON T.ID_Tarjeta=M.ID_Tarjeta WHERE T.Saldo>=M.Monto AND T.ReporteRobo=0 AND T.EstadoTarjeta=1 AND T.FecCaducidad>GETDATE();
 IF @@ROWCOUNT<>(SELECT COUNT(DISTINCT ID_Tarjeta) FROM inserted) THROW 51000,'Saldo insuficiente, tarjeta bloqueada o vencida',1;
END;
GO
CREATE TRIGGER trig_AfterUpdate_Tarjeta ON Tarjeta AFTER UPDATE AS BEGIN
 SET NOCOUNT ON;
 UPDATE T SET EstadoTarjeta=0 FROM Tarjeta T JOIN inserted I ON T.ID_Tarjeta=I.ID_Tarjeta WHERE I.ReporteRobo=1 AND T.EstadoTarjeta<>0;
END;
GO
CREATE TRIGGER trig_AfterUpdate_PuntoRecarga ON Punto_Recarga AFTER UPDATE AS BEGIN
 SET NOCOUNT ON;
 INSERT EventoSistema(Punto,Estado) SELECT ID_Punto_Recarga,EstadoPuntoRecarga FROM inserted WHERE EstadoPuntoRecarga='Fuera de servicio';
END;
GO
