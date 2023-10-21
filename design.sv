module Lift8(clk, reset, req_floor, idle, door, Up, Down, current_floor, requests, max_request, min_request, emergency_stop);

  input clk, reset, emergency_stop;
  input logic [2:0] req_floor;      // 3-bit input for 8 floors (0 to 7)
  output logic [1:0] door;
  output logic [2:0] max_request;
  output logic [2:0] min_request;
  output logic [1:0] Up;
  output logic [1:0] Down;
  output logic [1:0] idle;
  output logic [2:0] current_floor;
  output logic [7:0] requests;

  logic door_timer;
  logic emergency_stopped;
  logic flag=0;

  // Update requests when a new floor is requested
  always @(req_floor)
  begin
    requests[req_floor] = 1;
  // Update max_request and min_request based on requested floors
    if (max_request < req_floor)
    begin
      max_request = req_floor;
    end
    
    if (min_request > req_floor)
    begin
      min_request = req_floor;
    end
    
      // Update max_request and min_request based on current floor
    
    if (requests[max_request] == 0 && req_floor > current_floor)
    begin
      max_request = req_floor;
    end
    
    if (requests[min_request] == 0 && req_floor < current_floor)
    begin
      min_request = req_floor;
    end
    
  end

  // Check and update lift behavior based on current floor
  always @(current_floor )
  begin
    if (requests[current_floor] == 1)
    begin
      idle = 1;
      door = 1;
      requests[current_floor] = 0;
      door_timer = 1; // Start the door timer when opening
    end
  end

  // State machine for lift control
  always @(posedge clk )

  begin     
    if (door_timer == 1)
    begin
      door <= 0; // Close the door after the one clock expires
      //$display("%h", current_floor);
    end
    if (reset)
    begin
      // Reset lift to initial state
      flag=0;
      current_floor <= 0;
      idle <= 0;
      door <= 0; // door open
      Up <= 1;   // going up
      Down <= 0; // not going down
      max_request <= 0;
      min_request <= 7;
      requests <= 0;
      emergency_stopped <= 0; // Initialize emergency stop state
    end
    else if (requests == 0 && !reset)
    begin
      // Stay on the current floor if no requests
      current_floor <= current_floor;
      emergency_stopped <= 0; // Clear emergency stop when not moving
    end
    // emergency
    else if (emergency_stop)
    begin
      // Emergency stop button is turned on
      idle <= 1;
      flag <=1;
      emergency_stopped <= 1; // Set emergency stop state
    end
    else if (emergency_stopped && emergency_stop)
    begin
      // Remain stopped until the emergency stop button is reset
      current_floor <= current_floor;
      door <= 0; // Keep the door closed during an emergency stop
    end
    // emergency reset
    else if (!emergency_stop && flag)
    begin
      // Emergency stop button is turned off
      emergency_stopped <= 0; // Set emergency stop state
      flag <=0;
    end
    else
    begin
      // Normal operation when not in emergency stop
      if (max_request <= 7)
      begin
        if (min_request < current_floor && Down == 1)
        begin
          // Move down one floor
          current_floor <= current_floor - 1;
          door <= 0;
          idle <= 0;
        end
        else if (max_request > current_floor && Up == 1)
        begin
          // Move up one floor
          current_floor <= current_floor + 1;
          door <= 0;
          idle <= 0;
        end
        else if (req_floor == current_floor)
        begin
//             // Open door and handle request
            door <= 1;
            idle <= 1;
        end
        else if (max_request == current_floor)
        begin
          Up <= 0;
          Down <= 1;
        end
        else if (min_request == current_floor)
        begin
          Up <= 1;
          Down <= 0;
        end
      end
    end
  end
endmodule
