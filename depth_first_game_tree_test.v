`include "config.vh"
`include "depth_first_game_tree.v"

module m_tb_m_depth_first_game_tree ();
    reg r_clk = 0, r_rst = 1;

    initial forever #5 r_clk <= ~r_clk;


    reg [`FIELD_SIZE-1:0] r_me_field = {7'b0000000,
                                        7'b0000000,
                                        7'b0000000,
                                        7'b0000000,
                                        7'b0000000,
                                        7'b0000100};

    reg [`FIELD_SIZE-1:0] r_op_field = {7'b0000000,
                                        7'b0000000,
                                        7'b0000000,
                                        7'b0000000,
                                        7'b0001000,
                                        7'b0001000};
    reg [`PILE_COUNT_ARRAY_SIZE-1:0] r_pile_count_array = {
        3'd0, 3'd0, 3'd0, 3'd2, 3'd1, 3'd0, 3'd0
    };

    wire w_fin;
    wire signed [15:0] w_score;
    wire [`COL_SIZE-1:0] w_col;
    reg [31:0] r_cycles = 0, r_searched_cyecles;
    reg r_en = 1;

    m_depth_first_game_tree #(
        .DEPTH(4),
        .IS_ME(1'b1)
    ) dfgt (
        .w_clk(r_clk),

        .i_en(r_en),

        .i_me_field(r_me_field),
        .i_op_field(r_op_field),
        .i_pile_count_array(r_pile_count_array),

        .o_fin(w_fin),
        .o_score(w_score),
        .o_col(w_col)
    );

    reg signed [15:0] r_score = 0;
    reg [`COL_SIZE-1:0] r_col = 0;

    initial begin
        $monitor("cycles: %d; score: %d; col: %d", r_searched_cyecles,  w_score, w_col);
    end

    always @(posedge r_clk) begin
        r_cycles <= r_cycles + 1;
        if (w_fin) begin
            // r_rst <= 1;
            r_score <= w_score;
            r_col <= w_col;
            r_searched_cyecles <= r_cycles;

            r_en <= 0;
        end
    end

    initial begin
        #10000000 $finish;
    end
endmodule