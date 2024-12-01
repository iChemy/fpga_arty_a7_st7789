`include "config.vh"
`include "evaluation_func.v"
`include "piler.v"

`default_nettype none

// 深さ優先探索によるゲーム木の探索 (minmax)
module m_depth_first_game_tree #(
    // 自分が持っている子孫の世代数 (0なら葉)
    parameter [7:0] DEPTH = 4,
    parameter [0:0] IS_ME = 1
)
(
    input wire w_clk,

    input wire i_en,
    input wire [`FIELD_SIZE-1:0] i_me_field,
    input wire [`FIELD_SIZE-1:0] i_op_field,
    input wire [`PILE_COUNT_ARRAY_SIZE-1:0] i_pile_count_array,

    output reg o_fin = 0,
    output reg signed [15:0] o_score = 0,
    output reg [`COL_SIZE-1:0] o_col = 0
);
    
    generate
        if (DEPTH == 0) begin
            localparam [1:0] LEAF_READY = 2'b00;
            localparam [1:0] LEAF_START_WORK = 2'b01;
            localparam [1:0] LEAF_END_WORK = 2'b10;

            reg [1:0] r_leaf_state = LEAF_READY;


            reg [`FIELD_SIZE-1:0] r_leaf_me_field, r_leaf_op_field;
            wire signed [15:0] w_leaf_score;
            m_evaluation_func ef (
                .i_me_field(r_leaf_me_field),
                .i_op_field(r_leaf_op_field),
                .o_score(w_leaf_score)
            );

            initial begin
                $monitor("IS_ME: %b, me: %b, op: %b", IS_ME, r_leaf_me_field, r_leaf_op_field);
            end

            always @(posedge w_clk) begin
                casex ({i_en, r_leaf_state})
                    {1'b1, LEAF_READY}: begin
                        r_leaf_state <= LEAF_START_WORK;
                        r_leaf_me_field <= i_me_field;
                        r_leaf_op_field <= i_op_field;

                        o_fin <= 0;
                    end

                    {1'b1, LEAF_START_WORK}: begin
                        o_fin <= 1;
                        o_score <= w_leaf_score;

                        r_leaf_state <= LEAF_END_WORK;
                    end
                    default: begin
                        o_fin <= 0;

                        r_leaf_state <= LEAF_READY;
                    end
                endcase
            end
        end else begin
            localparam [2:0] NODE_READY = 3'b000;
            localparam [2:0] NODE_SELF_CHECK = 3'b001; // 自分が子供を持たない (終了の盤面の可能性を考慮する)
            localparam [2:0] NODE_GENERATE_CHILD = 3'b010;
            localparam [2:0] NODE_WAIT_CHILD_RES =3'b100;
            localparam [2:0] NODE_END_WORK = 3'b101;

            reg [2:0] r_node_state = NODE_READY;

            reg [`FIELD_SIZE-1:0] r_node_me_field, r_node_op_field;
            reg [`PILE_COUNT_ARRAY_SIZE-1:0] r_node_pile_count_array;

            wire w_node_win_detected;
            wire [`FIELD_SIZE-1:0] w_node_win_checked_field;
            assign w_node_win_checked_field = (IS_ME) ? r_node_op_field : r_node_me_field;

            m_winning_detector wd(
                .i_field(w_node_win_checked_field),
                .o_detected(w_node_win_detected)
            );

            reg [`COL_SIZE-1:0] r_node_target_child_col = 0;
            reg [`FIELD_SIZE-1:0] r_node_generated_child_field = 0;
            reg [`PILE_COUNT_ARRAY_SIZE-1:0] r_node_generated_child_array = 0;
            wire [`FIELD_SIZE-1:0] w_node_target_field, w_node_child_field;
            wire [`PILE_COUNT_ARRAY_SIZE-1:0] w_node_child_pile_count_array;
            // 私の手番なら私の盤面にpileされて欲しいので
            assign w_node_target_field = (IS_ME) ? r_node_me_field : r_node_op_field;
            wire w_node_child_valid;
            m_piler p (
                .i_field(w_node_target_field),
                .i_pile_count_array(r_node_pile_count_array),
                .i_pile_col(r_node_target_child_col),

                .o_valid(w_node_child_valid),
                .o_field(w_node_child_field),
                .o_pile_count_array(w_node_child_pile_count_array)
            );

            reg signed [15:0] r_node_child_score;
            reg [`COL_SIZE-1:0] r_node_child_col;

            reg r_node_child_node_en = 0;

            wire [`FIELD_SIZE-1:0] w_node_child_me_field, w_node_child_op_field;
            assign w_node_child_me_field = (!IS_ME) ? r_node_me_field : r_node_generated_child_field;
            assign w_node_child_op_field = (IS_ME) ? r_node_op_field : r_node_generated_child_field;
            wire w_node_child_fin;
            wire signed [15:0] w_node_child_score;

            m_depth_first_game_tree #(
                .DEPTH(DEPTH-1),
                .IS_ME(~IS_ME)
            ) dfgt_child (
                .w_clk(w_clk),

                .i_en(r_node_child_node_en),
                .i_me_field(w_node_child_me_field),
                .i_op_field(w_node_child_op_field),
                .i_pile_count_array(r_node_generated_child_array),

                .o_fin(w_node_child_fin),
                .o_score(w_node_child_score),
                .o_col()
            );
            always @(posedge w_clk) begin
                casex ({i_en, r_node_state})
                    {1'b1, NODE_READY}: begin
                        r_node_me_field <= i_me_field; r_node_op_field <= i_op_field;
                        r_node_pile_count_array <= i_pile_count_array;
                        o_fin <= 0;

                        r_node_state <= NODE_SELF_CHECK;
                    end

                    {1'b1, NODE_SELF_CHECK}: begin
                        if (w_node_win_detected) begin // 子供は持ってない
                            // IS_ME のとき敵が勝っていたということ
                            // !IS_ME のとき自分が勝っていたということ
                            o_score <= (IS_ME) ? {1'b1, 15'd0} : {1'b0, {15{1'b1}}};
                            o_fin <= 1;
                            r_node_state <= NODE_END_WORK;
                        end else begin
                            // 子供を持つとわかった時点で列同士を比較するための初期値設定が必要
                            r_node_target_child_col <= 0;
                            r_node_child_col <= 0;
                            r_node_child_score <= (IS_ME) ? {1'b1, 15'd0} : {1'b0, {15{1'b1}}};

                            r_node_state <= NODE_GENERATE_CHILD;
                        end
                    end

                    {1'b1, NODE_GENERATE_CHILD}: begin
                        if (r_node_target_child_col >= 7) begin 
                            // 8列目に積もうとした結果が返ってくるということ
                            // すでに7列目までの結果は保持しているので o_fin フラグを立てて処理するべき

                            o_fin <= 1;
                            o_score <= r_node_child_score;
                            o_col <= r_node_child_col;
                        end else if (w_node_child_valid) begin
                            r_node_generated_child_field <= w_node_child_field;
                            r_node_generated_child_array <= w_node_child_pile_count_array;

                            r_node_child_node_en <= 1;
                            r_node_state <= NODE_WAIT_CHILD_RES;
                        end else begin // 列が満杯で積めなかったということその場合次にいく
                            r_node_target_child_col <= r_node_target_child_col + 1;
                        end
                    end

                    {1'b1, NODE_WAIT_CHILD_RES}: begin
                        if (w_node_child_fin) begin
                            if (IS_ME) begin
                                if (r_node_child_score < w_node_child_score) begin
                                    r_node_child_score <=  w_node_child_score;
                                    r_node_child_col <= r_node_target_child_col;
                                end
                            end else begin
                                if (r_node_child_score > w_node_child_score) begin
                                    r_node_child_score <=  w_node_child_score;
                                    r_node_child_col <= r_node_target_child_col;
                                end
                            end

                            r_node_target_child_col <= r_node_target_child_col + 1;
                            r_node_child_node_en <= 0; // 一旦用済み
                            r_node_state <= NODE_GENERATE_CHILD;
                        end
                    end

                    default: begin //{1'bx, NODE_END_WORK} {1'b0, 3'bxxx}
                        r_node_state <= NODE_READY;
                        o_fin <= 0;
                    end
                endcase
            end
            initial begin
                // $monitor("State: %b, o_fin: %b, i_en: %b, r_node_target_child_col: %d, w_node_child_valid: %b, r_node_child_col: %d, r_node_child_score: %d, w_node_child_score: %d",
                //         r_node_state, o_fin, i_en, r_node_target_child_col, w_node_child_valid, r_node_child_col, r_node_child_score, w_node_child_score);
                // $monitor("DEPTH: %d, state: %b, gen_c: %b, gen_arr: %o", DEPTH, r_node_state, r_node_generated_child_field, r_node_generated_child_array);
            end
        end
    endgenerate
endmodule