# Metropolitano: datos

El modelo relacional detrás de usuarios, tarjetas, recargas y pagos del Metropolitano.

[Ficha y evidencia en el portafolio](https://juan-coronado.github.io/projects/metropolitano-datos/)

| Periodo original | Dificultad académica | Estado de esta versión |
| --- | --- | --- |
| 2024-I | Intermedia | Comprobado en SQL Server |

## Funcionalidades

- 16 tablas del modelo, cinco vistas y diez procedimientos.
- Función de saldo y cuatro triggers.
- Recargas, pagos y bloqueo con integridad de saldo.

## Ejecución

SQL Server 2019 o superior y sqlcmd. Usar una base de pruebas nueva y vacía; sustituir SERVIDOR y BASE_DE_PRUEBAS por los valores del entorno. Ejecutar los tres scripts en orden.

```powershell
sqlcmd -S "SERVIDOR" -E -d "BASE_DE_PRUEBAS" -i programa/01_esquema.sql -b -f 65001
sqlcmd -S "SERVIDOR" -E -d "BASE_DE_PRUEBAS" -i programa/02_vistas.sql -b -f 65001
sqlcmd -S "SERVIDOR" -E -d "BASE_DE_PRUEBAS" -i programa/03_operaciones.sql -b -f 65001
```

## Comprobación disponible

Ejecutado en SQL Server LocalDB 2019 aislado. Saldo comprobado: 10 + 20 + 12 − 2,50 = 39,50; rechazo de sobreconsumo y tarjeta robada.

Ejecutar desde la raíz del repositorio. La prueba inserta datos ficticios y requiere una base de pruebas recién preparada; no usar una base de producción.

```powershell
sqlcmd -S "SERVIDOR" -E -d "BASE_DE_PRUEBAS" -i tests/integracion.sql -b -f 65001
```

[Registro de ejecución](evidencia/ejecucion.txt)

Las comprobaciones anteriores corresponden a la recuperación de octubre de 2026; esta publicación conserva sus registros.

## Aprendizaje

- Convertir un caso de negocio en entidades y relaciones.
- Utilizar SQL, restricciones y operaciones atómicas.

## Revisión para el portafolio

- Recuperado el SQL del informe y corregidos campos, claves y joins.
- Eliminada la doble aplicación de recargas y pagos; triggers para múltiples filas.

## Alcance

Datos de prueba. Se conservaron el modelo conceptual y el alcance del trabajo de 2024-I. No se hizo una prueba de carga concurrente.

## Contexto académico y procedencia

Este repositorio conserva el alcance académico y los créditos disponibles en el material original. La recuperación, las correcciones y las reconstrucciones de octubre de 2026 se realizaron con asistencia de Codex/IA y se distinguen del trabajo original. La contribución individual de cada integrante no está desglosada aquí.
