`timescale 1ns/1fs
import SystemVerilogCSP::*;

module arbiter_pipeline_1 (interface A,B,W,O);
parameter FL=2;
parameter BL=2;
parameter WIDTH=2;
logic winner;
logic [WIDTH-1:0]a,b;
always begin
	wait (A.status != idle || B.status != idle);
	if (A.status != idle && B.status != idle) begin
		winner = ($urandom%2 == 0) ? 0 : 1;
		$display("1.Both A&B are not idle, winner=%d @ %t",winner,$time);
		end
	else if (A.status != idle) begin
		winner = 0;
		$display("1.A is not idle(B is idle), winner=%d @ %t",winner,$time);
		end
	else begin // B.status != idle
		winner = 1;
		$display("1.B is not idle(A is idle), winner=%d @ %t",winner,$time);
		end
	if (winner == 0) begin
		A.Receive(a); #FL;
		fork
		begin
		W.Send(a);
		$display("1.W receive %d from A @ %t",a,$time);
		end
		begin
		O.Send(0); 
		//$display("1.O sends A @ %t",$time);
		end
		join
		#BL;
	end
	else begin
		B.Receive(b); #FL;
		fork 
		begin
		W.Send(b);
		$display("1.W receive %d from B @ %t",b,$time);
		end
		begin
		O.Send(1);
		//$display("1.O sends B @ %t",$time);
		end
		join
		#BL;
	end
end//always
endmodule



module arbiter_slackless_1 (interface A,B,W);
parameter FL=2;
parameter BL=2;
parameter WIDTH=2;
int winner;
logic [WIDTH-1:0]a,b;
always begin
	wait (A.status != idle || B.status != idle);
	if (A.status != idle && B.status != idle) begin
		winner = ($urandom%2 == 0) ? 0 : 1;
		//$display("2.Both A&B are not idle, winner=%d @ %t",winner,$time);
		end
	else if (A.status != idle) begin
		winner = 0;
		//$display("2.A is not idle(B is idle), winner=%d @ %t",winner,$time);
		end
	else begin // B.status != idle
		winner = 1;
		//$display("2.B is not idle(A is idle), winner=%d @ %t",winner,$time);
		end
	if (winner == 0) begin
		A.Receive(a); #FL;
		fork
		W.Send(a);
		//$display("2.W receive %d from A @ %t",a,$time);
		join
		#BL;
	end
	else begin
		B.Receive(b); #FL;
		fork 
		W.Send(b);
		//$display("2.W receive %d from B @ %t",b,$time);
		join
		#BL;
	end
end//always
endmodule



module merge_1(interface L0, interface L1, interface R, interface Ctrl);
parameter FL=2;
parameter BL=2;
parameter WIDTH=2;
logic [WIDTH-1:0]inPort1;//00,01,10,11
logic [WIDTH-1:0]inPort0;
logic [WIDTH-1:0]controlPort;
always begin
	Ctrl.Receive(controlPort);
	if(controlPort==0) 
	begin
	L0.Receive(inPort0);
	$display("3. Merge receive %d from port1 @ %t",inPort1,$time);
	R.Send(inPort0);
	end
	else if(controlPort==1) 
	begin
	L1.Receive(inPort1);
	$display("3. Merge receive %d from port0 @ %t",inPort0,$time);
	R.Send(inPort1);
	end
end
endmodule




module data_generator_1(interface R);
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


/*module data_generator_A(interface R);
parameter WIDTH = 12;
parameter FL = 4;
logic [WIDTH-1:0] SendValue;
initial begin 
	SendValue = 1; 
	R.Send(SendValue); #15;
	SendValue = 2; 
	R.Send(SendValue); #15;
	SendValue = 3; 
	R.Send(SendValue); #5;
	SendValue = 4; 
	R.Send(SendValue); #15;
end
endmodule
module data_generator_B(interface R);
parameter WIDTH = 12;
parameter FL = 4;
logic [WIDTH-1:0] SendValue;
initial begin 
	#20;
	SendValue = 1; 
	R.Send(SendValue); #15;
	SendValue = 2; 
	R.Send(SendValue); #15;  
	SendValue = 3; 
	R.Send(SendValue); #15;
end
endmodule
*/



module data_bucket_1 (interface L);
parameter WIDTH = 12;
parameter BL = 2; 
logic [WIDTH-1:0] ReceiveValue;
always begin
	L.Receive(ReceiveValue);
	#BL;
end
endmodule



module arbiter_tb;
	Channel #(.hsProtocol(P4PhaseBD)) intf  [9:0] ();
	data_generator_1     #(.WIDTH(2), .FL(15)) dg1(.R(intf[0]));
	data_generator_1     #(.WIDTH(2), .FL(15)) dg2(.R(intf[1]));
	data_generator_1     #(.WIDTH(2), .FL(15)) dg3(.R(intf[4]));
	data_generator_1     #(.WIDTH(2), .FL(15)) dg4(.R(intf[5]));
	arbiter_pipeline_1   #(.WIDTH(2), .FL(2), .BL(2)) ap1(.A(intf[0]), .B(intf[1]), .W(intf[2]), .O(intf[3]));
	arbiter_pipeline_1   #(.WIDTH(2), .FL(2), .BL(2)) ap2(.A(intf[4]), .B(intf[5]), .W(intf[6]), .O(intf[7]));
	arbiter_slackless_1  #(.WIDTH(2), .FL(2), .BL(2)) as1(.A(intf[3]), .B(intf[7]), .W(intf[8]));
	merge_1              #(.WIDTH(2), .FL(2), .BL(2)) mg(.L0(intf[2]), .L1(intf[6]), .R(intf[9]), .Ctrl(intf[8]));
	data_bucket_1        #(.WIDTH(2), .BL(2)) db1(.L(intf[9]));

initial
	#80 $stop;
endmodule