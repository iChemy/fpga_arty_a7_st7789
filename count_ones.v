module m_count_ones
# (
    parameter INPUT_SIZE = 42
)
(
    input wire [INPUT_SIZE-1:0] i_data,
    output wire [$clog2(INPUT_SIZE+1)-1:0] o_sum
);
    localparam LEFT_BIT_WIDTH = INPUT_SIZE / 2;
    localparam RIGHT_BIT_WIDTH = INPUT_SIZE - LEFT_BIT_WIDTH;


    wire [LEFT_BIT_WIDTH-1:0] w_left;
    wire [RIGHT_BIT_WIDTH-1:0] w_right;

    wire [$clog2(LEFT_BIT_WIDTH+1)-1:0] w_left_out;
    wire [$clog2(RIGHT_BIT_WIDTH+1)-1:0] w_right_out;
    generate
        if (INPUT_SIZE == 1) begin
            assign o_sum = i_data;
        end else begin
            m_count_ones #(
                .INPUT_SIZE(LEFT_BIT_WIDTH)
            ) co_l (
                .i_data(i_data[INPUT_SIZE-1:RIGHT_BIT_WIDTH]),

                .o_sum(w_left_out)
            );

            m_count_ones #(
                .INPUT_SIZE(RIGHT_BIT_WIDTH)
            ) co_r (
                .i_data(i_data[RIGHT_BIT_WIDTH-1:0]),

                .o_sum(w_right_out)
            );

            assign o_sum = w_left_out + w_right_out;
        end
    endgenerate
endmodule
