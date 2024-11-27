`include "count_ones.v"

module tb_m_count_ones ();
    localparam INPUT_SIZE = 42;
    reg [INPUT_SIZE-1:0] r_test = {7{6'b101010}};
    wire [$clog2(INPUT_SIZE+1)-1:0] w_test_out;
    initial begin
        $monitor("%d", w_test_out);
    end
    m_count_ones #(
        .INPUT_SIZE(INPUT_SIZE)
    ) mco (
        .i_data(r_test),
        .o_sum(w_test_out)
    );
endmodule