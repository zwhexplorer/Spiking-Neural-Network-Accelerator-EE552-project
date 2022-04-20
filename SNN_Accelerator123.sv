`timescale 1ns/1ps
import SystemVerilogCSP::*;
module SNN_Accelerator123;
parameter WIDTH=34;
parameter FL=2;
parameter BL=1;
parameter x1=2'b00;
parameter x2=2'b01;
parameter x3=2'b10;
parameter y1=2'b00;
parameter y2=2'b01;
parameter y3=2'b10;
parameter adder1_num=2'b00;
parameter adder2_num=2'b01;
parameter adder3_num=2'b10;
parameter Adder1_addr=4'b0001;
parameter Adder2_addr=4'b0101;
parameter Adder3_addr=4'b1001;

Channel #(.hsProtocol(P4PhaseBD),.WIDTH(34)) intf  [49:0] ();


router #(.WIDTH(WIDTH), 
         .FL(FL), 
		 .BL(BL), 
		 .Xaddr(x1), 
		 .Yaddr(y1)) 
router1 (.N_in(intf[49]),
		 .N_out(intf[49]),
		 .S_in(intf[5]), 
		 .S_out(intf[4]),
		 .E_in(intf[1]),
		 .E_out(intf[0]), 
		 .W_in(intf[49]), 
		 .W_out(intf[49]),
		 .P_in(intf[3]),
		 .P_out(intf[2]));
		 
		 
router #(.WIDTH(WIDTH), 
         .FL(FL), 
		 .BL(BL), 
		 .Xaddr(x2), 
		 .Yaddr(y1)) 
router2 (.N_in(intf[49]),
		 .N_out(intf[49]),
		 .S_in(intf[11]), 
		 .S_out(intf[10]),
		 .E_in(intf[7]),
		 .E_out(intf[6]), 
		 .W_in(intf[0]), 
		 .W_out(intf[1]),
		 .P_in(intf[9]),
		 .P_out(intf[8]));
		 
		 
		 
router #(.WIDTH(WIDTH), 
         .FL(FL), 
		 .BL(BL), 
		 .Xaddr(x3), 
		 .Yaddr(y1)) 
router3 (.N_in(intf[49]),
		 .N_out(intf[49]),
		 .S_in(intf[22]), 
		 .S_out(intf[21]),
		 .E_in(intf[49]),
		 .E_out(intf[49]), 
		 .W_in(intf[6]), 
		 .W_out(intf[7]),
		 .P_in(intf[20]),
		 .P_out(intf[19]));
		 
router #(.WIDTH(WIDTH), 
         .FL(FL), 
		 .BL(BL), 
		 .Xaddr(x1), 
		 .Yaddr(y2)) 
router4 (.N_in(intf[4]),
		 .N_out(intf[5]),
		 .S_in(intf[28]), 
		 .S_out(intf[27]),
		 .E_in(intf[24]),
		 .E_out(intf[23]), 
		 .W_in(intf[49]), 
		 .W_out(intf[49]),
		 .P_in(intf[26]),
		 .P_out(intf[25]));
		 

router #(.WIDTH(WIDTH), 
         .FL(FL), 
		 .BL(BL), 
		 .Xaddr(x2), 
		 .Yaddr(y2)) 
router5 (.N_in(intf[10]),
		 .N_out(intf[11]),
		 .S_in(intf[34]), 
		 .S_out(intf[33]),
		 .E_in(intf[30]),
		 .E_out(intf[29]), 
		 .W_in(intf[23]), 
		 .W_out(intf[24]),
		 .P_in(intf[32]),
		 .P_out(intf[31]));
		 
		 
router #(.WIDTH(WIDTH), 
         .FL(FL), 
		 .BL(BL), 
		 .Xaddr(x3), 
		 .Yaddr(y2)) 
router6 (.N_in(intf[21]),
		 .N_out(intf[22]),
		 .S_in(intf[38]), 
		 .S_out(intf[37]),
		 .E_in(intf[49]),
		 .E_out(intf[49]), 
		 .W_in(intf[29]), 
		 .W_out(intf[30]),
		 .P_in(intf[36]),
		 .P_out(intf[35]));
		 
		 
router #(.WIDTH(WIDTH), 
         .FL(FL), 
		 .BL(BL), 
		 .Xaddr(x1), 
		 .Yaddr(y3)) 
router7 (.N_in(intf[27]),
		 .N_out(intf[28]),
		 .S_in(intf[49]), 
		 .S_out(intf[49]),
		 .E_in(intf[40]),
		 .E_out(intf[39]), 
		 .W_in(intf[49]), 
		 .W_out(intf[49]),
		 .P_in(intf[42]),
		 .P_out(intf[41]));
		 
router #(.WIDTH(WIDTH), 
         .FL(FL), 
		 .BL(BL), 
		 .Xaddr(x2), 
		 .Yaddr(y3)) 
router8 (.N_in(intf[33]),
		 .N_out(intf[34]),
		 .S_in(intf[49]), 
		 .S_out(intf[49]),
		 .E_in(intf[44]),
		 .E_out(intf[43]), 
		 .W_in(intf[39]), 
		 .W_out(intf[40]),
		 .P_in(intf[46]),
		 .P_out(intf[45]));		 
		 
router #(.WIDTH(WIDTH), 
         .FL(FL), 
		 .BL(BL), 
		 .Xaddr(x3), 
		 .Yaddr(y3)) 
router9 (.N_in(intf[37]),
		 .N_out(intf[38]),
		 .S_in(intf[49]), 
		 .S_out(intf[49]),
		 .E_in(intf[49]),
		 .E_out(intf[49]), 
		 .W_in(intf[43]), 
		 .W_out(intf[44]),
		 .P_in(intf[48]),
		 .P_out(intf[47]));		
		 
		 

memory_wrapper memory_wrapper1(.toMemRead(intf[12]), .toMemWrite(intf[13]),
					.toMemT(intf[14]), 
				    .toMemX(intf[15]),.toMemY(intf[16]),
					.toMemSendData(intf[17]),
				    .fromMemGetData(intf[18]),
					.toNOC(intf[3]),.fromNOC(intf[2]));
memory memory1(.read(intf[12]),
			   .write(intf[13]),
			   .T(intf[14]),
			   .x(intf[15]),
			   .y(intf[16]),
			   .data_out(intf[18]),
			   .data_in(intf[17])); 
data_bucket db1 (.r(intf[8]));
data_bucket db2 (.r(intf[19]));		
Partial_sum_adder #(.adder_number(adder1_num),.Adder_addr(Adder1_addr)) 
                    adder1 (.in(intf[25]),.out(intf[26]));
Partial_sum_adder #(.adder_number(adder2_num),.Adder_addr(Adder2_addr)) 
                    adder2(.in(intf[31]),.out(intf[32]));
Partial_sum_adder #(.adder_number(adder3_num),.Adder_addr(Adder3_addr)) 
                    adder3(.in(intf[35]),.out(intf[36]));	   
pe pe1(.packet_in(intf[41]),.packet_out(intf[42]));
pe pe2(.packet_in(intf[45]),.packet_out(intf[46]));
pe pe3(.packet_in(intf[47]),.packet_out(intf[48]));

initial begin
#20000;
$stop;


end
endmodule


