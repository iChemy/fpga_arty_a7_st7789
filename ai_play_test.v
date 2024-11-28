// `include "config.vh"
// `include "game_tree_v2.v"
`include "ai_play.v"

module tb_m_ai_play;
    // Parameters
    reg w_clk = 0;
    reg w_rst = 1;
    reg [3:0] w_user_input = 0;

    wire [`COL_SIZE-1:0] o_selecting_col;
    wire [`FIELD_SIZE-1:0] o_your_field;
    wire [`FIELD_SIZE-1:0] o_ai_field;

    // Instantiate the m_ai_play module
    m_ai_play uut (
        .w_clk(w_clk),
        .w_rst(w_rst),
        .w_user_input(w_user_input),
        .o_selecting_col(o_selecting_col),
        .o_your_field(o_your_field),
        .o_ai_field(o_ai_field)
    );

    // Clock generation
    always #5 w_clk = ~w_clk; // 10 ns clock period

    // Simulation process
    initial begin
        // Monitor signals
        $monitor("Time: %d, State: %b, Selecting Column: %d, Your Field: %b, AI Field: %b",
                 $time, uut.r_state, o_selecting_col, o_your_field, o_ai_field);

        // Reset the design
        w_rst = 1;
        #20;
        w_rst = 0;

        // Simulate user turn: Increment column selection
        w_user_input = 4'b0001; // USER_INPUT_INC
        #20;
        w_user_input = 0;

        // Simulate user turn: Decrement column selection
        w_user_input = 4'b0010; // USER_INPUT_DEC
        #20;
        w_user_input = 0;

        // Simulate user turn: Confirm column selection
        w_user_input = 4'b0100; // USER_INPUT_OK
        #20;
        w_user_input = 0;

        // Wait for AI turn to complete
        #10000;

        // End simulation
        $finish;
    end
endmodule
