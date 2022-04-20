`timescale 1ns/1ps
import SystemVerilogCSP::*;
module Partial_sum_adder_tb;
parameter WIDTH=34;
Channel #(.hsProtocol(P4PhaseBD)) intf  [1:0] ();
data_generator dg1 (.r(intf[0]));
Partial_sum_adder #(.adder_number(2'b10)) psa1(.in(intf[0]),.out(intf[1]));
data_bucket db1 (.r(intf[1]));
/***logic [WIDTH-1:0] packet;
reg [7:0] mem_p_fromAdder;
reg [3:0] des_addr_fromAdder,spike_addr;
***/
initial begin/***
packet={1000_0100,10,{16{1'b0}},0000_1010};//pe1 partial value:10=1010
intf[0].Send(packet);

packet={1001_0100,10,{16{1'b0}},0000_0101};//pe2 partial value:5=0101
intf[0].Send(packet);

packet={1010_0100,10,{16{1'b0}},0000_0001};//pe3 partial value:1=0001
intf[0].Send(packet);


intf[1].Receive(packet);//mem_p
mem_p_fromAdder=packet[7:0];
des_addr_fromAdder=packet[33:30];
$display("des_addr:%b,...data:%b",des_addr_fromAdder,mem_p_fromAdder);

intf[1].Receive(packet);//out_sp
spike_addr=packet[3:0];
des_addr_fromAdder=packet[33:30];
$display("des_addr:%b,...spike_addr:%b",des_addr,spike_addr);***/
#100;
end
endmodule