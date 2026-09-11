# Como presentar y demostrar - SIDN
## Playbook para el dia de la presentacion

## 0. Antes de empezar (preparacion)
- Preseto: abre una terminal PowerShell en la carpeta y fija el entorno UNA vez (asi todos
  los .exe corren sin problema de rutas):
  ```
  cd D:\Ntt\COBOL\ProyectoFinal
  $env:Path = "D:\Program Files\OpenCobolIDE\GnuCOBOL\bin;" + $env:Path
  $env:COB_CONFIG_DIR = "D:\Program Files\OpenCobolIDE\GnuCOBOL\config"
  $env:TMP = "D:\Ntt\tmp"; $env:TEMP = "D:\Ntt\tmp"
  ```
- Si presentas en OTRA maquina: primero recompila los .cob (los .exe no estan en el repo).
- Deja un estado limpio y unas cuentas sembradas ANTES de presentar:
  ```
  Remove-Item CUENTAS.DAT,PROCESADOS.DAT,CHECKPOINT.TXT -ErrorAction SilentlyContinue
  .\ALTACUENTA.exe     (teclea las 8 cuentas: numero, titular, empresa)
  ```
- Ten abiertos: diagrama_sistema.drawio, GUION_PRESENTACION.md, PRUEBAS.md, PERFORMANCE.md.
- CAPTURAS DE RESPALDO: corre todo hoy y toma pantallazos de cada prueba. Si el demo en vivo
  falla, muestras las capturas y sigues.

## 1. Que enseñar en cada parte (sigue el guion de 20 min)
| Min | Tema | Que muestras en pantalla |
|-----|------|--------------------------|
| 0-3 | Caso + arquitectura | El diagrama (diagrama_sistema.drawio): online vs batch, WFL |
| 3-7 | Proceso online | En vivo: CONSULTACUENTA (consultas una cuenta) y DEPOSITO (ves el saldo cambiar) |
| 7-11 | Programacion COBOL | Abres un .cob (ej. ACTUALIZAR-SALDOS) y muestras el FD indexado + READ/REWRITE |
| 11-14 | WFL y orquestacion | dispersion.wfl + corres orquestador.ps1 (la cadena entera, PROC en paralelo) |
| 14-17 | Volumen y performance | PERFORMANCE.md: 50,000 mov en 0.55 s, cuello = ACTUALIZAR-SALDOS |
| 17-19 | Restart e idempotencia | Corres el orquestador OTRA vez (omite todo) + ACTUALIZAR dos veces |
| 19-20 | Conclusiones | Cierre |

## 2. Las 5 pruebas, en vivo (comandos y que aparece)
Todo en la terminal ya preparada (paso 0).

**Prueba funcional + volumen** (generar movimientos y correr la cadena):
```
.\GENERA-MOVIMIENTOS.exe        (teclea 50000 para volumen, o 200 para algo rapido)
.\orquestador.ps1
```
Aparece: VALIDAR (leidos/validos/rechazados), los 3 PROC en paralelo, CONSOLIDAR (totales),
ACTUALIZAR (aplicados), y "REPORTE GENERADO". Dices el tiempo (esta en PERFORMANCE.md).

**Prueba de error** (los invalidos van al log):
```
notepad LOG-RECHAZOS.TXT
```
Muestras que los movimientos con cuenta inexistente quedaron con su causa "CUENTA NO EXISTE".

**Prueba de restart** (reanuda sin repetir):
```
.\orquestador.ps1
```
Como el CHECKPOINT ya tiene las fases, dice "omitida" en las 5. Explicas: si se cae a la
mitad, reanuda desde ahi.

**Prueba de duplicidad / idempotencia** (no pagar dos veces):
```
.\ACTUALIZAR-SALDOS.exe
```
La segunda corrida dice APLICADOS 0, OMITIDOS = todos. No vuelve a mover saldos.

**El reporte final**:
```
notepad REPORTE.TXT
```
Muestras el saldo por cuenta y los totales de control.

## 3. Orden recomendado del demo (para que fluya)
1. Cuentas ya sembradas -> CONSULTACUENTA una cuenta.
2. DEPOSITO a esa cuenta -> ves el saldo subir (online en tiempo real).
3. GENERA-MOVIMIENTOS 50000 -> orquestador.ps1 (batch completo + paralelo).
4. Abrir REPORTE.TXT y LOG-RECHAZOS.TXT.
5. orquestador.ps1 otra vez -> restart (omite todo).
6. Cerrar con los numeros de performance.

## 4. Plan B (si el demo falla)
- Capturas de cada paso (tomadas hoy).
- PRUEBAS.md y PERFORMANCE.md abiertos: lees los resultados de ahi.
- El repo en GitHub abierto, por si piden ver el codigo.

## 5. Checklist del dia
[ ] .exe compilados en la maquina donde presento
[ ] entorno fijado en la terminal (paso 0)
[ ] cuentas sembradas
[ ] capturas de respaldo listas
[ ] diagrama, guion, PRUEBAS y PERFORMANCE abiertos
[ ] repo actualizado (push hecho)
