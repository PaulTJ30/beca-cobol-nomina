# ------------------------------------------------------------------
# SIDN - guion de CAPTURAS para la presentacion
# Corre las 6 pantallas de evidencia (online + las 5 pruebas) con un
# letrero y una pausa en cada una. En cada pausa: toma el pantallazo
# (Win+Shift+S) y presiona Enter para seguir.
# NO tecleas datos: el script siembra cuentas y montos solo.
# ------------------------------------------------------------------
$ErrorActionPreference = "Stop"
$proj = "D:\Ntt\COBOL\ProyectoFinal"
$env:Path = "D:\Program Files\OpenCobolIDE\GnuCOBOL\bin;" + $env:Path
$env:COB_CONFIG_DIR = "D:\Program Files\OpenCobolIDE\GnuCOBOL\config"
$env:TMP = "D:\Ntt\tmp"; $env:TEMP = "D:\Ntt\tmp"
Set-Location $proj

function Limpiar {
  Remove-Item CUENTAS.DAT,PROCESADOS.DAT,CHECKPOINT.TXT,MOVIMIENTOS.TXT,`
    VALIDOS.TXT,LOG-RECHAZOS.TXT,MOVAPLICAR.TXT,CONTROL.TXT,REPORTE.TXT `
    -ErrorAction SilentlyContinue
}
function Sembrar {
  @"
101
JUAN PEREZ HERNANDEZ
TECNOLOGIA ALFA
S
102
MARIA LOPEZ GARCIA
TECNOLOGIA ALFA
S
103
CARLOS RUIZ MENDOZA
CONSTRUCTORA BETA
S
104
ANA TORRES VEGA
CONSTRUCTORA BETA
S
105
LUIS RAMOS CASTRO
COMERCIAL GAMA
S
106
SOFIA DIAZ NUNEZ
COMERCIAL GAMA
S
107
JORGE MENA SOLIS
SERVICIOS DELTA
S
108
ELENA SOTO RIVERA
SERVICIOS DELTA
N
"@ | .\ALTACUENTA.exe | Out-Null
}
function Banner($n,$t) {
  Write-Host ""
  Write-Host "===================================================="
  Write-Host "   CAPTURA $n - $t"
  Write-Host "===================================================="
}
function Pausa { Read-Host "`n>>> Toma el pantallazo y presiona Enter para seguir" | Out-Null }

# ---------- CAPTURA 1: OPERACION ONLINE (saldo cambia en vivo) ----------
Limpiar; Sembrar
Banner 1 "ONLINE - deposito actualiza el saldo en tiempo real"
Write-Host "-- Consulta cuenta 101 (saldo inicial 0):"
"101`nN" | .\CONSULTACUENTA.exe
Write-Host "`n-- Deposito de 500 a la cuenta 101:"
"101`n500`nN" | .\DEPOSITO.exe
Write-Host "`n-- Consulta 101 otra vez (saldo ya subio a 500):"
"101`nN" | .\CONSULTACUENTA.exe
Pausa

# ---------- Estado limpio para el batch ----------
Limpiar; Sembrar
"30" | .\GENERA-MOVIMIENTOS.exe | Out-Null

# ---------- CAPTURA 2: PRUEBA FUNCIONAL (cadena completa) ----------
Banner 2 "FUNCIONAL - cadena batch de punta a punta (30 mov)"
& "$proj\orquestador.ps1"
Write-Host "`n-- REPORTE.TXT (saldos por cuenta + totales de control):"
Get-Content REPORTE.TXT
Pausa

# ---------- CAPTURA 3: PRUEBA DE ERROR (log de rechazos) ----------
Banner 3 "ERROR - movimientos invalidos al log con su causa"
Write-Host "-- LOG-RECHAZOS.TXT (cuentas 9999 = CUENTA NO EXISTE):"
Get-Content LOG-RECHAZOS.TXT
Pausa

# ---------- CAPTURA 4: PRUEBA DE RESTART (checkpoint) ----------
Banner 4 "RESTART - 2a corrida omite las 5 fases por checkpoint"
& "$proj\orquestador.ps1"
Pausa

# ---------- CAPTURA 5: PRUEBA DE DUPLICIDAD (idempotencia) ----------
Banner 5 "DUPLICIDAD - ACTUALIZAR 2a vez no aplica nada (idempotente)"
.\ACTUALIZAR-SALDOS.exe
Pausa

# ---------- CAPTURA 6: PRUEBA DE VOLUMEN (50,000 + tiempos) ----------
Limpiar; Sembrar
"50000" | .\GENERA-MOVIMIENTOS.exe | Out-Null
Banner 6 "VOLUMEN - 50,000 movimientos, tiempo por fase"
$t0 = Get-Date
$d = Measure-Command { .\VALIDAR-MOVIMIENTOS.exe | Out-Host }
Write-Host ("   VALIDAR-MOVIMIENTOS   {0,6:N3} s" -f $d.TotalSeconds)
# Los 3 PROC en paralelo con Start-Process (arranque ligero: mide el
# COBOL, no el overhead de runspaces de Start-Job).
$p = Get-Date
$procs = @()
$procs += Start-Process -FilePath ".\PROC-DEPOSITOS.exe"      -NoNewWindow -PassThru
$procs += Start-Process -FilePath ".\PROC-RETIROS.exe"        -NoNewWindow -PassThru
$procs += Start-Process -FilePath ".\PROC-TRANSFERENCIAS.exe" -NoNewWindow -PassThru
$procs | Wait-Process
Write-Host ("   PROC (D/R/T paralelo) {0,6:N3} s" -f ((Get-Date)-$p).TotalSeconds)
$d = Measure-Command { .\CONSOLIDAR.exe | Out-Host }
Write-Host ("   CONSOLIDAR            {0,6:N3} s" -f $d.TotalSeconds)
$d = Measure-Command { .\ACTUALIZAR-SALDOS.exe | Out-Host }
Write-Host ("   ACTUALIZAR-SALDOS     {0,6:N3} s" -f $d.TotalSeconds)
$d = Measure-Command { .\GENERAR-REPORTES.exe | Out-Host }
Write-Host ("   GENERAR-REPORTES      {0,6:N3} s" -f $d.TotalSeconds)
$tot = ((Get-Date)-$t0).TotalSeconds
Write-Host ("   ------------------------------------")
Write-Host ("   TOTAL CADENA          {0,6:N3} s   (~{1:N0} mov/s)" -f $tot,(50000/$tot))
Pausa

Write-Host "`n=== FIN DE LAS CAPTURAS ==="
