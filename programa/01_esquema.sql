-- SQL Server 2019+. Recuperado y corregido desde el informe 2024-I.
SET XACT_ABORT ON;
CREATE TABLE Usuario(
ID_Usuario INT IDENTITY(1,1) PRIMARY KEY, -- Creacion de la llave primaria
DNI VARCHAR(8),
Nombre_Usuario VARCHAR(50),
Apellido_Usuario VARCHAR(50),
Correo VARCHAR(50),
Telefono VARCHAR(15)
);

-- Creacion de la tabla Tarjeta
CREATE TABLE Tarjeta(
ID_Tarjeta INT IDENTITY(1,1) PRIMARY KEY, -- Creacion de la llave primaria
ID_Usuario INT,
Tipo_Tarjeta VARCHAR(20), -- Tipos: Normal, Escolar, Universitaria, Discapacitado
Saldo DECIMAL(10,2) NOT NULL,
FecEmision DATETIME,
FecCaducidad DATETIME,
EstadoTarjeta BIT NOT NULL DEFAULT 1, -- Tarjeta Activa o Inactiva
ReporteRobo BIT NOT NULL DEFAULT 0,
FOREIGN KEY (ID_Usuario) references Usuario(ID_Usuario) ON DELETE CASCADE
);

-- Creacion de la tabla Tarjeta_Escolar
CREATE TABLE Tarjeta_Escolar(
ID_Tarjeta Int PRIMARY KEY,
NombreEscuela VARCHAR(20),
NivelEscolar VARCHAR(20),
FOREIGN KEY (ID_Tarjeta) REFERENCES Tarjeta(ID_Tarjeta) ON DELETE CASCADE
);

-- Creacion de la tabla Tarjeta_Discapacitados
CREATE TABLE Tarjeta_Discapacitados(
ID_Tarjeta Int PRIMARY KEY,
NroCarneDiscapacidad VARCHAR(20),
TipoDiscapacidad VARCHAR(20),
FOREIGN KEY (ID_Tarjeta) REFERENCES Tarjeta(ID_Tarjeta) ON DELETE CASCADE
);

-- Creacion de la tabla Tarjeta_Universitario
CREATE TABLE Tarjeta_Universitario(
ID_Tarjeta INT PRIMARY KEY,
NroCarneUniversitario VARCHAR(20),
FechaCaducidadCarne DATE,
NombreUniversidad VARCHAR(50),
FOREIGN KEY (ID_Tarjeta) REFERENCES Tarjeta(ID_Tarjeta) ON DELETE CASCADE
);

-- Creacion de la tabla Estacion
CREATE TABLE Estacion(
ID_Estacion INT IDENTITY(1,1) PRIMARY KEY,
Nombre_Estacion VARCHAR(20),
Direccion VARCHAR(50)
);

-- Creacion de la tabla Empleado
CREATE TABLE Empleado(
ID_Empleado INT IDENTITY(1,1) PRIMARY KEY,
ID_Estacion INT,
Nombre VARCHAR(50),
Apellido VARCHAR(50),
DNI VARCHAR(8),
FOREIGN KEY (ID_Estacion) REFERENCES Estacion(ID_Estacion) ON DELETE CASCADE
);

-- Creaacion de la tabla Punto_Recarga
CREATE TABLE Punto_Recarga(
ID_Punto_Recarga INT IDENTITY(1,1) PRIMARY KEY,
ID_Estacion INT,
Tipo_Estacion_Recarga VARCHAR(25), -- 'MaquinaRecargaConsulta', 'Taquilla', 'Digital'
EstadoPuntoRecarga VARCHAR(20), -- 'Operativo', 'Fuera de servicio', 'Mantenimiento'
FOREIGN KEY (ID_Estacion) REFERENCES Estacion(ID_Estacion) ON DELETE CASCADE
);

-- Creacion de la tabla MaquinaRecargaConsulta
CREATE TABLE MaquinaRecargaConsulta(
ID_Maquina INT IDENTITY(1,1) PRIMARY KEY,
ID_Punto_Recarga INT,
VersionSoftware VARCHAR(15),
FecUltimoMantenimiento DATETIME,
FOREIGN KEY (ID_Punto_Recarga) REFERENCES Punto_Recarga(ID_Punto_Recarga) ON DELETE CASCADE
);

-- Creacion de la tabla Digital
CREATE TABLE Digital(
ID_Dispositivo INT IDENTITY(1,1) PRIMARY KEY,
ID_Punto_Recarga INT,
SistemaOperativo VARCHAR(50),
VersionSO VARCHAR(20),
FOREIGN KEY (ID_Punto_Recarga) REFERENCES Punto_Recarga(ID_Punto_Recarga) ON DELETE CASCADE
);

