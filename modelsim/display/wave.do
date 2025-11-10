onerror {resume}
quietly WaveActivateNextPane {} 0

# === 顶层信号 (top-level) ===
add wave -noupdate -label KEY -radix binary /testbench/KEY
add wave -noupdate -label SW  -radix binary -expand /testbench/SW

# === 显示输入 (display inputs) ===
add wave -noupdate -divider inputs
add wave -noupdate -label buy_price   -radix unsigned /testbench/buy_price
add wave -noupdate -label sell_price  -radix unsigned /testbench/sell_price
add wave -noupdate -label spread_now  -radix unsigned /testbench/spread_now
add wave -noupdate -label trade_count -radix unsigned /testbench/trade_count

# === 被测模块输出 (outputs) ===
add wave -noupdate -divider display_hex
add wave -noupdate -label HEX0 -radix hexadecimal /testbench/U1/HEX0
add wave -noupdate -label HEX1 -radix hexadecimal /testbench/U1/HEX1
add wave -noupdate -label HEX2 -radix hexadecimal /testbench/U1/HEX2
add wave -noupdate -label HEX3 -radix hexadecimal /testbench/U1/HEX3
add wave -noupdate -label HEX4 -radix hexadecimal /testbench/U1/HEX4
add wave -noupdate -label HEX5 -radix hexadecimal /testbench/U1/HEX5
add wave -noupdate -label LEDR -radix binary -expand /testbench/U1/LEDR

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
