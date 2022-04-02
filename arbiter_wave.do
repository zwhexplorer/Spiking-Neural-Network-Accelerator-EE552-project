onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /arbiter_tb/dg1/SendValue
add wave -noupdate -radix unsigned /arbiter_tb/dg2/SendValue
add wave -noupdate -radix unsigned /arbiter_tb/ap1/winner
add wave -noupdate -radix unsigned /arbiter_tb/ap1/a
add wave -noupdate -radix unsigned /arbiter_tb/ap1/b
add wave -noupdate -radix unsigned /arbiter_tb/dg3/SendValue
add wave -noupdate -radix unsigned /arbiter_tb/dg4/SendValue
add wave -noupdate -radix unsigned /arbiter_tb/ap2/winner
add wave -noupdate -radix unsigned /arbiter_tb/ap2/a
add wave -noupdate -radix unsigned /arbiter_tb/ap2/b
add wave -noupdate -radix unsigned /arbiter_tb/as1/winner
add wave -noupdate -radix unsigned /arbiter_tb/as1/a
add wave -noupdate -radix unsigned /arbiter_tb/as1/b
add wave -noupdate -radix unsigned /arbiter_tb/mg/inPort1
add wave -noupdate -radix unsigned /arbiter_tb/mg/inPort0
add wave -noupdate -radix unsigned /arbiter_tb/mg/controlPort
add wave -noupdate -radix unsigned /arbiter_tb/db1/ReceiveValue
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 fs} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
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
configure wave -timelineunits fs
update
WaveRestoreZoom {0 fs} {210 ns}
