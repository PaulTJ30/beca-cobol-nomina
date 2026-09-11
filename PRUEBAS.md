# Evidencias de pruebas
## Sistema de Dispersion de Nomina (SIDN)

Todas las pruebas se corrieron en OpenCOBOL/OpenCobolIDE (Windows). La cadena batch se
ejecuta con orquestador.ps1 o corriendo los programas en orden.

## 1. Prueba funcional (caso feliz)
Objetivo: que la cadena complete de punta a punta y los saldos queden correctos.
- Entrada: 8 cuentas dadas de alta (saldo 0) + 30 movimientos generados.
- Ejecucion: VALIDAR -> PROC (D/R/T) -> CONSOLIDAR -> ACTUALIZAR-SALDOS -> GENERAR-REPORTES.
- Resultado: 30 leidos, 27 validos, 3 rechazados; 27 aplicados al maestro; REPORTE.TXT
  generado con los saldos por cuenta y los totales de control (27 mov, suma $113,300).
- Estado: PASA.

## 2. Prueba de volumen
Objetivo: procesar un volumen alto (una quincena) y medir tiempo.
- Entrada: 50,000 movimientos (45,000 validos, 5,000 rechazados).
- Resultado: cadena completa en 0.55 s (~90,000 movimientos por segundo). Aplicados 45,000;
  suma de control $185,269,900.
- Estado: PASA. (Detalle en PERFORMANCE.md.)

## 3. Prueba de error (datos invalidos)
Objetivo: que los movimientos malos no se apliquen y queden en el log con su causa.
- Entrada: el generador inyecta cuentas inexistentes (9999) cada 10 registros.
- Resultado: VALIDAR-MOVIMIENTOS separo 5,000 rechazados de 50,000 y los escribio a
  LOG-RECHAZOS.TXT con la causa "CUENTA NO EXISTE". Tambien valida tipo (D/R/T), monto > 0 y,
  en transferencias, que exista la cuenta destino.
- Estado: PASA.

## 4. Prueba de restart
Objetivo: que el JOB se pueda reanudar sin repetir fases ya completadas.
- Ejecucion: se corre orquestador.ps1 (crea CHECKPOINT.TXT por fase); se vuelve a correr.
- Resultado: en la segunda corrida detecta el checkpoint y OMITE las 5 fases (VALIDAR, PROC,
  CONSOLIDAR, ACTUALIZAR, REPORTES). Si el JOB cayera a la mitad, reanuda desde la fase
  pendiente. Combinado con la idempotencia (prueba 5), un reinicio nunca duplica.
- Estado: PASA.

## 5. Prueba de duplicidad (idempotencia)
Objetivo: que un mismo movimiento no se aplique dos veces.
- Ejecucion: se corre ACTUALIZAR-SALDOS dos veces sobre el mismo MOVAPLICAR.
- Resultado: 1a corrida aplica 27 (o 45,000) movimientos; 2a corrida los OMITE todos
  (APLICADOS 0, OMITIDOS = total). ACTUALIZAR-SALDOS lleva un indexado PROCESADOS por id de
  movimiento; si el id ya se aplico, lo salta. Los saldos no cambian en la segunda corrida.
- Estado: PASA.

## Resumen
| Prueba | Resultado |
|--------|-----------|
| Funcional | PASA (27/27 aplicados, saldos y reporte correctos) |
| Volumen | PASA (50,000 en 0.55 s) |
| Error | PASA (5,000 rechazos al log con causa) |
| Restart | PASA (reanuda por checkpoint, omite fases hechas) |
| Duplicidad | PASA (idempotencia por id, no aplica dos veces) |
