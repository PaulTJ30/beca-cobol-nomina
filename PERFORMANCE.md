# Reporte de performance
## Banco Aurora - Sistema de Dispersion de Nomina

Medido en GnuCOBOL/OpenCobolIDE sobre archivos indexados/secuenciales locales (Windows,
laptop estandar). Cada fase es un programa; el tiempo se midio lanzando el ejecutable
directo y cronometrando con Python.

## Volumen
- 50,000 movimientos de entrada (una quincena de nomina realista).
- 45,000 validos, 5,000 rechazados (cuentas inexistentes inyectadas para la prueba de error).
- Suma de control aplicada: $22,500,000 (45,000 x $500).

## Tiempo por fase (50,000 movimientos)
| Fase | Tiempo | % del total |
|------|--------|-------------|
| VALIDAR-MOVIMIENTOS | 0.12 s | 20.8% |
| PROC (D/R/T paralelo) | 0.08 s | 13.7% |
| CONSOLIDAR | 0.08 s | 14.3% |
| ACTUALIZAR-SALDOS | 0.24 s | 43.3% |
| GENERAR-REPORTES | 0.04 s | 7.9% |
| **TOTAL** | **0.55 s** | 100% |

## Throughput
- ~90,000 movimientos por segundo, cadena completa.

## Cuello de botella
- **ACTUALIZAR-SALDOS (43%)**. Es la fase con mas I/O: por cada movimiento hace una lectura
  y una reescritura del maestro CUENTAS (indexado) mas una lectura y una escritura en el
  indice de idempotencia PROCESADOS. Es I/O aleatorio contra dos archivos indexados, por eso
  domina el tiempo.

## Optimizaciones aplicadas
1. **Paralelismo**: los tres PROC (depositos, retiros, transferencias) corren en paralelo
   (WFL / orquestador con Start-Job), no en serie.
2. **Acceso indexado**: el maestro CUENTAS se busca por llave (numero de cuenta), no con un
   barrido secuencial; cada lookup es O(log n) en vez de O(n).
3. **Idempotencia por indice**: el control de duplicados usa un indexado por id de
   movimiento, asi el restart no reprocesa lo ya aplicado (evita trabajo repetido).
4. **Validacion antes de aplicar**: los rechazos se filtran en VALIDAR, para que las fases
   pesadas (PROC, ACTUALIZAR) solo trabajen sobre movimientos validos.

## Resultado
Una quincena de 50,000 movimientos se disperso en menos de 1 segundo, con integridad
(idempotencia) y capacidad de reinicio. La fase a optimizar si el volumen creciera mucho es
ACTUALIZAR-SALDOS; una mejora seria agrupar/ordenar por cuenta para reducir el I/O aleatorio.
