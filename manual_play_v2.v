`include "config.vh"
`include "piler.v"

module m_manual_play (
    input wire w_clk,
    input wire w_rst,

    input wire [3:0] w_user_input,

    output wire [`COL_SIZE-1:0] o_selecting_col,
    output wire [`FIELD_SIZE-1:0] o_red_field,
    output wire [`FIELD_SIZE-1:0] o_blue_field
);
    localparam NOT_START = 3'b000;
    localparam RED_TURN = 3'b001;
    localparam BLUE_TURN = 3'b100;
    localparam RED_PILING = 3'b011;
    localparam BLUE_PILING = 3'b110;

    localparam USER_INPUT_INC = 4'b0001;
    localparam USER_INPUT_DEC = 4'b0010;
    localparam USER_INPUT_OK = 4'b0100;

    reg [2:0] state = RED_TURN;

    reg [`PILED_COUNT_ARRAY_SIZE-1:0] r_piled_count_array = 0;
    reg [`FIELD_SIZE-1:0] r_red_field = 0, r_blue_field = 0;
    reg [`COL_SIZE-1:0] r_selecting_col = 0;

    wire [`FIELD_SIZE-1:0] w_mp_input_field = (state == RED_PILING) ? r_red_field : (state == BLUE_PILING) ? r_blue_field : 42'b0;
    wire [`PILED_COUNT_ARRAY_SIZE-1:0] w_mp_input_array = (state == RED_PILING || state == BLUE_PILING) ? r_piled_count_array : {21{1'b1}};

    wire w_mp_output_valid;
    wire[`FIELD_SIZE-1:0]  w_mp_output_field;
    wire [`PILED_COUNT_ARRAY_SIZE-1:0] w_mp_output_array;
    m_piler mp (
        .i_field(w_mp_input_field),
        .i_piled_count_array(r_piled_count_array),
        .i_piled_col(r_selecting_col),

        .o_valid(w_mp_output_valid),
        .o_piled_field(w_mp_output_field),
        .o_piled_count_array(w_mp_output_array)
    );
    reg [7:0] r_wait = 0;
    always @(posedge w_clk) begin
        if (w_rst) begin
            r_red_field <= 0;
            r_blue_field = 0;
            r_piled_count_array <= 0;
            r_selecting_col <= 0;

            state <= RED_TURN;
        end else if (state == RED_TURN || state == BLUE_TURN) begin
            if (w_user_input == USER_INPUT_INC) begin
                r_selecting_col <= (r_selecting_col + 1) % `COL_SIZE;
            end

            if (w_user_input == USER_INPUT_DEC) begin
                r_selecting_col <= (r_selecting_col - 1) % `COL_SIZE;
            end

            if (w_user_input == USER_INPUT_OK) begin
                if (state == RED_TURN) begin
                    state <= RED_PILING;
                end else begin
                    state <= BLUE_PILING;
                end
            end
        end else if (state == RED_PILING || state == BLUE_PILING) begin
            r_wait <= r_wait + 1;
            if (w_mp_output_valid & r_wait == 255) begin
                if (state == RED_PILING) begin
                    r_red_field <= w_mp_output_field;
                    state <= BLUE_TURN;
                end else begin
                    r_blue_field <= w_mp_output_field;
                    state <= RED_TURN;
                end

                r_piled_count_array <= w_mp_output_array;
            end else if (!w_mp_output_valid) begin
                if (state == RED_PILING) begin
                    r_wait <= 0;
                    state <= RED_TURN;
                end else begin
                    r_wait <= 0;
                    state <= BLUE_TURN;
                end
            end
        end
    end
endmodule
