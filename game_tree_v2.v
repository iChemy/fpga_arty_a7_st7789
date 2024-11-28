`include "config.vh"
// `include "seaquence_checker.v"
`include "evaluator.v"
`include "piler.v"

module m_game_tree_v2 # (
    parameter IS_ME = 1'b1,

    // 何世代の子孫を下に持つか, 0なら葉
    parameter DEPTH = 0
)
(
    input wire w_clk,
    input wire w_rst,
    input wire w_en,

    input wire [`FIELD_SIZE-1:0] i_me_field,
    input wire [`FIELD_SIZE-1:0] i_op_field,
    input wire [`PILED_COUNT_ARRAY_SIZE-1:0] i_piled_array,

    output reg o_valid = 0,
    output reg o_finished = 0,
    output reg signed [15:0] o_score = 0,
    output reg [`COL_SIZE-1:0] o_selected_col = 0
);
    generate
        if (DEPTH == 0) begin :gen_depth0
            wire signed [15:0] w_score; 

            m_evaluator ev(
                .i_me_field((w_en) ? i_me_field : 0),
                .i_opposite_field((w_en) ? i_op_field : 0),
                .o_score(w_score)
            );

            always @(posedge w_clk) begin
                if (w_rst || o_finished) begin
                    o_valid <= 0;
                    o_finished <= 0;
                    o_score <= 0;
                    o_selected_col <= 0;
                end else if (w_en) begin
                    o_valid <= 1;
                    o_finished <= 1;
                    o_score <= w_score;
                    o_selected_col <= 0;
                end
            end
        end else begin :gen_parent
            reg r_me_working = 0;
            reg [`COL_SIZE-1:0] r_selected_col = 0;
            always @(posedge w_clk) begin
                if (w_rst) begin
                    r_me_working <= 0;
                    r_selected_col <= 0;
                end

                if (w_en) begin
                    r_me_working <= 1;
                end
            end

            reg [`FIELD_SIZE-1:0] r_me_field = 0, r_op_field = 0;
            reg [`PILED_COUNT_ARRAY_SIZE-1:0] r_piled_array = 0;
            always @(posedge w_clk) begin
                if (r_me_working) begin
                    r_me_field <= i_me_field;
                    r_op_field <= i_op_field;
                    r_piled_array <= i_piled_array;
                end
                if (w_rst) begin
                    r_me_field <= 0;
                    r_op_field <= 0;
                    r_piled_array <= 0;
                    r_child_en <= 0;
                end
            end

            wire [`FIELD_SIZE-1:0] w_me_field_next, w_op_field_next;
            wire [`PILED_COUNT_ARRAY_SIZE-1:0] w_piled_array_next;
            wire w_pile_simu_valid, w_game_set;
            if (IS_ME) begin
                assign w_op_field_next = r_op_field;
                m_piler p_me (
                    .i_field(r_me_field),
                    .i_piled_count_array(r_piled_array),
                    .i_piled_col(r_selected_col),

                    .o_valid(w_pile_simu_valid),
                    .o_piled_field(w_me_field_next),
                    .o_piled_count_array(w_piled_array_next)
                );

                m_seaquence_checker s_op (
                    .i_field(r_op_field),

                    .o_detected(w_game_set)
                );
            end else begin
                assign w_me_field_next = r_me_field;
                m_piler p_op (
                    .i_field(r_op_field),
                    .i_piled_count_array(r_piled_array),
                    .i_piled_col(r_selected_col),

                    .o_valid(w_pile_simu_valid),
                    .o_piled_field(w_op_field_next),
                    .o_piled_count_array(w_piled_array_next)
                );

                m_seaquence_checker s_me (
                    .i_field(r_me_field),

                    .o_detected(w_game_set)
                );
            end

            reg r_child_en = 0;
            wire w_child_valid, w_child_finished;
            wire signed [15:0] w_child_score;
            m_game_tree_v2 #(
                .IS_ME(~IS_ME),
                .DEPTH(DEPTH-1)
            ) gt (
                .w_clk(w_clk),
                .w_rst(w_rst),
                .w_en(r_child_en),
                
                .i_me_field(w_me_field_next),
                .i_op_field(w_op_field_next),
                .i_piled_array(w_piled_array_next),

                .o_valid(w_child_valid),
                .o_finished(w_child_finished),
                .o_score(w_child_score),
                .o_selected_col()
            );

            reg r_settlement_checked = 0;
            reg signed [15:0] r_res_score = (IS_ME) ? {1'b1, {15{1'b0}}} : {1'b0, {15{1'b1}}};
            reg [`COL_SIZE-1:0] r_res_col = 0;
            always @(posedge w_clk) begin
                if (w_rst || o_finished) begin
                    r_settlement_checked <= 0;
                    r_res_score <= (IS_ME) ? {1'b1, {15{1'b0}}} : {1'b0, {15{1'b1}}};
                    r_child_en <= 0;
                    r_res_col <= 0;

                    o_valid <= 0;
                    o_finished <= 0;
                    o_selected_col <= 0;
                    o_score <= 0;

                    r_me_working <= 0;
                    r_selected_col <= 0;
                end else if (r_me_working & !r_settlement_checked) begin
                    if (w_game_set) begin
                        if (IS_ME) begin
                            o_valid <= 1;
                            o_finished <= 1;
                            o_score <= {1'b0, {15{1'b1}}};
                            o_selected_col <= 0;

                            r_me_working <= 0;
                        end else begin
                            o_valid <= 1;
                            o_finished <= 1;
                            o_score <= {1'b1, {15{1'b0}}};
                            o_selected_col <= 0;

                            r_me_working <= 0;                               
                        end
                    end
                    r_settlement_checked <= 1;
                end else if (r_me_working & r_settlement_checked & !o_finished) begin
                    if (r_child_en) begin
                        if (!w_pile_simu_valid) begin
                            r_child_en <= 0;
                            r_selected_col <= r_selected_col+1;
                        end else if (w_child_valid & w_child_finished) begin
                            if (IS_ME) begin
                                if (r_res_score < w_child_score) begin
                                    r_res_score <= w_child_score;
                                    r_res_col <= r_selected_col;
                                end
                            end else begin
                                if (r_res_score > w_child_score) begin
                                    r_res_score <= w_child_score;
                                    r_res_col <= r_selected_col;
                                end
                            end
                            r_child_en <= 0;
                            r_selected_col <= r_selected_col+1;
                        end
                    end else if (r_selected_col != 7 & !r_child_en) begin
                        r_child_en <= 1;
                    end else if (r_selected_col == 7) begin
                        r_child_en <= 0;
                        o_valid <= 1;
                        o_finished <= 1;
                        o_score <= r_res_score;
                        o_selected_col <= r_res_col; 

                        r_me_working <= 0;
                        r_settlement_checked <= 0;
                    end
                end
            end
            initial begin
                $monitor("%b %d %d", r_me_working, o_score, r_res_score);
            end
        end
    endgenerate
    
endmodule