-- Creacion de la tabla Taquilla
CREATE TABLE Taquilla (
ID_Taquilla INT IDENTITY(1,1) PRIMARY KEY,
ID_Punto_Recarga INT,
FOREIGN KEY (ID_Punto_Recarga) REFERENCES Punto_Recarga(ID_Punto_Recarga) ON DELETE CASCADE
);

-- Creacion de la tabla EmpleadoXTaquilla
CREATE TABLE EmpleadoXTaquilla(
ID_Empleado INT,
ID_Taquilla INT,
Inicio_Turno DATETIME,
Fin_Turno DATETIME,
PRIMARY KEY (ID_Empleado, ID_Taquilla),
FOREIGN KEY (ID_Empleado) REFERENCES Empleado(ID_Empleado) ON DELETE CASCADE,
FOREIGN KEY (ID_Taquilla) REFERENCES Taquilla(ID_Taquilla) ON DELETE NO ACTION
);

-- Creacion de la tabla Metodo_Pago
CREATE TABLE Metodo_Pago(
ID_Metodo_Pago INT IDENTITY(1,1) PRIMARY KEY,
TipoPago VARCHAR(20),
Proveedor_Servicios_Pago VARCHAR(20) null,
NroCuentaBancaria VARCHAR(20) null,
NroTarjeta VARCHAR(20) null,
NombreTitular VARCHAR(50) null,
BancoEmisor VARCHAR(50) null
);

-- Creacion de la tabla Transaccion
CREATE TABLE Transaccion(
ID_Transaccion INT IDENTITY(1,1) PRIMARY KEY,
ID_Tarjeta INT,
ID_Metodo_Pago INT,
FecTransaccion DATE,
Monto Decimal(10,2) NOT NULL,
ID_Punto_Recarga INT,
FOREIGN KEY (ID_Tarjeta) REFERENCES Tarjeta (ID_Tarjeta) ON DELETE CASCADE,
FOREIGN KEY (ID_Metodo_Pago) REFERENCES Metodo_Pago(ID_Metodo_Pago) ON DELETE CASCADE,
FOREIGN KEY (ID_Punto_Recarga) REFERENCES Punto_Recarga(ID_Punto_Recarga) ON DELETE CASCADE
);

--Creación de la tabla Bus
CREATE TABLE BusAlimentador (
ID_BusAlimentador INT IDENTITY(1,1) PRIMARY KEY,
Linea VARCHAR(10)
);

-- Creación de la tabla Pago_Pasaje
CREATE TABLE Pago_Pasaje(
ID_Pago_Pasaje INT IDENTITY(1,1) PRIMARY KEY,
ID_Tarjeta INT,
Tipo_Pasaje VARCHAR(20),
Monto_Pasaje Decimal(10,2) NOT NULL,
FecPagoPasaje DATETIME,
ID_Estacion INT,
ID_BusAlimentador INT,
FOREIGN KEY (ID_Tarjeta) REFERENCES Tarjeta(ID_tarjeta) ON DELETE CASCADE,
FOREIGN KEY (ID_Estacion) REFERENCES Estacion(ID_Estacion) ON DELETE CASCADE,
FOREIGN KEY (ID_BusAlimentador) REFERENCES BusAlimentador(ID_BusAlimentador) ON DELETE CASCADE
);
GO


ALTER TABLE Usuario ADD CONSTRAINT UQ_Usuario_DNI UNIQUE(DNI);
ALTER TABLE Usuario ADD CONSTRAINT CK_DNI CHECK(LEN(DNI)=8 AND DNI NOT LIKE '%[^0-9]%');
ALTER TABLE Tarjeta ADD CONSTRAINT CK_Saldo CHECK(Saldo>=0);
ALTER TABLE Tarjeta ADD CONSTRAINT CK_Fechas CHECK(FecCaducidad>FecEmision);
ALTER TABLE Tarjeta ADD CONSTRAINT CK_Tipo CHECK(Tipo_Tarjeta IN ('Normal','Escolar','Universitaria','Discapacitados'));
ALTER TABLE Transaccion ADD CONSTRAINT CK_Recarga CHECK(Monto>0);
ALTER TABLE Pago_Pasaje ADD CONSTRAINT CK_Pasaje CHECK(Monto_Pasaje>0);
CREATE TABLE EventoSistema(ID INT IDENTITY PRIMARY KEY, Punto INT NOT NULL, Estado VARCHAR(20) NOT NULL, Fecha DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME());
GO
