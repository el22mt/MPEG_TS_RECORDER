set_global_assignment -entity "PLL_6MHz" -library "lib_PLL_6MHz" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "PLL_6MHz" -library "lib_PLL_6MHz" -name IP_TOOL_VERSION "17.1"
set_global_assignment -entity "PLL_6MHz" -library "lib_PLL_6MHz" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_PLL_6MHz" -name SPD_FILE [file join $::quartus(sip_path) "PLL_6MHz.spd"]

set_global_assignment -library "lib_PLL_6MHz" -name MISC_FILE [file join $::quartus(sip_path) "PLL_6MHz_sim/PLL_6MHz.vo"]
