`timescale 1ns/1fs
import SystemVerilogCSP::*;
module data_bucket (interface r);
  parameter WIDTH = 12;
  parameter BL = 2; //ideal environment
  logic [WIDTH-1:0] ReceiveValue = 0;
  logic [3:0] Value;
  
  //Variables added for performance measurements
  real cycleCounter=0, //# of cycles = Total number of times a value is received
       timeOfReceive=0, //Simulation time of the latest Receive 
       cycleTime=0; // time difference between the last two receives
  real averageThroughput=0, averageCycleTime=0, sumOfCycleTimes=0;
  always
  begin
	//$display("START module data_bucket and time is %d", $time);	
    //Save the simulation time when Receive starts
    timeOfReceive = $time;
    r.Receive(ReceiveValue);
	//value=ReceiveValue[];
	//$display("ReceiveValue is %d",ReceiveValue);
	//$display("ReceiveTime is %d",timeOfReceive);
    #BL;
    cycleCounter += 1;		
    //Measuring throughput: calculate the number of Receives per unit of time  
    //CycleTime stores the time it takes from the begining to the end of the always block
    
	/***cycleTime = $time - timeOfReceive;
    averageThroughput = cycleCounter/$time;
    sumOfCycleTimes += cycleTime;
    averageCycleTime = sumOfCycleTimes / cycleCounter;
    $display("Execution cycle= %d, Cycle Time= %d, 
    Average CycleTime=%f, Average Throughput=%f", cycleCounter, cycleTime, 
    averageCycleTime, averageThroughput);***/
	
	//$display("End module data_bucket and time is %d", $time);
  end

endmodule