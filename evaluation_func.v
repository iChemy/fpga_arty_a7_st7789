`include "config.vh"
`include "count_ones.v"
`include "winning_detector.v"


// 評価関数
module m_evaluation_func (
    input wire [`FIELD_SIZE-1:0] i_me_field,
    input wire [`FIELD_SIZE-1:0] i_op_field,

    output wire signed [15:0] o_score
);

    wire w_is_me_win, w_is_op_win;

    m_winning_detector wd0(
        .i_field(i_me_field),
        .o_detected(w_is_me_win)
    );
    m_winning_detector wd1(
        .i_field(i_op_field),
        .o_detected(w_is_op_win)
    );

    wire [7:0] w_score_for_me, w_score_for_op;

    m_evaluate_oneside me(
        .i_field(i_op_field),
        .o_score(w_score_for_me)
    );

    m_evaluate_oneside op(
        .i_field(i_me_field),
        .o_score(w_score_for_op)
    );

    assign o_score = (w_is_me_win) ? {1'b0,{15{1'b1}}} : (w_is_op_win) ? {1'b1, {15'b0}} : {8'd0, w_score_for_me} - {8'd0, w_score_for_op};
endmodule

module m_evaluate_oneside (
    input wire [`FIELD_SIZE-1:0] i_field,

    output wire [7:0] o_score
);
    // 横方向摂動
    wire [`FIELD_SIZE-1:0] w_horizontal_pertubation;
    assign w_horizontal_pertubation = i_field |
                                    ((i_field >> 1) & `RIGHT_SHIFT_MASK) |
                                    ((i_field << 1) & `LEFT_SHIFT_MASK);
    wire [`FIELD_SIZE-1:0] w_horizontal_affected = ~w_horizontal_pertubation;

    wire [$clog2(`FIELD_SIZE+1)-1:0] w_horizontal_score;
    m_count_N_in_a_row # (
        .MASK(`RIGHT_SHIFT_MASK)
    )
    c40
    (
        .i_field(w_horizontal_affected),
        .o_count(w_horizontal_score)
    );

    // 縦方向摂動
    wire [`FIELD_SIZE-1:0] w_vertical_pertubation;
    assign w_vertical_pertubation = i_field |
                                    ((i_field >> `COL_COUNT)) |
                                    ((i_field << `COL_COUNT));
    wire [`FIELD_SIZE-1:0] w_vertical_affected = ~w_vertical_pertubation;
    wire [$clog2(`FIELD_SIZE+1)-1:0] w_vertical_score;
    m_count_N_in_a_row # (
        .SHIFT_RIGHT_COUNT(`COL_COUNT)
    )
    c41
    (
        .i_field(w_vertical_affected),
        .o_count(w_vertical_score)
    );

    // 左上右下斜め摂動
    wire [`FIELD_SIZE-1:0] w_ltrb_pertubation;
    assign w_ltrb_pertubation = i_field |
                                    ((i_field << (`COL_COUNT+1)) & `LEFT_SHIFT_MASK) |
                                    ((i_field >> (`COL_COUNT+1)) & `RIGHT_SHIFT_MASK);
    wire [`FIELD_SIZE-1:0] w_ltrb_affected = ~w_ltrb_pertubation;
    wire [$clog2(`FIELD_SIZE+1)-1:0] w_ltrb_score;
    m_count_N_in_a_row # (
        .MASK(`RIGHT_SHIFT_MASK),
        .SHIFT_RIGHT_COUNT(`COL_COUNT+1)
    )
    c42
    (
        .i_field(w_ltrb_affected),
        .o_count(w_ltrb_score)
    );

    // 右上左下斜め摂動
    wire [`FIELD_SIZE-1:0] w_rtrlb_pertubation;
    assign w_rtrlb_pertubation = i_field |
                                    ((i_field << (`COL_COUNT-1)) & `RIGHT_SHIFT_MASK) |
                                    ((i_field >> (`COL_COUNT-1)) & `LEFT_SHIFT_MASK);
    wire [`FIELD_SIZE-1:0] w_rtlb_affected = ~w_ltrb_pertubation;
    wire [$clog2(`FIELD_SIZE+1)-1:0] w_rtlb_score;
    m_count_N_in_a_row # (
        .MASK(`LEFT_SHIFT_MASK),
        .SHIFT_RIGHT_COUNT(`COL_COUNT-1)
    )
    c43
    (
        .i_field(w_rtlb_affected),
        .o_count(w_rtlb_score)
    );


    assign o_score = w_horizontal_score + w_vertical_score + w_ltrb_score + w_rtlb_score;  
endmodule


// N連続で並んでいる部分の数をカウントする 1111100 で N = 4 ならこれは 1111 100 と 1 1111 00 の 2
module m_count_N_in_a_row
# (
    parameter MASK = ~{42'b0},
    parameter SHIFT_RIGHT_COUNT = 1,
    parameter IN_A_ROW_LENGTH = 4
)
(
    input wire [`FIELD_SIZE-1:0] i_field,

    output wire [$clog2(`FIELD_SIZE+1)-1:0] o_count
);
    wire [`FIELD_SIZE-1:0] w_shifted [0:IN_A_ROW_LENGTH-1];
    assign w_shifted[0] = i_field;

    genvar i;
    generate
        for (i = 1; i <= IN_A_ROW_LENGTH-1; i = i+1) begin
            assign w_shifted[i] = w_shifted[i-1] & ((w_shifted[i-1] >> SHIFT_RIGHT_COUNT) & MASK);
        end
    endgenerate

    m_count_ones #(
        .INPUT_SIZE(`FIELD_SIZE)
    )
    co (
        .i_data(w_shifted[IN_A_ROW_LENGTH-1]),
        .o_count(o_count)
    );
endmodule
