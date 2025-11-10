onerror {resume}
quietly WaveActivateNextPane {} 0

# ===== 顶层驱动 (stimuli) =====
add wave -noupdate -label clk   -radix binary /testbench/clk
add wave -noupdate -label reset -radix binary /testbench/reset

# ===== UUT: order_generator =====
add wave -noupdate -divider order_generator
add wave -noupdate -label buy_price  -radix unsigned /testbench/U1/buy_price
add wave -noupdate -label sell_price -radix unsigned /testbench/U1/sell_price

# （可选）内部信号 (internal signals)
add wave -noupdate -label lfsr1 -radix hexadecimal /testbench/U1/lfsr1
add wave -noupdate -label lfsr2 -radix hexadecimal /testbench/U1/lfsr2
add wave -noupdate -label div   -radix unsigned   /testbench/U1/div

TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1000 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 120
configure wave -valuecolwidth 60
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {5 us}
