transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/marie/Workspace/MPEG_TS_RECORDER/TestProjects/FIFO_TEST {C:/Users/marie/Workspace/MPEG_TS_RECORDER/TestProjects/FIFO_TEST/FIFO_DC_i4o4_8d.v}

vlog -vlog01compat -work work +incdir+C:/Users/marie/Workspace/MPEG_TS_RECORDER/TestProjects/FIFO_TEST {C:/Users/marie/Workspace/MPEG_TS_RECORDER/TestProjects/FIFO_TEST/FIFO_DC_i4o4_8d_TB.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L rtl_work -L work -voptargs="+acc"  FIFO_DC_i4o4_8d_TB

do C:/Users/marie/Workspace/MPEG_TS_RECORDER/TestProjects/FIFO_TEST/../ELEC5566M-Resources/simulation/load_sim.tcl
