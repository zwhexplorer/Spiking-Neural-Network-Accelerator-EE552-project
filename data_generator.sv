`timescale 1ns/1fs
import SystemVerilogCSP::*;
module data_generator (interface r);
  parameter WIDTH = 34;
  parameter FL = 2; //ideal environment
  parameter MAX=50;
  logic [33:0] SendValue;
  logic [15:0] zeros=0000_0000_0000_0000;
  //always
  initial
  begin 
    //add a display here to see when this module starts its main loop
    //$display("START_data_gen_time %m %d",$time);
    //SendValue = {$random()} % MAX;
	//SendValue={1000_0100,10,{16{1'b0}},0001_0011};//19---PE1
	SendValue={8'b1000_0100,2'b10,{16{1'b0}},8'b0001_0011};//19---PE1
	#FL;
	r.Send(SendValue);
	//$display("Send Value%d",SendValue);
	SendValue={8'b1001_0100,2'b10,{16{1'b0}},8'b0000_1100};//12---PE2
	#FL;
	r.Send(SendValue);	
	//SendValue={8'b1010_0100,2'b10,{16{1'b0}},8'b0001_1101};//29---PE3
	SendValue={8'b1010_0100,2'b10,{16{1'b0}},8'b0010_0111};//39---PE3
	#FL;
	r.Send(SendValue);
	
	//SendValue=48;
    

    //Communication action Send is about to start
   // $display("Starting %m.Send @ %d", $time);

    //Communication action Send is finished
   // $display("Finished %m.Send @ %d", $time);
	SendValue={8'b1000_0100,2'b10,{16{1'b0}},8'b0001_0011};//19---PE1
	#FL;
	r.Send(SendValue);
	//$display("Send Value%d",SendValue);
	SendValue={8'b1001_0100,2'b10,{16{1'b0}},8'b0001_0011};//19---PE2
	#FL;
	r.Send(SendValue);	
	SendValue={8'b1010_0100,2'b10,{16{1'b0}},8'b0000_1001};//9---PE3
	#FL;
	r.Send(SendValue);  

	SendValue={8'b1000_0100,2'b10,{16{1'b0}},8'b0001_1011};//27---PE1
	#FL;
	r.Send(SendValue);
	//$display("Send Value%d",SendValue);
	SendValue={8'b1001_0100,2'b10,{16{1'b0}},8'b0000_1000};//8---PE2
	#FL;
	r.Send(SendValue);	
	SendValue={8'b1010_0100,2'b10,{16{1'b0}},8'b0000_0000};//0---PE3
	#FL;
	r.Send(SendValue);	
  end
endmodule