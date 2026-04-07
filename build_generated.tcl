
# Auto-generated Vivado script

create_project IN-1_IN3P-1_STP_STDP-1_GENS-2_SNN_HW vivado_build_IN-1_IN3P-1_STP_STDP-1_GENS-2_SNN_HW -part xc7a35tcpg236-1 -force

# Add design sources
add_files -fileset sources_1 "C:/Users/ZTF/Documents/GitHub/SNN_HW/Nets/IN-1_IN3P-1_STP_STDP-1_GENS-2_SNN_HW/snn_proj/src/snn.sv" "C:/Users/ZTF/Documents/GitHub/SNN_HW/Service/Clock_divider_HW/clock_divider_proj/src/clock_divider.sv" "C:/Users/ZTF/Documents/GitHub/SNN_HW/Service/Fixed_Point_Arithmetic_HW/fixed_point_arithmetic_proj/src/fixed_point_arithmetic_if.sv" "C:/Users/ZTF/Documents/GitHub/SNN_HW/Service/Signal_generator_HW/signal_generator_proj/src/signal_generator.sv" "C:/Users/ZTF/Documents/GitHub/SNN_HW/Service/Spikes_counter_HW/spikes_counter_proj/src/spikes_counter.sv" "C:/Users/ZTF/Documents/GitHub/SNN_HW/Service/Spikes_counter_HW/spikes_counter_proj/src/spikes_counter_pkg.sv" "C:/Users/ZTF/Documents/GitHub/SNN_HW/Network/Dendrite_HW/dendrite_proj/src/dendrite.sv" "C:/Users/ZTF/Documents/GitHub/SNN_HW/Network/Neuron_Izh_HW/neuron_izh_proj/src/neuron_izh.sv" "C:/Users/ZTF/Documents/GitHub/SNN_HW/Network/Soma_Izh_HW/soma_izh_proj/src/soma_izh.sv" "C:/Users/ZTF/Documents/GitHub/SNN_HW/Network/Soma_Izh_HW/soma_izh_proj/src/soma_izh_pkg.sv" "C:/Users/ZTF/Documents/GitHub/SNN_HW/Network/STDP_HW/stdp_proj/src/stdp.sv" "C:/Users/ZTF/Documents/GitHub/SNN_HW/Network/STDP_HW/stdp_proj/src/stdp_pkg.sv" "C:/Users/ZTF/Documents/GitHub/SNN_HW/Network/STP_HW/stp_proj/src/stp.sv" "C:/Users/ZTF/Documents/GitHub/SNN_HW/Network/STP_HW/stp_proj/src/stp_pkg.sv" "C:/Users/ZTF/Documents/GitHub/SNN_HW/Network/STP_STDP_Synapse_HW/stp_stdp_synapse_proj/src/stp_stdp_synapse.sv" "C:/Users/ZTF/Documents/GitHub/SNN_HW/Network/STP_STDP_Synapse_HW/stp_stdp_synapse_proj/src/stp_stdp_synapse_pkg.sv"

# Add simulation sources
add_files -fileset sim_1 "C:/Users/ZTF/Documents/GitHub/SNN_HW/Nets/IN-1_IN3P-1_STP_STDP-1_GENS-2_SNN_HW/snn_proj/sim/snn_tb.sv" "C:/Users/ZTF/Documents/GitHub/SNN_HW/Network/Dendrite_HW/dendrite_proj/sim/dendrite_tb.sv" "C:/Users/ZTF/Documents/GitHub/SNN_HW/Network/Neuron_Izh_HW/neuron_izh_proj/sim/neuron_izh_tb.sv" "C:/Users/ZTF/Documents/GitHub/SNN_HW/Network/Soma_Izh_HW/soma_izh_proj/sim/soma_tb.sv" "C:/Users/ZTF/Documents/GitHub/SNN_HW/Network/STDP_HW/stdp_proj/sim/stdp_tb.sv" "C:/Users/ZTF/Documents/GitHub/SNN_HW/Network/STP_HW/stp_proj/sim/stp_tb.sv"

# Add constraints
add_files -fileset constrs_1 "C:/Users/ZTF/Documents/GitHub/SNN_HW/Nets/IN-1_IN3P-1_STP_STDP-1_GENS-2_SNN_HW/snn_proj/constrs/Basys3.xdc"

# Set top module
set_property top IN-1_IN3P-1_STP_STDP-1_GENS-2_SNN_HW [current_fileset]

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

puts "Project created: IN-1_IN3P-1_STP_STDP-1_GENS-2_SNN_HW"
