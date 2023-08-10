transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/marie/Workspace/ELEC5566M-Unit2-el22mt/2-P-Synchroniser {C:/Users/marie/Workspace/ELEC5566M-Unit2-el22mt/2-P-Synchroniser/ResetSynchroniser.v}

vlog -vlog01compat -work work +incdir+C:/Users/marie/Workspace/ELEC5566M-Unit2-el22mt/2-P-Synchroniser {C:/Users/marie/Workspace/ELEC5566M-Unit2-el22mt/2-P-Synchroniser/ResetSynchroniser_TB.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L rtl_work -L work -voptargs="+acc"  ResetSynchroniser_TB

do C:/Users/marie/Workspace/ELEC5566M-Unit2-el22mt/2-P-Synchroniser/../../ELEC5566M-Resources/simulation/load_sim.tcl
