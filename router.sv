`timescale 1ns/1fs
import SystemVerilogCSP::*;

//-------------------------------------------------------------------------------------------------------------------------------------------------------
module packet_analyser_5(interface N_L, N_ctrl, N_R, S_L, S_ctrl, S_R, E_L, E_ctrl, E_R, W_L, W_ctrl, W_R, P_L, P_ctrl, P_R);
parameter FL=2;
parameter BL=1;
parameter WIDTH=34;
parameter [1:0]Xaddr=00;
parameter [1:0]Yaddr=00;
logic [1:0]Xsour_Nin, Xdest_Nin;
logic [1:0]Xsour_Sin, Xdest_Sin; 
logic [1:0]Xsour_Ein, Xdest_Ein; 
logic [1:0]Xsour_Win, Xdest_Win;
logic [1:0]Xsour_Pin, Xdest_Pin; 
logic [1:0]Ysour_Nin, Ydest_Nin; 
logic [1:0]Ysour_Sin, Ydest_Sin;
logic [1:0]Ysour_Ein, Ydest_Ein;
logic [1:0]Ysour_Win, Ydest_Win;
logic [1:0]Ysour_Pin, Ydest_Pin;
logic [WIDTH-1:0]packet_Nin, packet_Sin, packet_Ein, packet_Win, packet_Pin;

//packet comes from NORTH
always begin
	N_L.Receive(packet_Nin); #FL;
	$display("router_num:%m---1. NORTH receive packetN(%b)",packet_Nin);
	fork
	Xsour_Nin = packet_Nin[WIDTH-1:WIDTH-2];
	Ysour_Nin = packet_Nin[WIDTH-3:WIDTH-4];
	Xdest_Nin = packet_Nin[WIDTH-5:WIDTH-6];
	Ydest_Nin = packet_Nin[WIDTH-7:WIDTH-8];
	join
	$display("router_num:%m---1. The router address is %b%b",Xaddr,Yaddr);
	$display("router_num:%m---1. packetN destination address is %b%b",Xdest_Nin,Ydest_Nin);
	if (Xdest_Nin==Xaddr & Ydest_Nin==Yaddr) 
		begin 
		N_ctrl.Send(10); 
		$display("router_num:%m---1. packetN should send from NORTH to PE"); 
		end
	else if (Xdest_Nin > Xaddr)            
		begin 
		N_ctrl.Send(11);  
		$display("router_num:%m---1. packetN should send from NORTH to EAST");
		end
	else if (Xdest_Nin < Xaddr)           
		begin 
		N_ctrl.Send(00); 
		$display("router_num:%m---1. packetN should send from NORTH to WEST");
		end
	else if (Ydest_Nin > Yaddr)           
		begin 
		N_ctrl.Send(01); 
		$display("router_num:%m---1. packetN should send from NORTH to SOUTH");
		end
	N_R.Send(packet_Nin); #BL;
end


//packet comes from SOUTH
always begin
	S_L.Receive(packet_Sin); #FL;
	$display("router_num:%m---2. SOUTH receive packetS(%b)",packet_Sin);
	fork
	Xsour_Sin = packet_Sin[WIDTH-1:WIDTH-2];
	Ysour_Sin = packet_Sin[WIDTH-3:WIDTH-4];
	Xdest_Sin = packet_Sin[WIDTH-5:WIDTH-6];
	Ydest_Sin = packet_Sin[WIDTH-7:WIDTH-8];
	join
	$display("router_num:%m---2. The router address is %b%b",Xaddr,Yaddr);
	$display("router_num:%m---2. packetS destination address is %b%b",Xdest_Sin,Ydest_Sin);
	if (Xdest_Sin==Xaddr & Ydest_Sin==Yaddr) 
		begin
		S_ctrl.Send(10); 
		$display("router_num:%m---2. packetS should send from SOUTH to PE"); 
		end
	else if (Xdest_Sin > Xaddr)            
		begin
		S_ctrl.Send(11);
		$display("router_num:%m---2. packetS should send from SOUTH to EAST"); 
		end
	else if (Xdest_Sin < Xaddr)            
		begin
		S_ctrl.Send(00);
		$display("router_num:%m---2. packetS should send from SOUTH to WEST"); 
		end
	else if (Ydest_Sin < Yaddr)            
		begin
		S_ctrl.Send(01);
		$display("router_num:%m---2. packetS should send from SOUTH to NORTH"); 
		end
	S_R.Send(packet_Sin); #BL;
end


//packet comes from EAST
always begin
	E_L.Receive(packet_Ein); #FL;
	$display("router_num:%m---3. EAST receive packetE(%b)",packet_Ein);
	fork
	Xsour_Ein = packet_Ein[WIDTH-1:WIDTH-2];
	Ysour_Ein = packet_Ein[WIDTH-3:WIDTH-4];
	Xdest_Ein = packet_Ein[WIDTH-5:WIDTH-6];
	Ydest_Ein = packet_Ein[WIDTH-7:WIDTH-8];
	join
	$display("router_num:%m---3. The router address is %b%b",Xaddr,Yaddr);
	$display("router_num:%m---3. packetE destination address is %b%b",Xdest_Ein,Ydest_Ein);
	if (Xdest_Ein==Xaddr & Ydest_Ein==Yaddr) 
		begin
		E_ctrl.Send(10);
		$display("router_num:%m---3. packetE should send from EAST to PE"); 
		end
	else if (Xdest_Ein < Xaddr)            
		begin
		E_ctrl.Send(00);
		$display("router_num:%m---3. packetE should send from EAST to WEST"); 
		end
	else if (Ydest_Ein > Yaddr)            
		begin
		E_ctrl.Send(11);
		$display("router_num:%m---3. packetE should send from EAST to SOUTH"); 
		end
	else if (Ydest_Ein < Yaddr)            
		begin
		E_ctrl.Send(01);
		$display("router_num:%m---3. packetE should send from EAST to NORTH"); 
		end
	E_R.Send(packet_Ein); #BL;
end


//packet comes from WEST
always begin
	W_L.Receive(packet_Win); #FL;
	$display("router_num:%m---4. WEST receive packetW(%b)",packet_Win);
	fork
	Xsour_Win = packet_Win[WIDTH-1:WIDTH-2];
	Ysour_Win = packet_Win[WIDTH-3:WIDTH-4];
	Xdest_Win = packet_Win[WIDTH-5:WIDTH-6];
	Ydest_Win = packet_Win[WIDTH-7:WIDTH-8];
	join
	$display("router_num:%m---4. The router address is %b%b",Xaddr,Yaddr);
	$display("router_num:%m---4. packetW destination address is %b%b",Xdest_Win,Ydest_Win);
	if (Xdest_Win==Xaddr & Ydest_Win==Yaddr) 
		begin
		W_ctrl.Send(10);
		$display("router_num:%m---4. packetW should send from WEST to PE"); 
		end
	else if (Xdest_Win > Xaddr)            
		begin
		W_ctrl.Send(11);
		$display("router_num:%m---4. packetW should send from WEST to EAST"); 
		end
	else if (Ydest_Win > Yaddr)           
		begin
		W_ctrl.Send(00);
		$display("router_num:%m---4. packetW should send from WEST to SOUTH"); 
		end
	else if (Ydest_Win < Yaddr)            
		begin
		W_ctrl.Send(01);
		$display("router_num:%m---4. packetW should send from WEST to NORTH"); 
		end
	W_R.Send(packet_Win); #BL;
end


//packet comes from PE
always begin
	P_L.Receive(packet_Pin); #FL;
	$display("router_num:%m---5. PE receive packetP(%b)",packet_Pin);
	fork
	Xsour_Pin = packet_Pin[WIDTH-1:WIDTH-2];
	Ysour_Pin = packet_Pin[WIDTH-3:WIDTH-4];
	Xdest_Pin = packet_Pin[WIDTH-5:WIDTH-6];
	Ydest_Pin = packet_Pin[WIDTH-7:WIDTH-8];
	join
	$display("router_num:%m---5. The router address is %b%b",Xaddr,Yaddr);
	$display("router_num:%m---5. packetP destination address is %b%b",Xdest_Pin,Ydest_Pin);
	if (Xdest_Pin > Xaddr)      
		begin
		P_ctrl.Send(11);
		$display("router_num:%m---5. packetP should send from PE to EAST"); 
		end
	else if (Xdest_Pin < Xaddr) 
		begin
		P_ctrl.Send(00);
		$display("router_num:%m---5. packetP should send from PE to WEST"); 
		end
	else if (Ydest_Pin > Yaddr) 
		begin
		P_ctrl.Send(10);
		$display("router_num:%m---5. packetP should send from PE to SOUTH"); 
		end
	else if (Ydest_Pin < Yaddr) 
		begin
		P_ctrl.Send(01);
		$display("router_num:%m---5. packetP should send from PE to NORTH"); 
		end
	P_R.Send(packet_Pin); #BL;
end
endmodule







//-------------------------------------------------------------------------------------------------------------------------------------------------------
module split_5(interface L, interface Ctrl, interface A, B, C, D);
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






//-------------------------------------------------------------------------------------------------------------------------------------------------------
module arbiter_withpacket_5 (interface A, B, C, D, R);
parameter WIDTH;
parameter FL, BL;
	Channel #(.hsProtocol(P4PhaseBD),.WIDTH(34)) intf  [19:0] ();
	packet_dispatch_2   #(.WIDTH(WIDTH), .FL(FL)) P_dis(.A(A), .A_P(intf[14]), .A_S(intf[0]),
														.B(B), .B_P(intf[15]), .B_S(intf[1]),
														.C(C), .C_P(intf[16]), .C_S(intf[4]),
														.D(D), .D_P(intf[17]), .D_S(intf[5]));
	arbiter_pipeline_2  #(.WIDTH(2), .FL(FL), .BL(BL)) ap1(.A(intf[0]), .B(intf[1]), .W(intf[2]), .O(intf[3]));
	arbiter_pipeline_2  #(.WIDTH(2), .FL(FL), .BL(BL)) ap2(.A(intf[4]), .B(intf[5]), .W(intf[6]), .O(intf[7]));
	arbiter_slackless_2 #(.WIDTH(2), .FL(FL), .BL(FL)) as1(.A(intf[3]), .B(intf[7]), .W(intf[8]));
	merge_2             #(.WIDTH(2), .FL(FL), .BL(FL)) mg(.L0(intf[2]), .L1(intf[6]), .R(intf[9]), .Ctrl(intf[8]));
	merge_packet_2      #(.WIDTH(WIDTH), .FL(FL), .BL(FL)) mg_P(.A(intf[14]), .B(intf[15]), .C(intf[16]), .D(intf[17]), .R(R), .Ctrl(intf[9]));
	
endmodule






//-------------------------------------------------------------------------------------------------------------------------------------------------------
module router (interface N_in, N_out, S_in, S_out, E_in, E_out, W_in, W_out, P_in, P_out);
parameter WIDTH;
parameter FL, BL;
parameter Xaddr;
parameter Yaddr;
	Channel #(.hsProtocol(P4PhaseBD),.WIDTH(34)) intf  [59:20] ();
	packet_analyser_5         #(.WIDTH(WIDTH), .FL(FL), .BL(BL), .Xaddr(Xaddr), .Yaddr(Yaddr))
								pac_ana(.N_L(N_in), .N_ctrl(intf[50]), .N_R(intf[20]), 
										.S_L(S_in), .S_ctrl(intf[51]), .S_R(intf[21]), 
										.E_L(E_in), .E_ctrl(intf[53]), .E_R(intf[23]), 
										.W_L(W_in), .W_ctrl(intf[52]), .W_R(intf[22]), 
										.P_L(P_in), .P_ctrl(intf[54]), .P_R(intf[24]));
	split_5                   #(.WIDTH(WIDTH), .FL(FL), .BL(BL)) splt_N(.L(intf[20]), .Ctrl(intf[50]), .A(intf[25]), .B(intf[26]), .C(intf[27]), .D(intf[28]));
	split_5                   #(.WIDTH(WIDTH), .FL(FL), .BL(BL)) splt_S(.L(intf[21]), .Ctrl(intf[51]), .A(intf[29]), .B(intf[30]), .C(intf[31]), .D(intf[32]));
	split_5                   #(.WIDTH(WIDTH), .FL(FL), .BL(BL)) splt_E(.L(intf[23]), .Ctrl(intf[53]), .A(intf[37]), .B(intf[38]), .C(intf[39]), .D(intf[40]));
	split_5                   #(.WIDTH(WIDTH), .FL(FL), .BL(BL)) splt_W(.L(intf[22]), .Ctrl(intf[52]), .A(intf[33]), .B(intf[34]), .C(intf[35]), .D(intf[36]));
	split_5                   #(.WIDTH(WIDTH), .FL(FL), .BL(BL)) splt_P(.L(intf[24]), .Ctrl(intf[54]), .A(intf[41]), .B(intf[42]), .C(intf[43]), .D(intf[44]));
	arbiter_withpacket_5      #(.WIDTH(WIDTH), .FL(FL), .BL(BL)) arbi_N(.A(intf[30]), .B(intf[34]), .C(intf[38]), .D(intf[42]), .R(N_out));
	arbiter_withpacket_5      #(.WIDTH(WIDTH), .FL(FL), .BL(BL)) arbi_S(.A(intf[26]), .B(intf[33]), .C(intf[40]), .D(intf[43]), .R(S_out));
	arbiter_withpacket_5      #(.WIDTH(WIDTH), .FL(FL), .BL(BL)) arbi_E(.A(intf[28]), .B(intf[32]), .C(intf[36]), .D(intf[44]), .R(E_out));
	arbiter_withpacket_5      #(.WIDTH(WIDTH), .FL(FL), .BL(BL)) arbi_W(.A(intf[25]), .B(intf[29]), .C(intf[37]), .D(intf[41]), .R(W_out));
	arbiter_withpacket_5      #(.WIDTH(WIDTH), .FL(FL), .BL(BL)) arbi_P(.A(intf[27]), .B(intf[31]), .C(intf[35]), .D(intf[39]), .R(P_out));

endmodule








/*
module data_generator_5_N(interface R);
parameter WIDTH = 34;
parameter FL = 4;
logic [WIDTH-1:0] SendValue;
initial begin 
	#5;
//	SendValue = 8'b0100_0001; R.Send(SendValue); #FL; 
	SendValue = 8'b0100_0101; R.Send(SendValue); #FL;
	SendValue = 8'b0100_0110; R.Send(SendValue); #FL;
//	SendValue = 8'b0100_1001; #FL; R.Send(SendValue);
//	SendValue = 8'b0100_0010; #FL; R.Send(SendValue);
end
endmodule


module data_generator_5_S(interface R);
parameter WIDTH = 34;
parameter FL = 4;
logic [WIDTH-1:0] SendValue;
initial begin 
	SendValue = 8'b0110_0101; R.Send(SendValue); #FL;
//	SendValue = 8'b0110_1000; #FL; R.Send(SendValue);
//	SendValue = 8'b0110_0100; #FL; R.Send(SendValue);
//	SendValue = 8'b0110_0000; #FL; R.Send(SendValue);
//	SendValue = 8'b0110_0001; R.Send(SendValue); #FL;
end
endmodule


module data_generator_5_E(interface R);
parameter WIDTH = 34;
parameter FL = 4;
logic [WIDTH-1:0] SendValue;
initial begin 
	SendValue = 8'b1001_0101; R.Send(SendValue); #FL;
	SendValue = 8'b1001_0110; R.Send(SendValue); #FL;
//	SendValue = 8'b1001_0100; #FL; R.Send(SendValue);
//	SendValue = 8'b1001_0000; #FL; R.Send(SendValue);
//	SendValue = 8'b1001_0001; R.Send(SendValue); #FL;
end
endmodule


module data_generator_5_W(interface R);
parameter WIDTH = 34;
parameter FL = 4;
logic [WIDTH-1:0] SendValue;
initial begin 
	
	SendValue = 8'b0001_0101; R.Send(SendValue); #FL;
	SendValue = 8'b0001_0110; R.Send(SendValue); #FL;
//	SendValue = 8'b0001_0100; #FL; R.Send(SendValue);
//	SendValue = 8'b0001_1001; #FL; R.Send(SendValue);
//	SendValue = 8'b0001_1010; #FL; R.Send(SendValue);
end
endmodule



module data_generator_5_P(interface R);
parameter WIDTH = 34;
parameter FL = 4;
logic [WIDTH-1:0] SendValue;
initial begin 
	#15;
//	SendValue = 8'b0101_0000; R.Send(SendValue); #FL;
	SendValue = 8'b0101_0110; R.Send(SendValue); #FL;
//	SendValue = 8'b0101_0100; #FL; R.Send(SendValue);
//	SendValue = 8'b0101_1001; #FL; R.Send(SendValue);
//	SendValue = 8'b0101_1010; #FL; R.Send(SendValue);
end
endmodule



module data_generator_5(interface R);
parameter WIDTH = 12;
parameter FL = 4;
logic [WIDTH-1:0] SendValue;
always begin 
	SendValue = $random() % (2**WIDTH);//2**WIDTH=MAX
	R.Send(SendValue);
	#FL;
end
endmodule



module data_bucket_5 (interface L);
parameter WIDTH = 12;
parameter BL = 2; 
logic [WIDTH-1:0] ReceiveValue;
always begin
	L.Receive(ReceiveValue);
	#BL;
end
endmodule


//-------------------------------------------------------------------------------------------------------------------------------------------------------
module router_tb; 
	Channel #(.hsProtocol(P4PhaseBD),.WIDTH(34)) intf  [59:20] ();
	data_generator_5_N        #(.WIDTH(8), .FL(10)) dg_N(.R(intf[55]));
	data_generator_5_S        #(.WIDTH(8), .FL(10)) dg_S(.R(intf[56]));
	data_generator_5_E        #(.WIDTH(8), .FL(10)) dg_E(.R(intf[58]));
	data_generator_5_W        #(.WIDTH(8), .FL(10)) dg_W(.R(intf[57]));
	data_generator_5_P        #(.WIDTH(8), .FL(10)) dg_P(.R(intf[59]));
	packet_analyser_5         #(.WIDTH(8), .FL(2), .BL(2), .Xaddr(01), .Yaddr(01)) 
									pac_ana(.N_L(intf[55]), .N_ctrl(intf[50]), .N_R(intf[20]), 
											.S_L(intf[56]), .S_ctrl(intf[51]), .S_R(intf[21]), 
											.E_L(intf[58]), .E_ctrl(intf[53]), .E_R(intf[23]), 
											.W_L(intf[57]), .W_ctrl(intf[52]), .W_R(intf[22]), 
											.P_L(intf[59]), .P_ctrl(intf[54]), .P_R(intf[24]));
	split_5                   #(.WIDTH(8), .FL(2), .BL(2)) splt_N(.L(intf[20]), .Ctrl(intf[50]), .A(intf[25]), .B(intf[26]), .C(intf[27]), .D(intf[28]));
	split_5                   #(.WIDTH(8), .FL(2), .BL(2)) splt_S(.L(intf[21]), .Ctrl(intf[51]), .A(intf[29]), .B(intf[30]), .C(intf[31]), .D(intf[32]));
	split_5                   #(.WIDTH(8), .FL(2), .BL(2)) splt_E(.L(intf[23]), .Ctrl(intf[53]), .A(intf[37]), .B(intf[38]), .C(intf[39]), .D(intf[40]));
	split_5                   #(.WIDTH(8), .FL(2), .BL(2)) splt_W(.L(intf[22]), .Ctrl(intf[52]), .A(intf[33]), .B(intf[34]), .C(intf[35]), .D(intf[36]));
	split_5                   #(.WIDTH(8), .FL(2), .BL(2)) splt_P(.L(intf[24]), .Ctrl(intf[54]), .A(intf[41]), .B(intf[42]), .C(intf[43]), .D(intf[44]));
	arbiter_withpacket_5      #(.WIDTH(8), .FL(2), .BL(2)) arbi_N(.A(intf[30]), .B(intf[34]), .C(intf[38]), .D(intf[42]), .R(intf[45]));
	arbiter_withpacket_5      #(.WIDTH(8), .FL(2), .BL(2)) arbi_S(.A(intf[26]), .B(intf[33]), .C(intf[40]), .D(intf[43]), .R(intf[46]));
	arbiter_withpacket_5      #(.WIDTH(8), .FL(2), .BL(2)) arbi_E(.A(intf[28]), .B(intf[32]), .C(intf[36]), .D(intf[44]), .R(intf[48]));
	arbiter_withpacket_5      #(.WIDTH(8), .FL(2), .BL(2)) arbi_W(.A(intf[25]), .B(intf[29]), .C(intf[37]), .D(intf[41]), .R(intf[47]));
	arbiter_withpacket_5      #(.WIDTH(8), .FL(2), .BL(2)) arbi_P(.A(intf[27]), .B(intf[31]), .C(intf[35]), .D(intf[39]), .R(intf[49]));
	data_bucket_5             #(.WIDTH(8), .BL(10)) db_N(.L(intf[45]));
	data_bucket_5             #(.WIDTH(8), .BL(10)) db_S(.L(intf[46]));
	data_bucket_5             #(.WIDTH(8), .BL(10)) db_E(.L(intf[48]));
	data_bucket_5             #(.WIDTH(8), .BL(10)) db_W(.L(intf[47]));
	data_bucket_5             #(.WIDTH(8), .BL(10)) db_P(.L(intf[49]));


initial
	#80 $stop;

endmodule
*/


