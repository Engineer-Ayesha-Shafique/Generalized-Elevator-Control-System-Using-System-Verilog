module Lift8_Tb();
  logic clk, reset;
  logic [2:0] req_floor;
  logic [1:0] idle, door, Up, Down;
  logic [2:0] current_floor;
  logic [2:0] max_request, min_request;
  logic [7:0] requests;
  logic emergency_stop;

  Lift8 dut(
    .clk(clk),
    .reset(reset),
    .req_floor(req_floor),
    .idle(idle),
    .door(door),
    .Up(Up),
    .Down(Down),
    .current_floor(current_floor),
    .max_request(max_request),
    .min_request(min_request),
    .requests(requests),
    .emergency_stop(emergency_stop)
  );

  initial begin
    $dumpfile("waveform.vcd"); // Specify the VCD waveform output file
    $dumpvars(0, Lift8_Tb);    // Dump all variables in the module hierarchy

    clk = 1'b0;
    emergency_stop = 0;
    reset = 1;
    #10;
    reset = 0;
    req_floor = 1;
    #30;
    req_floor = 4;
    
    #10
    
    // Simulate elevator operation
    req_floor = 3; // Request floor 3
    #20;
    req_floor = 7; // Request floor 5
    #20;
    emergency_stop = 1; // Activate emergency stop
    #20;
    emergency_stop = 0; // Deactivate emergency stop
    #10;
    req_floor = 2; // Request floor 2
    #40;
    req_floor = 6; // Request floor 6
    #20;
    
    #20;
    req_floor = 1;
  end

  initial begin
  $display("Starting simulation...");
    $monitor("Time=%t,clk=%b,reset=%b,req_floor=%h,idle=%h,door=%h,Up=%h,Down=%h,current_floor=%h,max_request=%h,min_request=%h,requests=%h",
    $time, clk, reset, req_floor, idle, door, Up, Down, current_floor, max_request, min_request, requests);
  // Run the simulation for a sufficient duration
  #305; // Adjust the simulation time as needed
  $display("Simulation finished.");
  $finish;
end

// C
  always #5 clk = ~clk;
endmodule

