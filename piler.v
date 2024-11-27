`include "config.vh"
`include "piled_counter.v"


/*
 * 
 *    6 5 4 3 2 1 0
 * 5 上位 ---> 下位
 * 4  |
 * 3  |
 * 2  V
 * 1 下位
 * 0 
 * 
 * 例: 5行 6列目 (左上) -> 7*5 + 6 = 41 (最上位ビット)
 * 例: 3行 4列目 (真ん中の方) -> 7*3 + 4 = 25 
 */
module m_piler (
    input wire [`FIELD_SIZE-1:0] i_field,
    input wire [`PILED_COUNT_ARRAY_SIZE-1:0] i_piled_count_array,
    input wire [`COL_SIZE-1:0] i_piled_col,

    output wire o_valid,
    output wire [`FIELD_SIZE-1:0] o_piled_field,
    output wire [`PILED_COUNT_ARRAY_SIZE-1:0] o_piled_count_array
);

    wire w_pile_valid;
    wire [`PILED_COUNT_ARRAY_SIZE-1:0] w_piled_count_array;
    wire [`ROW_SIZE-1:0] w_piled_count;

    m_piled_counter pm(
        .i_piled_count_array(i_piled_count_array),
        .i_col(i_piled_col),

        .o_valid(w_pile_valid),
        .o_piled_counter(w_piled_count_array),
        .o_piled_count(w_piled_count)
    );

    assign o_piled_field = i_field | (1'b1 << (`COL_COUNT*w_piled_count + i_piled_col)); // ここで i_field が書き換えられた値が出てくる
    assign o_valid = w_pile_valid;
    assign o_piled_count_array = (w_pile_valid) ? w_piled_count_array : i_piled_count_array;
endmodule
