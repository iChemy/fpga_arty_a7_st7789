`include "config.vh"
`include "game_tree_v2.v"


module tb_m_game_tree ();
    reg r_clk = 0;
    reg r_rst = 1;
    initial forever #50 r_clk = ~r_clk;

    reg [`FIELD_SIZE-1:0] r_me_field = {
        7'b0000000, 
        7'b0000000,
        7'b0000000,
        7'b0000000,
        7'b0000001,
        7'b0000001};
    reg [`FIELD_SIZE-1:0] r_op_field = {
        7'b0000000, 
        7'b0000000,
        7'b0000000,
        7'b0000010,
        7'b0000010,
        7'b0000010};

    reg [`PILED_COUNT_ARRAY_SIZE-1:0] r_piled_array = {
        3'd0, 3'd0, 3'd0, 3'd0, 3'd0, 3'd3, 3'd2
    };

    wire w_valid, w_finished;
    wire signed [15:0] w_score;
    wire [`COL_SIZE-1:0] w_selected_col;

    reg [`COL_SIZE-1:0] r_selected_col;
    reg signed [15:0] r_score;

    m_game_tree_v2 # (
        .IS_ME(1),
        .DEPTH(3)
    )
    gt (
        .w_clk(r_clk),
        .w_rst(r_rst),
        .w_en(1'b1),

        .i_me_field(r_me_field),
        .i_op_field(r_op_field),
        .i_piled_array(r_piled_array),

        .o_valid(w_valid),
        .o_finished(w_finished),
        .o_score(w_score),
        .o_selected_col(w_selected_col)
    );

    always @(posedge r_clk) begin
        
        if (w_finished & w_valid) begin
            r_selected_col <= w_selected_col;
            r_score <= w_score;
            r_rst <= 1;
        end else begin
            r_rst <= 0;
        end
    end

    initial begin
        $monitor("finished: %b |col: %d | score: %d", w_finished, r_selected_col, r_score);
        #1000000 $finish;
    end
endmodule