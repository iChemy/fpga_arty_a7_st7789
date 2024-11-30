`include "config.vh"
`include "piler.v"

module tb_m_piler ();

    reg r_clk = 0;
    initial forever #50 r_clk <= ~r_clk;

    reg [`FIELD_SIZE-1:0] r_field = 0;
    reg [`PILE_COUNT_ARRAY_SIZE-1:0] r_pile_count_array = 0;
    reg [`COL_SIZE-1:0] r_pile_col = 0;

    wire [`FIELD_SIZE-1:0] w_field;
    wire [`PILE_COUNT_ARRAY_SIZE-1:0] w_pile_count_array;

    wire w_valid;

    m_piler mp(
        .i_field(r_field),
        .i_pile_count_array(r_pile_count_array),
        .i_pile_col(r_pile_col),

        .o_valid(w_valid),
        .o_field(w_field),
        .o_pile_count_array(w_pile_count_array)
    );

    always @(posedge r_clk) begin
        r_pile_col <= (r_pile_col + 1) % `COL_COUNT;
        if (w_valid) begin
            r_field <= w_field;
            r_pile_count_array <= w_pile_count_array;
        end

        $display("Time: %0t | Col: %d | Counter: %o | Pile Field : %b",
                 $time, r_pile_col, r_pile_count_array, r_field);
    end

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_m_piler);

        #6000; // シミュレーション時間
        $finish;
    end
endmodule