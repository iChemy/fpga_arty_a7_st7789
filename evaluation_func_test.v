`include "config.vh"
`include "evaluation_func.v"

module tb_m_evaluation_func ();
    reg r_clk = 0;
    initial forever #5 r_clk <= ~r_clk;
    reg [`FIELD_SIZE-1:0] r_me_field = {7'b0000000,
                                        7'b0000000,
                                        7'b0000000,
                                        7'b0000000,
                                        7'b0000010,
                                        7'b0000010};

    reg [`FIELD_SIZE-1:0] r_op_field = {7'b0000000,
                                        7'b0000000,
                                        7'b0000000,
                                        7'b0000001,
                                        7'b0000001,
                                        7'b0000001};

    reg signed [15:0] r_score;
    wire signed [15:0] w_score;
    m_evaluation_func ef (
        .i_me_field(r_me_field),
        .i_op_field(r_op_field),

        .o_score(w_score)
    );
    initial begin
        $monitor("me:%b|op:%b|score:%d", r_me_field, r_op_field, r_score);
    end
    always @(posedge r_clk) begin
        r_score <= w_score;
    end

    initial begin
        #20 r_me_field = {
                        7'b0000000,
                        7'b0000000,
                        7'b0000000,
                        7'b0000010,
                        7'b0000010,
                        7'b0000010
                        };
        #20 r_op_field = {
                        7'b0000000,
                        7'b0000000,
                        7'b0000001,
                        7'b0000001,
                        7'b0000001,
                        7'b0000001
                        };
        #10 $finish;
    end
endmodule