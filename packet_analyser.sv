
`timescale 1ns/1fs
import SystemVerilogCSP::*;

module packet_analyser_3(interface N_L, N_ctrl, N_R, S_L, S_ctrl, S_R, E_L, E_ctrl, E_R, W_L, W_ctrl, W_R, P_L, P_ctrl, P_R);
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




















