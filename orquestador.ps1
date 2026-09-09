# ------------------------------------------------------------------
# Banco Aurora - orquestador de la cadena batch (equivale al JOB WFL)
# Corre la cadena real en GnuCOBOL: valida, procesa por tipo EN
# PARALELO (Start-Job), consolida, aplica al maestro y reporta.
# RESTART: guarda un CHECKPOINT por fase; al reanudar omite las fases
# ya completadas. ACTUALIZAR-SALDOS ademas es idempotente por movimiento.
# ------------------------------------------------------------------
$ErrorActionPreference = "Stop"
$proj = "D:\Ntt\COBOL\ProyectoFinal"
$env:Path = "D:\Program Files\OpenCobolIDE\GnuCOBOL\bin;" + $env:Path
$env:COB_CONFIG_DIR = "D:\Program Files\OpenCobolIDE\GnuCOBOL\config"
$env:TMP = "D:\Ntt\tmp"; $env:TEMP = "D:\Ntt\tmp"
Set-Location $proj

$ckpt = "CHECKPOINT.TXT"
$done = ""
if (Test-Path $ckpt) { $done = (Get-Content $ckpt -Raw) }
function Hecha($f) { return $done.Contains("[$f]") }
function Marcar($f) { Add-Content $ckpt "[$f]"; $script:done += "[$f]" }

Write-Host "=== JOB DISPERSION - orquestador ==="
if ($done) { Write-Host "Reanudando. Fases ya hechas: $done" }

# Fase 1: VALIDAR
if (-not (Hecha "VALIDAR")) {
  Write-Host "[1] VALIDAR-MOVIMIENTOS"; & ".\VALIDAR-MOVIMIENTOS.exe"; Marcar "VALIDAR"
} else { Write-Host "[1] VALIDAR (omitida)" }

# Fase 2: los 3 PROC EN PARALELO
if (-not (Hecha "PROC")) {
  Write-Host "[2] PROC en paralelo (D / R / T)"
  $bin = "D:\Program Files\OpenCobolIDE\GnuCOBOL\bin"
  $sb = {
    param($p,$b,$exe)
    $env:Path = "$b;" + $env:Path
    $env:COB_CONFIG_DIR = "$b\..\config"
    Set-Location $p; & ".\$exe"
  }
  $j1 = Start-Job $sb -ArgumentList $proj,$bin,"PROC-DEPOSITOS.exe"
  $j2 = Start-Job $sb -ArgumentList $proj,$bin,"PROC-RETIROS.exe"
  $j3 = Start-Job $sb -ArgumentList $proj,$bin,"PROC-TRANSFERENCIAS.exe"
  Wait-Job $j1,$j2,$j3 | Out-Null
  Receive-Job $j1,$j2,$j3
  Remove-Job $j1,$j2,$j3
  Marcar "PROC"
} else { Write-Host "[2] PROC (omitida)" }

# Fase 3: CONSOLIDAR
if (-not (Hecha "CONSOLIDAR")) {
  Write-Host "[3] CONSOLIDAR"; & ".\CONSOLIDAR.exe"; Marcar "CONSOLIDAR"
} else { Write-Host "[3] CONSOLIDAR (omitida)" }

# Fase 4: ACTUALIZAR-SALDOS
if (-not (Hecha "ACTUALIZAR")) {
  Write-Host "[4] ACTUALIZAR-SALDOS"; & ".\ACTUALIZAR-SALDOS.exe"; Marcar "ACTUALIZAR"
} else { Write-Host "[4] ACTUALIZAR (omitida)" }

# Fase 5: GENERAR-REPORTES
if (-not (Hecha "REPORTES")) {
  Write-Host "[5] GENERAR-REPORTES"; & ".\GENERAR-REPORTES.exe"; Marcar "REPORTES"
} else { Write-Host "[5] REPORTES (omitida)" }

Write-Host "=== JOB TERMINADO ==="
