`include "config.vh"
`include "two_people_play.v"

module testbench;

    // Inputs
    reg r_clk = 0;
    reg r_rst = 1;
    reg [3:0] r_user_input = 0;

    // Outputs
    wire [`COL_SIZE-1:0] w_selecting_col;
    wire [`FIELD_SIZE-1:0] w_red_field;
    wire [`FIELD_SIZE-1:0] w_blue_field;
    wire [1:0] w_settlement_state;

    // Instantiate the Unit Under Test (UUT)
    m_two_people_play tpp (
        .w_clk(r_clk),
        .w_rst(r_rst),
        .i_user_input(r_user_input),
        .o_selecting_col(w_selecting_col),
        .o_red_field(w_red_field),
        .o_blue_field(w_blue_field),
        .o_settlement_state(w_settlement_state)
    );

    initial begin
        $monitor("%b|%d|%b|%b|%b",tpp.r_state, w_selecting_col,w_red_field,w_blue_field,w_settlement_state);
    end

    initial forever #3 r_clk <= ~r_clk;

    always @(posedge r_clk) begin
        if (w_settlement_state != 2'b00) begin
            r_rst <= 1;
        end else begin
            r_rst <= 0;
        end

        r_user_input <= (r_user_input == 4'b0000) ? 4'b1000: r_user_input >> 1;
    end

    initial begin
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b0010;
        #10 r_user_input = 4'b0010;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b0010;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b0010;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b0010;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b0010;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b0010;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b0010;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b0010;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b0010;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b0010;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b0010;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b0010;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b0010;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b0010;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b0010;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b0010;
        #10 r_user_input = 4'b0010;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b0010;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b0010;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b0010;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b0010;
        #10 r_user_input = 4'b0010;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b0010;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b0010;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b0010;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b0010;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b0010;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b0010;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b0010;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b0010;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b0010;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b0010;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b0010;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b0010;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b0010;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b0010;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b0010;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b0010;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b0010;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b0010;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b0010;
        #10 r_user_input = 4'b0010;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b0010;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b0010;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b0010;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b0010;
        #10 r_user_input = 4'b0010;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b0010;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b0010;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b0010;
        #10 r_user_input = 4'b1000;
        #10 r_user_input = 4'b1000;
        #10 $finish;
    end


endmodule