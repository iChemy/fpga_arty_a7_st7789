
`include "config.vh"
`include "manual_play.v"

module tb_m_manual_play();
    reg r_clk = 0;
    reg r_rst = 0;
    reg [1:0] r_user_input = 2'b00;

    wire [`FIELD_SIZE-1:0] w_red_field;
    wire [`FIELD_SIZE-1:0] w_blue_field;

    // DUT (Device Under Test)
    m_manual_play uut (
        .w_clk(r_clk),
        .w_rst(r_rst),
        .w_user_input(r_user_input),
        .o_red_field(w_red_field),
        .o_blue_field(w_blue_field)
    );

    // Clock generation
    always #5 r_clk = ~r_clk; // 100MHz clock (10ns period)

    initial begin
        $monitor("Time: %0t | Red Field: %b | Blue Field: %b | State: %b | User Input: %b", 
                  $time, w_red_field, w_blue_field, uut.state, r_user_input);

        // Reset sequence
        r_rst = 1;
        #20 r_rst = 0;

        // Test: Increment column selection
        r_user_input = 2'b00; // USER_INPUT_INC
        #10 r_user_input = 2'b10; // USER_INPUT_OK (Transition to RED_PILING)
        #10 r_user_input = 2'b00; // USER_INPUT_INC (to simulate new interaction)
        
        // Wait for RED_PILING to complete
        #50;

        // Test: Decrement column selection for Blue Turn
        r_user_input = 2'b01; // USER_INPUT_DEC
        #10 r_user_input = 2'b10; // USER_INPUT_OK (Transition to BLUE_PILING)

        // Wait for BLUE_PILING to complete
        #50;

        // Finish simulation
        $finish;
    end
endmodule