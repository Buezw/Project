onerror {resume}
quietly WaveActivateNextPane {} 0

# === 顶层信号 (top-level) ===
add wave -noupdate -label KEY -radix binary /testbench/KEY
add wave -noupdate -label SW  -radix binary -expand /testbench/SW

# === 输入价格 (inputs) ===
add wave -noupdate -divider inputs
add wave -noupdate -label buy_price  -radix unsigned /testbench/buy_price
add wave -noupdate -label sell_price -radix unsigned /testbench/sell_price

# === 被测模块输出 (outputs) ===
add wave -noupdate -divider spread
add wave -noupdate -label spread_now -radix unsigned /testbench/U1/spread_now

# （可选）若模块内部有保持寄存器/使能门控信号，可在此追加观察
# add wave -noupdate -label spread_reg -radix unsigned /testbench/U1/spread_reg
# add wave -noupdate -label update_en  -radix binary   /testbench/U1/update_en

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
