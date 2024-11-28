`include "config.vh"
`include "game_tree_v2.v"

module m_ai_play (
    input wire w_clk,
    input wire w_rst,

    input wire [3:0] w_user_input,

    output wire [`COL_SIZE-1:0] o_selecting_col,
    output wire [`FIELD_SIZE-1:0] o_your_field,
    output wire [`FIELD_SIZE-1:0] o_ai_field
);
    localparam NOT_START = 3'b000;
    localparam YOUR_TURN = 3'b001;
    localparam AI_TURN = 3'b100;
    localparam YOUR_PILING = 3'b011;
    localparam AI_PILING = 3'b110;

    localparam USER_INPUT_INC = 4'b0001;
    localparam USER_INPUT_DEC = 4'b0010;
    localparam USER_INPUT_OK = 4'b0100;
    
    reg [2:0] r_state = YOUR_TURN;

    reg [`PILED_COUNT_ARRAY_SIZE-1:0] r_piled_count_array = 0;
    reg [`FIELD_SIZE-1:0] r_your_field = 0, r_ai_field = 0;
    reg [`COL_SIZE-1:0] r_selecting_col = 0;

    wire w_ai_tree_search_valid, w_ai_tree_search_finished;
    wire [`COL_SIZE-1:0] w_ai_tree_serach_selected_col;

    m_game_tree_v2 #(
        .IS_ME(1),
        .DEPTH(3)
    ) gt (
        .w_clk(w_clk),
        .w_rst(r_state != AI_TURN),
        .w_en(r_state == AI_TURN),

        .i_me_field(r_ai_field),
        .i_op_field(r_your_field),
        .i_piled_array(r_piled_count_array),

        .o_valid(w_ai_tree_search_valid),
        .o_finished(w_ai_tree_search_finished),
        .o_score(),
        .o_selected_col(w_ai_tree_serach_selected_col)
    );

    wire [`FIELD_SIZE-1:0] w_mp_input_field = (r_state == YOUR_PILING) ? r_your_field : (r_state == AI_PILING) ? r_ai_field : 42'b0;
    wire [`PILED_COUNT_ARRAY_SIZE-1:0] w_mp_input_array = (r_state == YOUR_PILING || r_state == AI_PILING) ? r_piled_count_array : {21{1'b1}};

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

    always @(posedge w_clk) begin
        if (w_rst) begin
            r_ai_field <= 0;
            r_your_field = 0;

            r_state <= YOUR_TURN;
        end else if (r_state == YOUR_TURN) begin
            if (w_user_input == USER_INPUT_INC) begin
                r_selecting_col <= (r_selecting_col + 1) % `COL_SIZE;
            end

            if (w_user_input == USER_INPUT_DEC) begin
                r_selecting_col <= (r_selecting_col - 1) % `COL_SIZE;
            end

            if (w_user_input == USER_INPUT_OK) begin
                    r_state <= YOUR_PILING;
            end
        end else if (r_state == YOUR_PILING || r_state == AI_PILING) begin
            if (w_mp_output_valid) begin
                if (r_state == YOUR_PILING) begin
                    r_your_field <= w_mp_output_field;
                    r_state <= AI_TURN;
                end else begin
                    r_ai_field <= w_mp_output_field;
                    r_state <= YOUR_TURN;
                end
                r_piled_count_array <= w_mp_output_array;
            end else begin
                if (r_state == YOUR_PILING) begin
                    r_state <= YOUR_TURN;
                end else begin
                    r_state <= AI_TURN;
                end
            end
        end else if (r_state == AI_TURN) begin
            if (w_ai_tree_search_valid & w_ai_tree_search_finished) begin
                r_selecting_col <= w_ai_tree_serach_selected_col;
                r_state <= AI_PILING;
            end
        end
    end
    
    vio_0 vio_00(w_clk, r_state);

    assign o_ai_field = r_ai_field;
    assign o_your_field = r_your_field;
    assign o_selecting_col = r_selecting_col;
endmodule