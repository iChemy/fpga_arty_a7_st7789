`include "config.vh"

/*
 * |col6に積まれてる数|col5に積まれてる数|...|col1に積まれてる数|col0に積まれてる数|
 *                              3bit x 7
 * 
 *
 */
module m_piled_counter (
    input wire [`PILED_COUNT_ARRAY_SIZE-1:0] i_piled_count_array,
    input wire [`COL_SIZE-1:0] i_col,

    output wire o_valid,
    output wire [`PILED_COUNT_ARRAY_SIZE-1:0] o_piled_counter,
    output wire [`ROW_SIZE-1:0] o_piled_count
);
    wire [`ROW_SIZE-1:0] w_piled_count = i_piled_count_array[i_col*(`ROW_SIZE)+:`ROW_SIZE];

    wire [`PILED_COUNT_ARRAY_SIZE-1:0] w_piled_count_array_masked = i_piled_count_array & ~(3'b111 << (i_col*(`ROW_SIZE)));

    assign o_valid = (w_piled_count != 3'b110); // 6個積まれてしまっている
    assign o_piled_count = w_piled_count;
    assign o_piled_counter = w_piled_count_array_masked | ((w_piled_count + 1) << (i_col*(`ROW_SIZE)));
endmodule
