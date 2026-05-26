module traffic_controller(input logic [1:0] detector,
                          input logic       clk,
                          input logic       rst,
                          output logic      highway_light,
                          output logic      farmland_light,
                          output logic      timer_light);

   typedef enum logic [1:0] {s0, s1, s2, s3} state_t;
   parameter    TIMER = 2'd3;

   logic [1:0] highway_timer, farmland_timer;
   logic [1:0] next_highway_timer, next_farmland_timer;
   state_t present_state, next_state;

   initial begin
      present_state = s0;
      highway_timer = 2'b0;
      farmland_timer = 2'b0;
   end

   always_ff @(posedge clk) begin
      if (rst) begin
         present_state       <= s0;
         highway_timer       <= '0;
         farmland_timer      <= '0;
      end
      else begin
         present_state <= next_state;
         highway_timer <= next_highway_timer;
         farmland_timer <= next_farmland_timer;
      end
   end // always_ff @ (posedge clk)

   always_comb begin
      next_state         = present_state;
      next_highway_timer = highway_timer;
      next_farmland_timer = farmland_timer;
      timer_light        = 1'b0;
      highway_light      = 1'b0;
      farmland_light     = 1'b0;

      case (present_state)

        s0: begin
           timer_light = 1'b0;
           if (detector == 2'b10) begin
              next_state = s1;
              next_highway_timer = 2'b0;
              next_farmland_timer = 2'b0;
           end
           else
             next_state = s0;

           highway_light = 1'b1;
           farmland_light = 1'b0;
        end

        s1: begin
           timer_light = 1'b0;
           if ((detector[0] == 0) && (highway_timer == TIMER))
             next_state = s2;
           else if ((detector[0] == 1) && (highway_timer <= TIMER))
             next_state = s0;
           else if ((detector[0] == 0) && (highway_timer < TIMER)) begin
              next_state = s1;
              next_highway_timer = highway_timer + 1'b1;
              timer_light = 1'b1;
           end

           highway_light = 1'b1;
           farmland_light = 1'b0;
        end

        s2: begin
           timer_light = 1'b0;
           if (detector[1] == 0)
             next_state = s3;
           else
             next_state = s2;

           highway_light = 1'b0;
           farmland_light = 1'b1;
        end

        s3: begin
           timer_light = 1'b0;
           if ((detector[1] == 0) && farmland_timer < TIMER) begin
              next_state = s3;
              next_farmland_timer = farmland_timer + 1'b1;
              timer_light = 1'b1;
           end
           else if ((detector[0] == 1) && farmland_timer == TIMER)
             next_state = s0;
           else if((detector[1] == 1) && farmland_timer < TIMER)
             next_state = s2;

           highway_light = 1'b0;
           farmland_light = 1'b1;
        end // case: s3

        default: next_state = s0;
      endcase // case (present_state)

   end // always_comb

endmodule // traffic_controller
