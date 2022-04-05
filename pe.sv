`timescale 1ns/100ps
import SystemVerilogCSP::*;
module data_generator (interface r);
  parameter WIDTH = 34;
  parameter FL = 0; //ideal environment
  logic [WIDTH-1:0] SendValue0=0;
  logic [WIDTH-1:0] SendValue1=0;
  
  initial begin 
    //add a display here to see when this module starts its main loop
    //$display("Start module %m and time is %d",$time);
	SendValue0 = 34'b0000_0100_01_0001_0100_0100_0100_0001_1111;	
    $display("In module %m, SendValue0 is %b", SendValue0);
    //Communication action Send is about to start
    $display("Start sending in module %m. Simulation time =%t", $time);
    r.Send(SendValue0);
	#FL;
	SendValue1 = 34'b0000_0100_00_0000_0000_0000_0000_0001_1111;  
    $display("In module %m, SendValue1 is %b", SendValue1);
    //Communication action Send is about to start
    $display("Start sending in module %m. Simulation time =%t", $time);
    r.Send(SendValue1);
    //Communication action Send is finished
    //$display("Finished sending in module %m. Simulation time =%t", $time);
    //Communication action Send is finished
    //$display("Finished sending in module %m. Simulation time =%t", $time);
  end
endmodule

module depacketizer_PE(interface packet, out_filter, out_ifmap, addr_out, ifmap_count);
	parameter WIDTH=34;
	parameter WIDTH_addr=4;
	parameter WIDTH_ifmap=5;
	parameter WIDTH_filter=24;
	parameter FL=2;
	parameter BL=1;
	logic [WIDTH-1:0] value;
	logic [WIDTH_filter-1:0]filvalue;
	logic [WIDTH_ifmap-1:0] mapvalue;
	logic  tomapvalue;
	logic [WIDTH_addr-1:0] addr_value;
	
	always begin
		packet.Receive(value);
		$display("receive value=%b, Simulation time =%t",value, $time);
		#FL;
		if(value[33:30]==4'b0110)
		begin
			tomapvalue=value[0:0];
			ifmap_count.Send(tomapvalue);
		end
		else
		begin
			if(value[25:24]==2'b00)
			begin
				mapvalue = value[4:0];
				out_ifmap.Send(mapvalue);
				$display("send mapvalue=%b, Simulation time =%t",mapvalue, $time);
			end
			else if(value[25:24]==2'b01)
			begin
				filvalue = value[23:0];
				out_filter.Send(filvalue);
				$display("send filvalue=%b, Simulation time =%t",filvalue, $time);
			end
		end
		//#BL;
		addr_value=value[29:26];
		addr_out.Send(addr_value);
		$display("send addr_value=%b, Simulation time =%t",addr_value, $time);
		#BL;
	end
endmodule

module ifmap_mem (interface ifmap_in, ifmap_count, ifmap_out, to_packet);
parameter WIDTH=5;
//parameter DEPTH_I = 5;
parameter FL=2;
parameter BL=1;
logic sendvalue;
logic [2:0] i=0,count;
logic [WIDTH-1:0] ifmap_value;

always begin
	ifmap_in.Receive(ifmap_value);
	$display("receive ifmap_value=%b",ifmap_value);
	#FL;
	if (ifmap_count.status != idle)
	begin
		ifmap_count.Receive(count);
		#FL;
		$display("receive ifmap_addr=%d",count);
		for(i=count+1;i<=i+2;i++) 
		begin
			sendvalue=ifmap_value[i];
			ifmap_out.Send(sendvalue);	
			#BL;
		end
		if(count==1)
		begin
			to_packet.Send(ifmap_value);
		end
	end
	else
	begin
		for(i=0;i<=i+2;i++)
		begin
		sendvalue=ifmap_value[i];
		ifmap_out.Send(sendvalue);
		$display("send ifmap_value=%b, Simulation time =%t",sendvalue, $time);
		#BL;
		end
	end	
end
endmodule

module filter_mem (interface filter_in, count_out, filter_out);
parameter WIDTH=24;
parameter FL=2;
parameter BL=1;
logic [7:0] sendvalue;
logic [WIDTH-1:0] filter_value;
logic [2:0] i=0;

always begin
	filter_in.Receive(filter_value);
	$display("receive filter_value=%b",filter_value);
	#FL;
	for(i=0;i<=2;i++)
	begin
		if(i==0)
			sendvalue=filter_value[7:0];
		else if(i==1)
			sendvalue=filter_value[15:8];
		else
			sendvalue=filter_value[23:16];
		count_out.Send(i);
		filter_out.Send(sendvalue);
		$display("filter_send value %b, Simulation time =%t",sendvalue,$time);
		#BL;
	end
end
endmodule

module Multiplier (interface filter_in, ifmap_in, multi_out);
parameter WIDTH=8;
parameter FL=2;
parameter BL=1;
logic [WIDTH-1:0] filter_value;
logic ifmap_value;
logic [WIDTH-1:0] multi_out_value;

always begin
	fork
	filter_in.Receive(filter_value);
	ifmap_in.Receive(ifmap_value);
	join
	#FL;
	multi_out_value=filter_value*ifmap_value;
	$display("multi_out_value = %b ", multi_out_value);
	multi_out.Send(multi_out_value);
	#BL;
	end
endmodule

module adder(interface a0, b0, sum);
	parameter WIDTH = 8;
	parameter FL = 2;
	parameter BL = 1;
	logic [WIDTH-1:0] a=0,b=0,s=0;
	
	always begin
		b0.Receive(b);
		#FL;
	end
	always begin
		a0.Receive(a);	
		#FL;	
		s=a+b;
		$display("SumValue_S =%d. time is %t", s, $time);
		sum.Send(s);
		#BL;										
	end
endmodule

module split (interface inPort,count_sel, acc_out, pkt_out);
	parameter WIDTH = 8;
	parameter FL=2;
	parameter BL=1;
	logic [WIDTH-1:0]A;
	logic [2:0] count;
	
	always begin
		count_sel.Receive(count);
		if(count!=2)
		begin
			inPort.Receive(A);
			#FL;		
			acc_out.Send(A);
			#BL;
		end
		else
		begin
			inPort.Receive(A);
			#FL;
			pkt_out.Send(A);
			$display("sum_out%d at %t",A, $time);
			#BL;
		end
	end
endmodule

module accumulator(interface I, O);
  parameter WIDTH = 8;
  parameter FL = 2;
  parameter BL = 1;
  logic [WIDTH-1:0] token=0;
  
  initial begin
  	O.Send(0);
	$display("send accumulated value 0 at %t", $time);
	#BL;
  end
  always begin
	I.Receive(token);
	#FL;
	O.Send(token);
	$display("send accumulated value = %d", token);
	#BL;
  end
endmodule

module packetizer_PE(interface result, ifmap_in, addr_in, packet);
	parameter WIDTH=34;
	parameter WIDTH_addr=4;
	parameter WIDTH_ifmap=5;
	parameter WIDTH_filter=24;
	parameter FL=2;
	parameter BL=1;
	logic [WIDTH-1:0] packet_value;
	logic [WIDTH_filter-1:0] result_value;
	logic [WIDTH_ifmap-1:0] mapvalue;
	logic [WIDTH_addr-1:0] addr_value;
	
	always begin
		addr_in.Receive(addr_value);
		ifmap_in.Receive(mapvalue);
		#FL;
	end
	always begin
		result.Receive(result_value);
		#FL;
		if(addr_value==4'b0100)
			begin
			packet_value={addr_value,4'b0101,2'b00,{6{4'b0000}},mapvalue};
			packet.Send(packet_value);
			end
		else if(addr_value==4'b0101)
			begin
			packet_value={addr_value,4'b0001,2'b00,{6{4'b0000}},mapvalue};
			packet.Send(packet_value);
			end
		#BL;
		packet_value={addr_value,4'b0110,2'b10,{4{4'b0000}},result_value};
		packet.Send(packet_value);
		#BL;
	end	
endmodule

module data_bucket (interface r);
  parameter WIDTH = 8;
  parameter BL = 0; //ideal environment
  logic [WIDTH-1:0] ReceiveValue = 0;
  
  //Variables added for performance measurements
  real cycleCounter=0, //# of cycles = Total number of times a value is received
       timeOfReceive=0, //Simulation time of the latest Receive 
       cycleTime=0; // time difference between the last two receives
  real averageThroughput=0, averageCycleTime=0, sumOfCycleTimes=0;
  always
  begin
	$display("Start module %m and time is %d", $time);	
    //Save the simulation time when Receive starts
    timeOfReceive = $time;
	$display("Start receiving in module %m. Simulation time =%t", $time);
    r.Receive(ReceiveValue);
	$display("Finished receiving in module %m. Simulation time =%t", $time);
    #BL;
	$display("In module %m, ReceiveValue is %d", ReceiveValue);
    cycleCounter += 1;		
    //Measuring throughput: calculate the number of Receives per unit of time  
    //CycleTime stores the time it takes from the begining to the end of the always block
    cycleTime = $time - timeOfReceive;
    averageThroughput = cycleCounter/$time;
    sumOfCycleTimes += cycleTime;
    averageCycleTime = sumOfCycleTimes / cycleCounter;
    $display("Execution cycle= %d, Cycle Time= %d, 
    Average CycleTime=%f, Average Throughput=%f", cycleCounter, cycleTime, 
    averageCycleTime, averageThroughput);
	//$display("End module data_bucket and time is %d", $time);
  end
endmodule

module pe;
	 //parameter WIDTH = 8;
	 parameter DEPTH_I = 5;	
	 parameter DEPTH_F = 3;
	 Channel #(.hsProtocol(P4PhaseBD), .WIDTH(34)) intf  [14:0] (); 
	 
	 data_generator #(.FL(2)) dg(.r(intf[0]));
	 depacketizer_PE #(.FL(2), .BL(1)) dpkt(.packet(intf[0]), .out_filter(intf[1]), .out_ifmap(intf[2]), .addr_out(intf[3]), .ifmap_count(intf[4]));
	 filter_mem #(.FL(2),.BL(1)) FM (.filter_in(intf[1]),.count_out(intf[5]),.filter_out(intf[6]));
	 ifmap_mem #(.FL(2),.BL(1)) IM (.ifmap_in(intf[2]), .ifmap_count(intf[4]), .ifmap_out(intf[7]), .to_packet(intf[8]));
	 Multiplier #(.FL(2), .BL(1)) mul(.filter_in(intf[6]), .ifmap_in(intf[7]), .multi_out(intf[9]));
	 adder 	    #(.FL(2), .BL(1)) add(.a0(intf[9]), .b0(intf[10]), .sum(intf[11]));
	 split      #(.FL(2), .BL(1)) spl(.inPort(intf[11]), .count_sel(intf[5]), .acc_out(intf[12]), .pkt_out(intf[13]));
	 accumulator #(.FL(2),.BL(1)) acc (.I(intf[12]), .O(intf[10]));
	 packetizer_PE #(.FL(2), .BL(1)) pkt(.result(intf[13]), .ifmap_in(intf[8]), .addr_in(intf[3]), .packet(intf[14]));
	 data_bucket #(.BL(1)) db(.r(intf[14]));
	 initial 
		#300 $stop;
endmodule
