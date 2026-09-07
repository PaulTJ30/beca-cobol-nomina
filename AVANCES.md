# Bitacora de avances - Banco Aurora SIDN (Proyecto Final Beca COBOL)

Proyecto individual. Sistema bancario de dispersion de nomina: operaciones online + batch
de alto volumen orquestado con WFL, sobre arquitectura MCP (implementado en GnuCOBOL,
documentando la capa MCP/WFL/DMSII). Meta: cerrar el miercoles 9; presentacion viernes 11.

## Estado de los 6 entregables

| # | Entregable | Estado | Bloque |
|---|-----------|--------|--------|
| 1 | Codigo COBOL (12 programas) | En curso (2 de 12) | 1-3 |
| 2 | WFL (orquestacion, restart) | Pendiente | 3 |
| 3 | Diseno tecnico | Borrador listo | 1 |
| 4 | Evidencias de pruebas | Pendiente | 3 |
| 5 | Reporte de performance | Pendiente | 3 |
| 6 | Presentacion (guion 20 min) | Pendiente | 3 |

---

## Bloque 1 - Lunes 7 sep  [HECHO]

Que se hizo:
- Diseno tecnico (DISENO_TECNICO.md): caso de negocio, arquitectura MCP mapeada a GnuCOBOL,
  flujos online y batch, archivos, los 12 programas y las dependencias del JOB.
- ALTACUENTA (online): da de alta cuentas de empleados en el maestro CUENTAS (indexado por
  numero de cuenta). Compila y corre.
- CONSULTACUENTA (online): consulta una cuenta por su numero y muestra datos y saldo.
  Compila y corre.
- Maestro CUENTAS.DAT creado con 4 cuentas de prueba.
- Repo en GitHub (beca-cobol-nomina) con el codigo del bloque.

Que decir en el avance (talking points):
- "Arranque con los cimientos: el diseno tecnico y el maestro de cuentas."
- "El maestro de cuentas es un archivo indexado, con el numero de cuenta como llave, que es
  el equivalente en GnuCOBOL de lo que en MCP seria DMSII."
- "Ya tengo dos operaciones online funcionando: alta de cuenta y consulta por numero."
- "El saldo arranca en cero a proposito: la nomina se abona despues, por el proceso batch."

Prueba mostrada: alta de 4 empleados, consulta de una cuenta existente (con su saldo) y de
una inexistente (mensaje de no encontrada).

---

## Bloque 2 - Martes 8 sep  [PENDIENTE]

Plan:
- DEPOSITO (abono de nomina), RETIRO (deducciones), TRANSFERENCIA (a terceros): validan la
  cuenta, aplican la regla (retiro no deja saldo negativo), actualizan el saldo y registran
  un movimiento con id unico.
- VALIDAR-MOVIMIENTOS (batch): separa validos de rechazados; los rechazos van a un LOG.
- Esqueleto de PROC-DEPOSITOS / PROC-RETIROS / PROC-TRANSFERENCIAS.
- Generador de volumen (miles de movimientos) para las pruebas.

Que decir (se llena al cerrar el bloque):
- ...

---

## Bloque 3 - Miercoles 9 sep  [PENDIENTE]

Plan:
- Rematar la cadena batch: CONSOLIDAR, ACTUALIZAR-SALDOS, GENERAR-REPORTES.
- WFL: el JOB con orquestacion, paralelismo, dependencias y restart, mas el orquestador que
  corre la cadena real en GnuCOBOL.
- Idempotencia (por id de movimiento) y restart (por checkpoint de fase).
- Las 5 pruebas: funcional, volumen, error, restart, duplicidad.
- Reporte de performance y guion de presentacion de 20 min.

Que decir (se llena al cerrar el bloque):
- ...
