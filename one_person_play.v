`include "config.vh"
// `include "piler.v"
// `include "winning_detector.v"
`include "depth_first_game_tree.v"

module m_one_person_play (
    input wire w_clk,
    input wire w_rst,
    input wire [3:0] i_user_input,

    output reg [`COL_SIZE-1:0] o_selecting_col,
    output reg [`FIELD_SIZE-1:0] o_red_field,
    output reg [`FIELD_SIZE-1:0] o_blue_field,

    output reg [1:0] o_settlement_state = 2'b0
);
    localparam [3:0] UNSTARTED = 4'b0000;

    // RED が人間
    localparam [3:0] RED_SELECTION = 4'b0001;
    localparam [3:0] RED_PILING = 4'b0010;
    localparam [3:0] RED_SET_CHECK = 4'b0011;
    localparam [3:0] RED_WIN = 4'b0101;

    localparam [3:0] BLUE_SELECTION = 4'b0100;
    localparam [3:0] BLUE_PILING = 4'b1000;
    localparam [3:0] BLUE_SET_CHECK = 4'b1100;
    localparam [3:0] BLUE_WIN = 4'b1010;

    reg [3:0] r_state = RED_SELECTION; // 人間が先

    reg [`PILE_COUNT_ARRAY_SIZE-1:0] r_pile_count_array = 0;
    reg [`FIELD_SIZE-1:0] r_red_field = 0, r_blue_field = 0;
    reg [`COL_SIZE-1:0] r_selecting_col = 0;

    /*** for player selection ***/
    localparam [3:0] USER_INPUT_INC = 4'b1000;
    localparam [3:0] USER_INPUT_DEC = 4'b0100;
    localparam [3:0] USER_INPUT_PILE = 4'b0001;

    /***  for piling  ***/
    wire [`FIELD_SIZE-1:0] w_target_field;
    assign w_target_field = (r_state == RED_PILING) ? r_red_field : 
                            (r_state == BLUE_PILING) ? r_blue_field :
                            0;

    wire w_pile_valid;
    wire [`FIELD_SIZE-1:0] w_pile_processed_field;
    wire [`PILE_COUNT_ARRAY_SIZE-1:0] w_pile_processed_array;
    m_piler p (
        .i_field(w_target_field),
        .i_pile_count_array(r_pile_count_array),
        .i_pile_col(r_selecting_col),

        .o_valid(w_pile_valid),
        .o_field(w_pile_processed_field),
        .o_pile_count_array(w_pile_processed_array)
    );

    /***  for tree searching  ***/
    reg r_en = 0;
    wire w_tree_fin, w_tree_score;
    wire [`COL_SIZE-1:0] w_selected_col;

    m_depth_first_game_tree #(
        .DEPTH(4),
        .IS_ME(1'b1) // ai の選択の際に自分がどの手を打つか選ぼうとする -> IS_MEは絶対1
    ) dfgt (
        .w_clk(w_clk),

        .i_en(r_en),

        .i_me_field(r_blue_field), // ai側
        .i_op_field(r_red_field), // プレイヤー

        .i_pile_count_array(r_pile_count_array),

        .o_fin(w_tree_fin),
        .o_score(),
        .o_col(w_selected_col)
    );

    /*** for settlement check ***/
    reg [`FIELD_SIZE-1:0] r_settlement_checked_field;

    wire w_win_detection_res;
    m_winning_detector wd (
        .i_field(r_settlement_checked_field),
        .o_detected(w_win_detection_res)
    );

    localparam [9:0] WAIT_COUNT = 2;
    // ユーザーがボタンを押して離す前に SELECTION_STATE にいくのを防ぐ
    reg [9:0] r_wait_counter = 0;

    always @(posedge w_clk) begin
        if (w_rst) begin
            r_state <= UNSTARTED;
            r_pile_count_array <= 0;
            r_red_field <= 0; r_blue_field <= 0;
            r_selecting_col <= 0;

            r_wait_counter <= 0;

            o_red_field <= 0;
            o_blue_field <= 0;
            o_selecting_col <= 0;
            o_settlement_state <= 0;
        end begin
            o_selecting_col <= r_selecting_col;
            o_red_field <= r_red_field;
            o_blue_field <= r_blue_field;

            case (r_state)
                UNSTARTED: begin
                    r_state <= RED_SELECTION;
                end

                RED_SELECTION: begin
                    case (i_user_input)
                        USER_INPUT_INC: begin
                            r_selecting_col <= (r_selecting_col + 1) % `COL_COUNT;
                        end
                        USER_INPUT_DEC: begin
                            r_selecting_col <= (r_selecting_col - 1) % `COL_COUNT;
                        end
                        USER_INPUT_PILE: begin
                            r_state <= RED_PILING;
                        end
                    endcase
                end

                RED_PILING: begin
                    if (w_pile_valid) begin
                        r_red_field <= w_pile_processed_field;
                        r_pile_count_array <= w_pile_processed_array;
                        r_settlement_checked_field <= w_pile_processed_field;

                        r_state <= RED_SET_CHECK; 
                    end else begin
                        r_state <= RED_SELECTION;
                    end
                end

                RED_SET_CHECK: begin
                    r_wait_counter <= r_wait_counter + 1;
                    if (w_win_detection_res) begin
                        r_state <= RED_WIN;
                    end else begin
                        if (r_wait_counter > WAIT_COUNT) begin
                            r_state <= BLUE_SELECTION; 
                            r_wait_counter <= 0;
                            r_en <= 1;
                        end
                    end
                end

                BLUE_SELECTION: begin // ai
                    if (w_tree_fin) begin
                        r_selecting_col <= w_selected_col;
                        r_en <= 0;
                        r_state <= BLUE_PILING;
                    end
                end

                BLUE_PILING: begin
                    if (w_pile_valid) begin
                        r_blue_field <= w_pile_processed_field;
                        r_pile_count_array <= w_pile_processed_array;
                        r_settlement_checked_field <= w_pile_processed_field;

                        r_state <= BLUE_SET_CHECK; 
                    end else begin
                        // 詰んだ場合違法な手を選ぶ可能性がありそうしたらループしてしまう
                        r_state <= BLUE_SELECTION;
                    end
                end

                BLUE_SET_CHECK: begin
                    r_wait_counter <= r_wait_counter + 1;
                    if (w_win_detection_res) begin
                        r_state <= BLUE_WIN;
                    end else begin
                        if (r_wait_counter > WAIT_COUNT) begin
                            r_state <= RED_SELECTION; 
                            r_wait_counter <= 0;
                        end
                    end
                end
            endcase
        end
    end
endmodule