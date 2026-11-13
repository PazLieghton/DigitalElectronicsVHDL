# Ejecutar desde la carpeta que contiene FinalMulti.qsf.
# Ejemplo en la consola de ModelSim: do sim/Depurar.do 187 299 81
proc depurar_voltimetro {proyecto valores} {
    set qsf [open [file join $proyecto FinalMulti.qsf] r]
    set fuentes {}
    foreach linea [split [read $qsf] "\n"] {
        if {[regexp {^\s*set_global_assignment\s+-name\s+VHDL_FILE\s+("[^"]+"|\S+)} $linea -> nombre]} {
            lappend fuentes [file join $proyecto [string trim $nombre \"]]
        }
    }
    close $qsf
    if {![llength $fuentes]} { error "FinalMulti.qsf no contiene fuentes VHDL." }
    lappend fuentes [file join $proyecto sim board_sim_tb.vhd]
    lassign $valores c1 c2 c3

    # Una biblioteca nueva en cada ejecución evita simular unidades de una compilación anterior.
    set salida [file normalize [file join $::env(TEMP) "voltimetro-modelsim-[pid]-[clock clicks]"]]
    file mkdir $salida
    set biblioteca [file join $salida work]
    vlib $biblioteca
    # ModelSim analiza las dependencias y después actualiza las unidades en ese orden.
    vcom -93 -autoorder -noautoorderrefresh -work $biblioteca {*}$fuentes
    vcom -refresh_marked -work $biblioteca
    vsim -lib $biblioteca -t ps -voptargs=+acc -wlf [file join $salida ondas.wlf] \
        -gCANAL1_CV=$c1 -gCANAL2_CV=$c2 -gCANAL3_CV=$c3 \
        -gARCHIVO_IMAGEN=[file join $salida imagen.ppm] board_sim_tb

    set placa sim:/board_sim_tb/placa
    set medidor $placa/nucleo/voltimetro_i
    set senales [list \
        [list Entradas binary sim:/board_sim_tb/muestras] \
        [list Realimentacion binary $placa/salidas] \
        [list Reloj_25MHz binary $medidor/clk_i] \
        [list Fin_ventana binary $medidor/fin_ventana]]
    foreach canal {1 2 3} {
        lappend senales [list Cuenta_BCD_$canal hexadecimal $medidor/canal$canal/cuenta_bcd]
        lappend senales [list Lectura_BCD_$canal hexadecimal $medidor/lectura$canal]
    }
    lappend senales [list Captura_VGA binary $medidor/pantalla/captura_cuadro]
    foreach canal {1 2 3} {
        lappend senales [list Pantalla_BCD_$canal hexadecimal $medidor/pantalla/reg${canal}_frame]
    }
    if {![batch_mode]} { view wave }
    foreach senal $senales {
        lassign $senal etiqueta formato ruta
        log $ruta
        if {![batch_mode]} {
            add wave -label $etiqueta -radix $formato $ruta
        }
    }
    run 80 us
    if {![batch_mode]} { wave zoom range 0us 42us }
    puts "Ventanas de 13,24 us. Lecturas BCD: [examine -radix hexadecimal $medidor/lectura1], [examine -radix hexadecimal $medidor/lectura2], [examine -radix hexadecimal $medidor/lectura3]."
    puts "Para completar los dos cuadros VGA, ejecute: run -all"
    puts "Ondas y captura imagen.ppm de la simulación: $salida"
}

set tensiones_cv {}
foreach indice {1 2 3} defecto {42 165 330} {
    if {[info exists $indice]} { set cv [set $indice] } else { set cv $defecto }
    if {![regexp {^[0-9]{1,3}$} $cv] || [scan $cv %d cv] != 1 || $cv > 330} {
        error "El canal $indice requiere un entero entre 0 y 330 centivoltios."
    }
    lappend tensiones_cv $cv
}
depurar_voltimetro [pwd] $tensiones_cv
