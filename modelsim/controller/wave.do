onerror {resume}
quietly WaveActivateNextPane {} 0

# === 与你之前习惯相同的顶层信号 (top-level signals) ===
add wave -noupdate -label KEY -radix binary /testbench/KEY
add wave -noupdate -label SW  -radix binary -expand /testbench/SW

# === 被测模块分隔 (divider for UUT) ===
add wave -noupdate -divider controller_fsm

# 关键端口 (key ports)
add wave -noupdate -label clk          -radix binary   /testbench/U1/clk
add wave -noupdate -label reset        -radix binary   /testbench/U1/reset
add wave -noupdate -label match_flag   -radix binary   /testbench/U1/match_flag
add wave -noupdate -label halt_signal  -radix binary   /testbench/U1/halt_signal
add wave -noupdate -label enable_count -radix binary   /testbench/U1/enable_count
add wave -noupdate -label state        -radix unsigned /testbench/U1/state

TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1000 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 120
configure wave -valuecolwidth 60
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {5 us}
