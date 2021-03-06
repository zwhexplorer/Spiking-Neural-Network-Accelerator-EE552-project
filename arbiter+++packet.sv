`timescale 1ns/1fs
import SystemVerilogCSP::*;

module arbiter_pipeline_2 (interface A,B,W,O);
parameter FL=2;
parameter BL=2;
parameter WIDTH=2;
int winner;
logic [WIDTH-1:0]a,b;
always begin
	wait (A.status != idle || B.status != idle);
	if (A.status != idle && B.status != idle) begin
		winner = ($urandom%2 == 0) ? 0 : 1;
		//$display("1.Both A&B are not idle, winner=%b @ %t",winner,$time);
		end
	else if (A.status != idle) begin
		winner = 0;
		//$display("1.A is not idle(B is idle), winner=%b @ %t",winner,$time);
		end
	else begin // B.status != idle
		winner = 1;
		//$display("1.B is not idle(A is idle), winner=%b @ %t",winner,$time);
		end
	if (winner ==0) begin
		A.Receive(a); 
		//$display("1.A receive %b @ %t",a,$time); 
		#FL;
		fork
		begin
		W.Send(0); 
		//$display("1.W sends 0 from A @ %t",$time);
		end
		begin
		O.Send(0); 
		//$display("1.O sends 0 from A @ %t",$time);
		end
		join 
		#BL;
	end
	else begin
		B.Receive(b); #FL;
		fork 
		begin
		W.Send(1);
		//$display("1.W sends 1 from B @ %t",$time);
		end
		begin
		O.Send(1);
		//$display("1.O sends 1 from B @ %t",$time);
		end
		join
		#BL;
	end
end//always
endmodule



module arbiter_slackless_2 (interface A,B,W);
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
		W.Send(0);
		//$display("2.W receive 0 from A @ %t",$time);
		join
		#BL;
	end
	else begin
		B.Receive(b); #FL;
		fork 
		W.Send(1);
		//$display("2.W receive 1 from B @ %t",$time);
		join
		#BL;
	end
end//always
endmodule



module merge_2(interface L1, interface L2, interface R, interface Ctrl);
parameter FL=2;
parameter BL=2;
parameter WIDTH=2;
logic [WIDTH-2:0]inPort0;
logic [WIDTH-2:0]inPort1;
logic [WIDTH-2:0]controlPort;
always begin
	Ctrl.Receive(controlPort);
	if(controlPort==0) 
	begin
	L1.Receive(inPort0); 
	//$display("3. Merge receive %b from inport0 @ %t",inPort0,$time); #FL;
	R.Send({1'b0,inPort0}); //send_v={1'b1,inprot}; R.Send(send_v)
	//$display("3. Merge send %b @ %t",{1'b0,inPort0},$time); #BL;
	end
	else if(controlPort==1) 
	begin
	L2.Receive(inPort1);
	//$display("3. Merge receive %b from inport1 @ %t",inPort1,$time); #FL;
	R.Send({1'b1,inPort1});
	//$display("3. Merge send %b @ %t",{1'b1,inPort1},$time); #BL;
	end
end
endmodule



module packet_dispatch_2(interface A,A_P,A_S,B,B_P,B_S,C,C_P,C_S,D,D_P,D_S);
parameter FL=2;
parameter BL=2;
parameter WIDTH=34;
logic [WIDTH-1:0] packetA,packetB,packetC,packetD;
always begin
	A.Receive(packetA);	#FL;
	fork
	A_P.Send(packetA);
	A_S.Send(2'b00);
	//$display("1. A Receive packetA @ %t",$time);
	join
	#BL;
end
always begin
	B.Receive(packetB); #FL;
	fork
	B_P.Send(packetB);
	B_S.Send(2'b01);
	//$display("1. B Receive packetB @ %t",$time);
	join
	#BL;
end
always begin
	C.Receive(packetC); #FL;
	fork
	C_P.Send(packetC);
	C_S.Send(2'b10);
	//$display("1. C Receive packetC @ %t",$time);
	join
	#BL;
end
always begin
	D.Receive(packetD); #FL;
	fork
	D_P.Send(packetD);
	D_S.Send(2'b11);
	//$display("1. D Receive packetD @ %t",$time);
	join
	#BL;
end
endmodule



module merge_packet_2(interface A,B,C,D,Ctrl,R);
parameter FL=2;
parameter BL=2;
parameter WIDTH=34;
logic [WIDTH-1:0] packetA,packetB,packetC,packetD;
logic [1:0] controlPort;
always begin
	Ctrl.Receive(controlPort);
	if(controlPort==2'b00) 
	begin
		A.Receive(packetA); #FL;
		fork
		R.Send(packetA);
		//$display("2. A Send packetA @ %t",$time); 
		join
		#BL;
	end
	else if(controlPort==2'b01) 
	begin
		B.Receive(packetB); #FL;
		fork
		R.Send(packetB);
		//$display("2. B Send packetB @ %t",$time);
		join
		#BL;
	end
	else if(controlPort==2'b10) 
	begin
		C.Receive(packetC); #FL;
		fork
		R.Send(packetC);
		//$display("2. C Send packetC @ %t",$time);
		join
		#BL;
	end
	else if(controlPort==2'b11) 
	begin
		D.Receive(packetD); #FL;
		fork
		R.Send(packetD);
		//$display("2. D Send packetD @ %t",$time);
		join
		#BL;
	end
end
endmodule



module data_generator_2(interface R);
parameter WIDTH = 34;
parameter FL = 4;
logic [WIDTH-1:0] SendValue;
always begin 
	SendValue = $random() % (2**WIDTH);//2**WIDTH=MAX  256 0-255
	#FL;
	R.Send(SendValue);
	//$display("dg send data=%d @ %t",SendValue,$time);
end
endmodule


module data_bucket_2 (interface L);
parameter WIDTH = 12;
parameter BL = 2; 
logic [WIDTH-1:0] ReceiveValue;
always begin
	L.Receive(ReceiveValue);
	#BL;
end
endmodule







module arbiter_withpacket_tb;
	Channel #(.hsProtocol(P4PhaseBD),.WIDTH(34)) intf  [18:0] ();
	data_generator_2     #(.WIDTH(31), .FL(15)) dgA(.R(intf[10]));
	data_generator_2     #(.WIDTH(31), .FL(15)) dgB(.R(intf[11]));
	data_generator_2     #(.WIDTH(31), .FL(15)) dgC(.R(intf[12]));
	data_generator_2     #(.WIDTH(31), .FL(15)) dgD(.R(intf[13]));
	packet_dispatch_2    #(.WIDTH(31), .FL(2)) P_dis(.A(intf[10]), .A_P(intf[14]), .A_S(intf[0]),
												.B(intf[11]), .B_P(intf[15]), .B_S(intf[1]),
												.C(intf[12]), .C_P(intf[16]), .C_S(intf[4]),
												.D(intf[13]), .D_P(intf[17]), .D_S(intf[5]));
	arbiter_pipeline_2   #(.WIDTH(2), .FL(2), .BL(2)) ap1(.A(intf[0]), .B(intf[1]), .W(intf[2]), .O(intf[3]));
	arbiter_pipeline_2   #(.WIDTH(2), .FL(2), .BL(2)) ap2(.A(intf[4]), .B(intf[5]), .W(intf[6]), .O(intf[7]));
	arbiter_slackless_2  #(.WIDTH(2), .FL(2), .BL(2)) as1(.A(intf[3]), .B(intf[7]), .W(intf[8]));
	merge_2              #(.FL(2), .BL(2))            mg(.L1(intf[2]), .L2(intf[6]), .R(intf[9]), .Ctrl(intf[8]));
	merge_packet_2       #(.WIDTH(31), .FL(2), .BL(2)) mg_P(.A(intf[14]), .B(intf[15]), .C(intf[16]), .D(intf[17]), .R(intf[18]), .Ctrl(intf[9]));
	data_bucket_2        #(.WIDTH(31), .BL(2)) db1(.L(intf[18]));

initial
	#80 $stop;
endmodule