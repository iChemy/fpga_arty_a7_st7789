`include "config.vh"
`include "evaluator.v"

module tb_m_evaluator ();
    reg [`FIELD_SIZE-1:0] r_me_field = {
        7'b0000000, 
        7'b0000000,
        7'b0000000,
        7'b0000000,
        7'b0000001,
        7'b0000101};
    reg [`FIELD_SIZE-1:0] r_opposite_field = {
        7'b0000000, 
        7'b0000000,
        7'b0000000,
        7'b0000010,
        7'b0000010,
        7'b0000010};

    wire signed [15:0] w_score;

    m_evaluator ev(
        .i_me_field(r_me_field),
        .i_opposite_field(r_opposite_field),
        .o_score(w_score)
    );

    initial begin
        $monitor("score: %d", w_score);
    end
endmodule