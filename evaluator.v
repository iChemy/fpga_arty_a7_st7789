`include "config.vh"
`include "seaquence_checker.v"
`include "count_ones.v"

module m_evaluator (
    input wire [`FIELD_SIZE-1:0] i_me_field,
    input wire [`FIELD_SIZE-1:0] i_opposite_field,

    output wire signed [15:0] o_score
);

    wire w_is_me_win, w_is_op_win;

    m_seaquence_checker sc0(
        .i_field(i_me_field),
        .o_detected(w_is_me_win)
    );
    m_seaquence_checker sc1(
        .i_field(i_opposite_field),
        .o_detected(w_is_op_win)
    );

    wire [7:0] w_score_for_me, w_score_for_op;

    m_evaluate_oneside me(
        .i_field(i_opposite_field),
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
    wire [`FIELD_SIZE-1:0] w_me_horizontal_affected = ~w_horizontal_pertubation;

    wire [$clog2(`FIELD_SIZE+1)-1:0] w_hor_count;
    m_count_four_in_a_row # (
        .MASK(`RIGHT_SHIFT_MASK)
    )
    c40
    (
        .i_field(w_me_horizontal_affected),
        .o_count(w_hor_count)
    );

    // 縦方向摂動
    wire [`FIELD_SIZE-1:0] w_vertical_pertubation;
    assign w_vertical_pertubation = i_field |
                                    ((i_field >> `COL_COUNT)) |
                                    ((i_field << `COL_COUNT));
    wire [`FIELD_SIZE-1:0] w_me_vertical_affected = ~w_vertical_pertubation;
    wire [$clog2(`FIELD_SIZE+1)-1:0] w_ver_count;
    m_count_four_in_a_row # (
        .SHIFT_RIGHT_COUNT(`COL_COUNT)
    )
    c41
    (
        .i_field(w_me_vertical_affected),
        .o_count(w_ver_count)
    );

    // 左上右下斜め摂動
    wire [`FIELD_SIZE-1:0] w_ltrb_pertubation;
    assign w_ltrb_pertubation = i_field |
                                    ((i_field << (`COL_COUNT+1)) & `LEFT_SHIFT_MASK) |
                                    ((i_field >> (`COL_COUNT+1)) & `RIGHT_SHIFT_MASK);
    wire [`FIELD_SIZE-1:0] w_me_ltrb_affected = ~w_ltrb_pertubation;
    wire [$clog2(`FIELD_SIZE+1)-1:0] w_ltrb_count;
    m_count_four_in_a_row # (
        .MASK(`RIGHT_SHIFT_MASK),
        .SHIFT_RIGHT_COUNT(`COL_COUNT+1)
    )
    c42
    (
        .i_field(w_me_ltrb_affected),
        .o_count(w_ltrb_count)
    );

    // 右上左下斜め摂動
    wire [`FIELD_SIZE-1:0] w_rtrlb_pertubation;
    assign w_rtrlb_pertubation = i_field |
                                    ((i_field << (`COL_COUNT-1)) & `RIGHT_SHIFT_MASK) |
                                    ((i_field >> (`COL_COUNT-1)) & `LEFT_SHIFT_MASK);
    wire [`FIELD_SIZE-1:0] w_me_rtlb_affected = ~w_ltrb_pertubation;
    wire [$clog2(`FIELD_SIZE+1)-1:0] w_rtlb_count;
    m_count_four_in_a_row # (
        .MASK(`LEFT_SHIFT_MASK),
        .SHIFT_RIGHT_COUNT(`COL_COUNT-1)
    )
    c43
    (
        .i_field(w_me_rtlb_affected),
        .o_count(w_rtlb_count)
    );


    assign o_score = w_hor_count + w_ver_count + w_ltrb_count + w_rtlb_count;  
endmodule

module m_count_four_in_a_row
# (
    parameter MASK = ~{42'b0},
    parameter SHIFT_RIGHT_COUNT = 1
)
(
    input wire [`FIELD_SIZE-1:0] i_field,

    output wire [$clog2(`FIELD_SIZE+1)-1:0] o_count
);
    wire [`FIELD_SIZE-1:0] w_shifted [0:3];
    assign w_shifted[0] = i_field;

    genvar i;
    generate
        for (i = 1; i <= 3; i = i+1) begin
            assign w_shifted[i] = w_shifted[i-1] & ((w_shifted[i-1] >> SHIFT_RIGHT_COUNT) & MASK);
        end
    endgenerate

    m_count_ones #(
        .INPUT_SIZE(`FIELD_SIZE)
    )
    mo (
        .i_data(w_shifted[3]),
        .o_sum(o_count)
    );
endmodule
