transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/marie/Workspace/TS_RECORDER {C:/Users/marie/Workspace/TS_RECORDER/BUFFER_OP.v}
vlog -vlog01compat -work work +incdir+C:/Users/marie/Workspace/TS_RECORDER {C:/Users/marie/Workspace/TS_RECORDER/BUFFER_IP.v}
vlog -vlog01compat -work work +incdir+C:/Users/marie/Workspace/TS_RECORDER {C:/Users/marie/Workspace/TS_RECORDER/BUFFER_COMB.v}
vlog -vlog01compat -work work +incdir+C:/Users/marie/Workspace/TS_RECORDER {C:/Users/marie/Workspace/TS_RECORDER/ResetSynchroniser.v}
vlog -vlog01compat -work work +incdir+C:/Users/marie/Workspace/TS_RECORDER {C:/Users/marie/Workspace/TS_RECORDER/NBitSynchroniser.v}
vlog -vlog01compat -work work +incdir+C:/Users/marie/Workspace/TS_RECORDER {C:/Users/marie/Workspace/TS_RECORDER/BUTTON_REL_DET.v}
vlog -vlog01compat -work work +incdir+C:/Users/marie/Workspace/TS_RECORDER {C:/Users/marie/Workspace/TS_RECORDER/TS_WIRE.v}
vlog -vlog01compat -work work +incdir+C:/Users/marie/Workspace/TS_RECORDER {C:/Users/marie/Workspace/TS_RECORDER/TS_STATE_MACHINE.v}

