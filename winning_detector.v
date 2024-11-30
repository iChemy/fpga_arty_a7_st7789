`include "config.vh"

module m_winning_detector
# (
    parameter IN_A_ROW_LEN = 4
)
(
    input wire [`FIELD_SIZE-1:0] i_field,
    output wire o_detected
);


    wire [`FIELD_SIZE-1:0] w_right_shifted [0:IN_A_ROW_LEN-1];
    wire [`FIELD_SIZE-1:0] w_top_down_shifted [0:IN_A_ROW_LEN-1];
    wire [`FIELD_SIZE-1:0] w_right_down_shifted [0:IN_A_ROW_LEN-1];
    wire [`FIELD_SIZE-1:0] w_left_down_shifted [0:IN_A_ROW_LEN-1];

    assign w_right_shifted[0] = i_field;
    assign w_top_down_shifted[0] = i_field;
    assign w_right_down_shifted[0] = i_field;
    assign w_left_down_shifted[0] = i_field;

    genvar i;
    generate
        for (i = 1; i <= IN_A_ROW_LEN-1; i = i + 1) begin
            assign w_right_shifted[i] = w_right_shifted[i-1] & 
                                            ((w_right_shifted[i-1] >> 1) & `RIGHT_SHIFT_MASK);
            assign w_top_down_shifted[i] = w_top_down_shifted[i-1] & 
                                            (w_top_down_shifted[i-1] >> `COL_COUNT);
            assign w_right_down_shifted[i] = w_right_down_shifted[i-1] & 
                                            ((w_right_down_shifted[i-1] >> (`COL_COUNT + 1)) & `RIGHT_DOWN_SHIFT_MASK);
            assign w_left_down_shifted[i] = w_left_down_shifted[i-1] & 
                                            ((w_left_down_shifted[i-1] >> (`COL_COUNT - 1)) & `LEFT_DOWN_SHIFT_MASK);
        end
    endgenerate

    // シーケンス検出
    assign o_detected = (w_right_shifted[IN_A_ROW_LEN-1] != 0) || 
                        (w_top_down_shifted[IN_A_ROW_LEN-1] != 0) || 
                        (w_right_down_shifted[IN_A_ROW_LEN-1] != 0) ||
                        (w_left_down_shifted[IN_A_ROW_LEN-1] != 0);
endmodule
