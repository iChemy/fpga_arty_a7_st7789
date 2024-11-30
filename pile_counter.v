`include "config.vh"

/*
 * |col6に積まれてる数|col5に積まれてる数|...|col1に積まれてる数|col0に積まれてる数|
 *                              3bit x 7
 * 
 */
module m_pile_counter (
    input wire [`PILE_COUNT_ARRAY_SIZE-1:0] i_pile_count_array,
    input wire [`COL_SIZE-1:0] i_col,

    output wire o_valid,
    output wire [`PILE_COUNT_ARRAY_SIZE-1:0] o_pile_count_array,
    output wire [`ROW_SIZE-1:0] o_pile_count
);
    wire [`ROW_SIZE-1:0] w_pile_count = i_pile_count_array[i_col*(`ROW_SIZE)+:`ROW_SIZE];

    wire [`PILE_COUNT_ARRAY_SIZE-1:0] w_pile_count_array_masked = i_pile_count_array & ~(3'b111 << (i_col*(`ROW_SIZE)));

    assign o_valid = (w_pile_count != 3'b110); // 6個積まれてしまっている
    assign o_pile_count = w_pile_count;
    assign o_pile_count_array = w_pile_count_array_masked | ((w_pile_count + 1) << (i_col*(`ROW_SIZE)));
endmodule
