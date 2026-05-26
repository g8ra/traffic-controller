module testbench;
   logic [1:0] detector;
   logic       clk;
   logic       rst;
   logic       highway_light;
   logic       farmland_light;
   logic       timer_light;
   traffic_controller uut (.detector      (detector),
                           .clk           (clk),
                           .rst           (rst),
                           .highway_light (highway_light),
                           .farmland_light(farmland_light),
                           .timer_light   (timer_light));

   initial begin
      clk = 0;
      forever #5 clk = ~clk;
   end

   initial begin
      detector = 2'b00;
      rst      = 1'b1;
      repeat (2) @(posedge clk);
      rst      = 1'b0;

      // TC1: s0 -> s1 request
      detector = 2'b10;
      @(posedge clk);

      // TC2: stay in s1 and increment highway timer (detector[0] must be 0)
      repeat (4) @(posedge clk);

      // TC3: s1 -> s2 when timer reaches TIMER
      detector = 2'b00;
      @(posedge clk);

      // TC4: stay in s2 (detector[1] == 1)
      detector = 2'b10;
      repeat (2) @(posedge clk);

      // TC5: s2 -> s3 (detector[1] == 0)
      detector = 2'b00;
      @(posedge clk);

      // TC6: hold in s3 and increment farmland timer to TIMER
      repeat (4) @(posedge clk);

      // TC7: s3 -> s0 requires detector[0] == 1 and timer full
      detector = 2'b01;
      @(posedge clk);

      // TC8: demonstrate s3 -> s2 when timer is not full and detector[1] == 1
      detector = 2'b00; // move to s3 and start timer from 0
      @(posedge clk);
      repeat (2) @(posedge clk); // partial count (< TIMER)
      detector = 2'b10; // detector[1] == 1
      @(posedge clk);

      repeat (5) @(posedge clk);
      $finish;
   end

   always @(posedge clk) begin
      $display("t=%0t det=%b hw=%b fm=%b tm=%b",
               $time, detector, highway_light, farmland_light, timer_light);
   end

endmodule // testbench
