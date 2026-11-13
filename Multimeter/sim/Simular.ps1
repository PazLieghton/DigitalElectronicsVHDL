<#
.SYNOPSIS
Simula la placa con GHDL y guarda su salida VGA como imagen PPM.
.DESCRIPTION
Canal1, Canal2 y Canal3 se expresan en centivoltios enteros (0 a 330).
La ruta de salida predeterminada corresponde al directorio actual.
.EXAMPLE
.\sim\Simular.ps1 -Canal1 42 -Canal2 165 -Canal3 330 -Salida pantalla.ppm
#>
[CmdletBinding()]
param (
    [ValidateRange(0, 330)] [int]$Canal1 = 42,
    [ValidateRange(0, 330)] [int]$Canal2 = 165,
    [ValidateRange(0, 330)] [int]$Canal3 = 330,
    [string]$Salida = 'Voltimetro-VGA.ppm'
)

$ErrorActionPreference = 'Stop'
$ghdl = (Get-Command ghdl -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1).Source
if (-not $ghdl) { throw 'Se necesita GHDL en el PATH para ejecutar esta prueba.' }
$destino = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Salida)
if ([IO.Path]::GetExtension($destino) -ne '.ppm') { throw 'La salida debe tener la extension .ppm.' }
if (-not [IO.Directory]::Exists([IO.Path]::GetDirectoryName($destino))) {
    throw "No existe el directorio de salida para $destino"
}
if ([IO.Directory]::Exists($destino)) { throw "La ruta de salida es un directorio: $destino" }

# Se importan las unidades que usa Quartus, tanto en la edición original como en la agrupada.
$proyecto = Split-Path -Parent $PSScriptRoot
$fuentes = @(foreach ($linea in Get-Content -LiteralPath (Join-Path $proyecto 'FinalMulti.qsf')) {
    if ($linea -match '^\s*set_global_assignment\s+-name\s+VHDL_FILE\s+("[^"]+"|\S+)') {
        (Get-Item -LiteralPath (Join-Path $proyecto $Matches[1].Trim('"'))).FullName
    }
})
if ($fuentes.Count -eq 0) { throw 'El proyecto no contiene archivos VHDL.' }
$banco = Join-Path $PSScriptRoot 'board_sim_tb.vhd'

# Cada ejecución usa su propia biblioteca de trabajo para evitar mezclar versiones.
$trabajo = Join-Path ([IO.Path]::GetTempPath()) ('voltimetro-ghdl-' + [guid]::NewGuid().ToString('N'))
[IO.Directory]::CreateDirectory($trabajo) | Out-Null
try {
    Push-Location -LiteralPath $trabajo
    try {
        & $ghdl -i --std=93c @fuentes $banco
        if ($LASTEXITCODE -ne 0) { throw 'GHDL no pudo importar las fuentes.' }
        & $ghdl -m --std=93c board_sim_tb
        if ($LASTEXITCODE -ne 0) { throw 'GHDL no pudo elaborar el banco de pruebas.' }
        & $ghdl -r --std=93c board_sim_tb "-gCANAL1_CV=$Canal1" "-gCANAL2_CV=$Canal2" "-gCANAL3_CV=$Canal3" --assert-level=error
        if ($LASTEXITCODE -ne 0) { throw 'La prueba de la placa ha fallado.' }
        [IO.File]::Copy((Join-Path $trabajo 'imagen.ppm'), $destino, $true)
    } finally {
        Pop-Location
    }
} finally {
    [IO.Directory]::Delete($trabajo, $true)
}
Write-Output "Captura VGA guardada en $destino"
