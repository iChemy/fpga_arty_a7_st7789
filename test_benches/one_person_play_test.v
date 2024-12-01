`include "config.vh"
`include "one_person_play.v"

module testbench;

    // Inputs
    reg r_clk = 0;
    reg r_rst = 0;
    reg [3:0] r_user_input = 0;

    // Outputs
    wire [`COL_SIZE-1:0] w_selecting_col;
    wire [`FIELD_SIZE-1:0] w_red_field;
    wire [`FIELD_SIZE-1:0] w_blue_field;
    wire [1:0] w_settlement_state;

    // Instantiate the Unit Under Test (UUT)
    m_one_person_play opp (
        .w_clk(r_clk),
        .w_rst(r_rst),
        .i_user_input(r_user_input),
        .o_selecting_col(w_selecting_col),
        .o_red_field(w_red_field),
        .o_blue_field(w_blue_field),
        .o_settlement_state(w_settlement_state)
    );

    initial begin
        $monitor("%b|%b|%b|%b",opp.r_state,w_red_field,w_blue_field,w_settlement_state);
    end

    initial forever #3 r_clk <= ~r_clk;

    always @(posedge r_clk) begin
        if (w_settlement_state[1] == 1'b1) begin
            r_rst <= 1;
        end
    end

    initial begin
        #10000 r_user_input = 4'b0001;
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b1000;
        #77777 r_user_input = 4'b0001; // 長押し
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b0001;
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b1000;
        #69867 r_user_input = 4'b0001; // 長押し
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b0001;
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b1000;
        #76543 r_user_input = 4'b0001; // 長押し
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b0001;
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b1000;
        #87123 r_user_input = 4'b0001; // 長押し
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b0001;
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b1000;
        #77777 r_user_input = 4'b0001; // 長押し
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b0001;
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b1000;
        #69867 r_user_input = 4'b0001; // 長押し
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b0001;
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b1000;
        #76543 r_user_input = 4'b0001; // 長押し
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b0001;
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b1000;
        #87123 r_user_input = 4'b0001; // 長押し
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b0001;
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b1000;
        #77777 r_user_input = 4'b0001; // 長押し
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b0001;
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b1000;
        #69867 r_user_input = 4'b0001; // 長押し
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b0001;
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b1000;
        #76543 r_user_input = 4'b0001; // 長押し
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b0001;
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b1000;
        #87123 r_user_input = 4'b0001; // 長押し
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b0001;
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b1000;
        #77777 r_user_input = 4'b0001; // 長押し
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b0001;
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b1000;
        #69867 r_user_input = 4'b0001; // 長押し
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b0001;
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b1000;
        #76543 r_user_input = 4'b0001; // 長押し
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b0001;
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b1000;
        #87123 r_user_input = 4'b0001; // 長押し
        #10000 r_user_input = 4'b0001;
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b1000;
        #77777 r_user_input = 4'b0001; // 長押し
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b0001;
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b1000;
        #69867 r_user_input = 4'b0001; // 長押し
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b0001;
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b1000;
        #76543 r_user_input = 4'b0001; // 長押し
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b0001;
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b1000;
        #87123 r_user_input = 4'b0001; // 長押し
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b0001;
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b1000;
        #77777 r_user_input = 4'b0001; // 長押し
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b0001;
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b1000;
        #69867 r_user_input = 4'b0001; // 長押し
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b0001;
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b1000;
        #76543 r_user_input = 4'b0001; // 長押し
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b0001;
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b1000;
        #87123 r_user_input = 4'b0001; // 長押し
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b0001;
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b1000;
        #77777 r_user_input = 4'b0001; // 長押し
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b0001;
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b1000;
        #69867 r_user_input = 4'b0001; // 長押し
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b0001;
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b1000;
        #76543 r_user_input = 4'b0001; // 長押し
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b0001;
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b1000;
        #87123 r_user_input = 4'b0001; // 長押し
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b0001;
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b1000;
        #77777 r_user_input = 4'b0001; // 長押し
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b0001;
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b1000;
        #69867 r_user_input = 4'b0001; // 長押し
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b0001;
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b1000;
        #76543 r_user_input = 4'b0001; // 長押し
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b0001;
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b1000;
        #87123 r_user_input = 4'b0001; // 長押し
        #10000 r_user_input = 4'b0001;
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b1000;
        #77777 r_user_input = 4'b0001; // 長押し
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b0001;
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b1000;
        #69867 r_user_input = 4'b0001; // 長押し
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b0001;
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b1000;
        #76543 r_user_input = 4'b0001; // 長押し
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b0001;
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b1000;
        #87123 r_user_input = 4'b0001; // 長押し
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b0001;
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b1000;
        #77777 r_user_input = 4'b0001; // 長押し
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b0001;
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b1000;
        #69867 r_user_input = 4'b0001; // 長押し
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b0001;
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b1000;
        #76543 r_user_input = 4'b0001; // 長押し
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b0001;
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b1000;
        #87123 r_user_input = 4'b0001; // 長押し
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b0001;
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b1000;
        #77777 r_user_input = 4'b0001; // 長押し
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b0001;
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b1000;
        #69867 r_user_input = 4'b0001; // 長押し
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b0001;
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b1000;
        #76543 r_user_input = 4'b0001; // 長押し
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b0001;
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b1000;
        #87123 r_user_input = 4'b0001; // 長押し
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b0001;
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b1000;
        #77777 r_user_input = 4'b0001; // 長押し
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b0001;
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b1000;
        #69867 r_user_input = 4'b0001; // 長押し
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b0001;
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b1000;
        #76543 r_user_input = 4'b0001; // 長押し
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b0001;
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b1000;
        #87123 r_user_input = 4'b0001; // 長押し
        #76543 r_user_input = 4'b0001; // 長押し
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b0001;
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b1000;
        #87123 r_user_input = 4'b0001; // 長押し
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b0001;
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b1000;
        #77777 r_user_input = 4'b0001; // 長押し
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b0001;
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b1000;
        #69867 r_user_input = 4'b0001; // 長押し
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b0001;
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b1000;
        #76543 r_user_input = 4'b0001; // 長押し
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b0001;
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b1000;
        #87123 r_user_input = 4'b0001; // 長押し
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b0001;
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b1000;
        #77777 r_user_input = 4'b0001; // 長押し
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b0001;
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b1000;
        #69867 r_user_input = 4'b0001; // 長押し
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b0001;
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b1000;
        #76543 r_user_input = 4'b0001; // 長押し
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b0001;
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b1000;
        #87123 r_user_input = 4'b0001; // 長押し
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b0001;
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b1000;
        #77777 r_user_input = 4'b0001; // 長押し
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b0001;
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b1000;
        #69867 r_user_input = 4'b0001; // 長押し
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b0001;
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b1000;
        #76543 r_user_input = 4'b0001; // 長押し
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b0001;
        #10 r_user_input = 4'b0010;
        #10000 r_user_input = 4'b1000;
        #87123 r_user_input = 4'b0001; // 長押し
        #10 r_user_input = 4'b0010;
        #100000;
        #10 $finish;
    end

endmodule