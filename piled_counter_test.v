`include "config.vh"
`include "piled_counter.v"

module tb_m_piled_counter ();
    reg [`PILED_COUNT_ARRAY_SIZE-1:0] r_piled_count_array = 0;
    reg [`COL_SIZE-1:0] r_pile_col = 0;
    wire [`ROW_SIZE-1:0] w_piled_count;
    wire [`PILED_COUNT_ARRAY_SIZE-1:0] w_piled_count_array;
    wire w_pile_valid;

    reg r_clk = 0;

    initial forever #50 r_clk <= ~r_clk;

    m_piled_counter pm(
        .i_piled_count_array(r_piled_count_array),
        .i_col(r_pile_col),

        .o_valid(w_pile_valid),
        .o_piled_counter(w_piled_count_array),
        .o_piled_count(w_piled_count)
    );

    always @(posedge r_clk) begin
        r_pile_col <= (r_pile_col + 1) % `COL_COUNT; // 列番号を0~6で循環
        if (w_pile_valid) begin
            r_piled_count_array <= w_piled_count_array; // 更新
        end
        $display("Time: %0t | Col: %d | Counter: %o | Pile Count: %d | Valid: %b",
                 $time, r_pile_col, r_piled_count_array, w_piled_count, w_pile_valid);
    end

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_m_piled_counter);

        #7000; // シミュレーション時間
        $finish;
    end
endmodule