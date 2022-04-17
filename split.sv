`timescale 1ns/1fs
import SystemVerilogCSP::*;

module split_4(interface L, interface Ctrl, interface A, B, C, D);
parameter FL=4;
parameter BL=6;
parameter WIDTH=34;
logic [WIDTH-1:0]packet;
logic [1:0]controlPort;
always begin
	fork
	begin
	L.Receive(packet);
	#FL;
	end
	begin
	Ctrl.Receive(controlPort);
	#FL;
	end
	join

	if(controlPort==2'b00) begin
	A.Send(packet);
	#BL; end
	else if(controlPort==2'b01) begin
	B.Send(packet);
	#BL; end
	else if(controlPort==2'b10) begin
	C.Send(packet);
	#BL; end
	else if(controlPort==2'b11) begin
	D.Send(packet);
	#BL; end
end
endmodule


module data_generator_4(interface R);
parameter WIDTH = 12;
parameter FL = 4;
logic [WIDTH-1:0] SendValue;
always begin 
	SendValue = $random() % (2**WIDTH);//2**WIDTH=MAX
	#FL;
	R.Send(SendValue);
	//$display("dg send data=%d @ %t",SendValue,$time);
end
endmodule



module data_bucket_4 (interface L);
parameter WIDTH = 12;
parameter BL = 2; 
logic [WIDTH-1:0] ReceiveValue;
always begin
	L.Receive(ReceiveValue);
	#BL;
end
endmodule




module split_tb;
	Channel #(.hsProtocol(P4PhaseBD),.WIDTH(34)) intf  [5:0] ();
	data_generator_4     #(.WIDTH(15), .FL(15)) dg_L(.R(intf[0]));
	data_generator_4     #(.WIDTH(2), .FL(15)) dg_ctrl(.R(intf[1]));
	split_4              #(.WIDTH(15), .FL(15), .BL(15)) splt(.L(intf[0]), .Ctrl(intf[1]), .A(intf[2]), .B(intf[3]), .C(intf[4]), .D(intf[5]));
	data_bucket_4        #(.WIDTH(15), .BL(15)) dbA(.L(intf[2]));
	data_bucket_4        #(.WIDTH(15), .BL(15)) dbB(.L(intf[3]));
	data_bucket_4        #(.WIDTH(15), .BL(15)) dbC(.L(intf[4]));
	data_bucket_4        #(.WIDTH(15), .BL(15)) dbD(.L(intf[5]));
initial
	#800 $stop;
endmodule