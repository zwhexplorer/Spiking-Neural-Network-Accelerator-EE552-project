`timescale 1ns/1fs
import SystemVerilogCSP::*;

//-------------------------------------------------------------------------------------------------------------------------------------------------------
module packet_analyser_5(interface N_L, N_ctrl, N_R, S_L, S_ctrl, S_R, E_L, E_ctrl, E_R, W_L, W_ctrl, W_R, P_L, P_ctrl, P_R);
parameter FL=2;
parameter BL=1;
parameter WIDTH=34;
parameter Xaddr=00;
parameter Yaddr=00;
logic [1:0]Xsour_Nin, Xdest_Nin, Xoffset_Nin;
logic [1:0]Xsour_Sin, Xdest_Sin, Xoffset_Sin;
logic [1:0]Xsour_Ein, Xdest_Ein, Xoffset_Ein;
logic [1:0]Xsour_Win, Xdest_Win, Xoffset_Win;
logic [1:0]Xsour_Pin, Xdest_Pin, Xoffset_Pin;
logic [1:0]Ysour_Nin, Ydest_Nin, Yoffset_Nin;
logic [1:0]Ysour_Sin, Ydest_Sin, Yoffset_Sin;
logic [1:0]Ysour_Ein, Ydest_Ein, Yoffset_Ein;
logic [1:0]Ysour_Win, Ydest_Win, Yoffset_Win;
logic [1:0]Ysour_Pin, Ydest_Pin, Yoffset_Pin;
logic [WIDTH-1:0]packet_Nin, packet_Sin, packet_Ein, packet_Win, packet_Pin;

//packet comes from NORTH
always begin
	N_L.Receive(packet_Nin); #FL;
	fork
	Xsour_Nin = packet_Nin[WIDTH-1:WIDTH-2];
	Ysour_Nin = packet_Nin[WIDTH-3:WIDTH-4];
	Xdest_Nin = packet_Nin[WIDTH-5:WIDTH-6];
	Ydest_Nin = packet_Nin[WIDTH-7:WIDTH-8];
	join
	Xoffset_Nin = Xdest_Nin - Xaddr;
	Yoffset_Nin = Ydest_Nin - Yaddr;
	if (Xoffset_Nin==0 & Yoffset_Nin==0) N_ctrl.Send(10);
	else if (Xoffset_Nin > 0)            N_ctrl.Send(11);
	else if (Xoffset_Nin < 0)            N_ctrl.Send(00);
	else if (Yoffset_Nin > 0)            N_ctrl.Send(01);
	N_R.Send(packet_Nin); #BL;
end


//packet comes from SOUTH
always begin
	S_L.Receive(packet_Sin); #FL;
	fork
	Xsour_Sin = packet_Sin[WIDTH-1:WIDTH-2];
	Ysour_Sin = packet_Sin[WIDTH-3:WIDTH-4];
	Xdest_Sin = packet_Sin[WIDTH-5:WIDTH-6];
	Ydest_Sin = packet_Sin[WIDTH-7:WIDTH-8];
	join
	Xoffset_Sin = Xdest_Sin - Xaddr;
	Yoffset_Sin = Ydest_Sin - Yaddr;
	if (Xoffset_Sin==0 & Yoffset_Sin==0) S_ctrl.Send(10);
	else if (Xoffset_Sin > 0)            S_ctrl.Send(11);
	else if (Xoffset_Sin < 0)            S_ctrl.Send(00);
	else if (Yoffset_Sin < 0)            S_ctrl.Send(01);
	S_R.Send(packet_Sin); #BL;
end


//packet comes from EAST
always begin
	E_L.Receive(packet_Ein); #FL;
	fork
	Xsour_Ein = packet_Ein[WIDTH-1:WIDTH-2];
	Ysour_Ein = packet_Ein[WIDTH-3:WIDTH-4];
	Xdest_Ein = packet_Ein[WIDTH-5:WIDTH-6];
	Ydest_Ein = packet_Ein[WIDTH-7:WIDTH-8];
	join
	Xoffset_Ein = Xdest_Ein - Xaddr;
	Yoffset_Ein = Ydest_Ein - Yaddr;
	if (Xoffset_Ein==0 & Yoffset_Ein==0) E_ctrl.Send(10);
	else if (Xoffset_Ein < 0)            E_ctrl.Send(00);
	else if (Yoffset_Ein > 0)            E_ctrl.Send(11);
	else if (Yoffset_Ein < 0)            E_ctrl.Send(01);
	E_R.Send(packet_Ein); #BL;
end


//packet comes from WEST
always begin
	W_L.Receive(packet_Win); #FL;
	fork
	Xsour_Win = packet_Win[WIDTH-1:WIDTH-2];
	Ysour_Win = packet_Win[WIDTH-3:WIDTH-4];
	Xdest_Win = packet_Win[WIDTH-5:WIDTH-6];
	Ydest_Win = packet_Win[WIDTH-7:WIDTH-8];
	join
	Xoffset_Win = Xdest_Win - Xaddr;
	Yoffset_Win = Ydest_Win - Yaddr;
	if (Xoffset_Win==0 & Yoffset_Win==0) W_ctrl.Send(10);
	else if (Xoffset_Win > 0)            W_ctrl.Send(11);
	else if (Yoffset_Win > 0)            W_ctrl.Send(00);
	else if (Yoffset_Win < 0)            W_ctrl.Send(01);
	W_R.Send(packet_Win); #BL;
end


//packet comes from PE
always begin
	P_L.Receive(packet_Pin); #FL;
	fork
	Xsour_Pin = packet_Pin[WIDTH-1:WIDTH-2];
	Ysour_Pin = packet_Pin[WIDTH-3:WIDTH-4];
	Xdest_Pin = packet_Pin[WIDTH-5:WIDTH-6];
	Ydest_Pin = packet_Pin[WIDTH-7:WIDTH-8];
	join
	Xoffset_Pin = Xdest_Pin - Xaddr;
	Yoffset_Pin = Ydest_Pin - Yaddr;
	if (Xoffset_Pin > 0)      P_ctrl.Send(11);
	else if (Xoffset_Pin < 0) P_ctrl.Send(00);
	else if (Yoffset_Pin > 0) P_ctrl.Send(10);
	else if (Yoffset_Pin < 0) P_ctrl.Send(01);
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
	Channel #(.hsProtocol(P4PhaseBD),.WIDTH(34)) intf  [19:0] ();
	packet_dispatch_2    #(.WIDTH(31), .FL(2)) P_dis(.A(A), .A_P(intf[14]), .A_S(intf[0]),
							.B(B), .B_P(intf[15]), .B_S(intf[1]),
							.C(C), .C_P(intf[16]), .C_S(intf[4]),
							.D(D), .D_P(intf[17]), .D_S(intf[5]));
	arbiter_pipeline_2   #(.WIDTH(2), .FL(2), .BL(2)) ap1(.A(intf[0]), .B(intf[1]), .W(intf[2]), .O(intf[3]));
	arbiter_pipeline_2   #(.WIDTH(2), .FL(2), .BL(2)) ap2(.A(intf[4]), .B(intf[5]), .W(intf[6]), .O(intf[7]));
	arbiter_slackless_2  #(.WIDTH(2), .FL(2), .BL(2)) as1(.A(intf[3]), .B(intf[7]), .W(intf[8]));
	merge_2              #(.WIDTH(2), .FL(2), .BL(2)) mg(.L0(intf[2]), .L1(intf[6]), .R(intf[9]), .Ctrl(intf[8]));
	merge_packet_2       #(.WIDTH(31), .FL(2), .BL(2)) mg_P(.A(intf[14]), .B(intf[15]), .C(intf[16]), .D(intf[17]), .R(R), .Ctrl(intf[9]));
	
endmodule






//-------------------------------------------------------------------------------------------------------------------------------------------------------
module router (interface N_in, N_out, S_in, S_out, E_in, E_out, W_in, W_out, P_in, P_out);
	Channel #(.hsProtocol(P4PhaseBD),.WIDTH(34)) intf  [59:20] ();
	packet_analyser_5         #(.WIDTH(31), .FL(2), .BL(2)) pac_ana(.N_L(N_in), .N_ctrl(intf[50]), .N_R(intf[20]), 
									.S_L(S_in), .S_ctrl(intf[51]), .S_R(intf[21]), 
									.E_L(E_in), .E_ctrl(intf[53]), .E_R(intf[23]), 
									.W_L(W_in), .W_ctrl(intf[52]), .W_R(intf[22]), 
									.P_L(P_in), .P_ctrl(intf[54]), .P_R(intf[24]));
	split_5                   #(.WIDTH(31), .FL(2), .BL(2)) splt_N(.L(intf[20]), .Ctrl(intf[50]), .A(intf[25]), .B(intf[26]), .C(intf[27]), .D(intf[28]));
	split_5                   #(.WIDTH(31), .FL(2), .BL(2)) splt_S(.L(intf[21]), .Ctrl(intf[51]), .A(intf[29]), .B(intf[30]), .C(intf[31]), .D(intf[32]));
	split_5                   #(.WIDTH(31), .FL(2), .BL(2)) splt_E(.L(intf[23]), .Ctrl(intf[53]), .A(intf[37]), .B(intf[38]), .C(intf[39]), .D(intf[40]));
	split_5                   #(.WIDTH(31), .FL(2), .BL(2)) splt_W(.L(intf[22]), .Ctrl(intf[52]), .A(intf[33]), .B(intf[34]), .C(intf[35]), .D(intf[36]));
	split_5                   #(.WIDTH(31), .FL(2), .BL(2)) splt_P(.L(intf[24]), .Ctrl(intf[54]), .A(intf[41]), .B(intf[42]), .C(intf[43]), .D(intf[44]));
	arbiter_withpacket_5      #(.WIDTH(31), .FL(2), .BL(2)) arbi_N(.A(intf[30]), .B(intf[34]), .C(intf[38]), .D(intf[42]), .R(N_out));
	arbiter_withpacket_5      #(.WIDTH(31), .FL(2), .BL(2)) arbi_S(.A(intf[26]), .B(intf[33]), .C(intf[40]), .D(intf[43]), .R(S_out));
	arbiter_withpacket_5      #(.WIDTH(31), .FL(2), .BL(2)) arbi_E(.A(intf[28]), .B(intf[32]), .C(intf[36]), .D(intf[44]), .R(E_out));
	arbiter_withpacket_5      #(.WIDTH(31), .FL(2), .BL(2)) arbi_W(.A(intf[25]), .B(intf[29]), .C(intf[37]), .D(intf[41]), .R(W_out));
	arbiter_withpacket_5      #(.WIDTH(31), .FL(2), .BL(2)) arbi_P(.A(intf[27]), .B(intf[31]), .C(intf[35]), .D(intf[39]), .R(P_out));

endmodule







