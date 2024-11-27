/*********************************************************************************************/
/* 240x240 ST7789 mini display project               Ver.2024-11-23a, ArchLab, Science Tokyo */
/*********************************************************************************************/
`default_nettype none

`include "config.vh"
`include "ai_play.v"
  
/*********************************************************************************************/
module m_main(
    input  wire w_clk,          // main clock signal (100MHz)
    input  wire [3:0] w_button, //
    output wire [3:0] w_led,    //
    output wire st7789_SDA,     //
    output wire st7789_SCL,     //
    output wire st7789_DC,      //
    output wire st7789_RES      //
);  

    // パラメータ: デバウンス時間 (20ms = 2,000,000クロックサイクル)
    localparam DEBOUNCE_DELAY = 2000000;
    reg [3:0] r_button_state = 4'b0;          // 安定したボタンの状態を保持
    reg [31:0] r_debounce_counter[3:0];      // 各ボタンごとのデバウンスカウンタ

    genvar i;
    always @(posedge w_clk) begin
        generate
            for (i = 0; i < 4; i = i + 1) begin
                if (w_button[i] == r_button_state[i]) begin
                    // ボタン状態が変わっていない場合、カウンタをリセット
                    r_debounce_counter[i] <= 0;
                end else begin
                    // ボタン状態が変化した場合、カウンタをインクリメント
                    r_debounce_counter[i] <= r_debounce_counter[i] + 1;
                    if (r_debounce_counter[i] >= DEBOUNCE_DELAY) begin
                        // デバウンス時間を超えたら状態を更新
                        r_button_state[i] <= w_button[i];
                        r_debounce_counter[i] <= 0;
                    end
                end
            end
        endgenerate
    end

    wire [`COL_SIZE-1:0] w_selecting_col;

    m_ai_play m_ai (
        .w_clk(w_clk),
        .w_rst(r_button_state == 4'b1111),

        .w_user_input(r_button_state),

        .o_selecting_col(w_selecting_col),
        .o_your_field(w_your_field),
        .o_ai_field(w_ai_field)
    );

    reg [`COL_SIZE-1:0] r_selecting_col;
    always @(posedge w_clk) begin
        r_selecting_col <= w_selecting_col; // for debug
    end

    reg [7:0] r_x = 0;
    reg [7:0] r_y = 0;
    reg [7:0] r_d = 0;
    reg [7:0] r_wait = 1;

    always @(posedge w_clk) begin
        r_x <= (r_x==239) ? 0 : r_x + 1;
        r_y <= (r_y==239 && r_x==239) ? 0 : (r_x==239) ? r_y + 1 : r_y;
    end
    
    reg [15:0] r_st_wadr  = 0;
    reg        r_st_we    = 0;
    reg [15:0] r_st_wdata = 0;
    always @(posedge w_clk) r_st_wadr  <= {r_y, r_x};
    always @(posedge w_clk) r_st_we    <= 1; 

    wire [`FIELD_SIZE-1:0] w_your_field, w_ai_field;
    input [15:0] w_color;

    m_get_color gc (
        .i_your_field(w_your_field),
        .i_ai_field(w_ai_field),

        .i_x(r_x),
        .i_y(r_y),

        .o_color(w_color)
    );

    always @(posedge w_clk) begin
        if (r_y < 48) begin
            r_st_wdata <= 16'h2020;
        end else if (r_x < 8 || r_x > 231) begin
            r_st_wdata <= 16'h5500;
        end else if (r_y % 32 == 14 || r_y % 32 == 15) begin
            r_st_wdata <= 16'h7878;
        end else if (r_x % 32 == 8 || r_x % 32 == 7) begin
            r_st_wdata <= 16'hA0A0;
        end else begin
            r_st_wdata <= w_color;
        end
    end
  
    wire [15:0] w_raddr;    
    reg  [15:0] r_rdata = 0;
    reg  [15:0] r_raddr = 0;
    reg  [15:0] vmem [0:65535]; // video memory, 256 x 256 (65,536) x 16bit color
    always @(posedge w_clk) begin
        if(r_st_we) vmem[r_st_wadr] <= r_st_wdata;
        r_rdata <= vmem[r_raddr];
        r_raddr <= w_raddr;
    end
    
`ifndef SYNTHESIS  
    reg [15:0] r_adr_p = 0;
    reg [15:0] r_dat_p = 0;
    always @(posedge w_clk) if(r_st_we) begin
        r_adr_p <= r_st_wadr;
        r_dat_p <= r_st_wdata;
        $write("@D%0d_%0d\n", r_st_wadr ^ r_adr_p, r_st_wdata ^ r_dat_p);
        $fflush();
    end
`endif

    m_st7789_disp d1 (w_clk, st7789_SDA, st7789_SCL, st7789_DC, st7789_RES, w_raddr, r_rdata);
endmodule

/*********************************************************************************************/
module m_st7789_disp(
    input  wire w_clk, // main clock signal (100MHz)
    output wire st7789_SDA,
    output wire st7789_SCL,
    output wire st7789_DC,
    output wire st7789_RES,
    output wire [15:0] w_raddr,
    input  wire [15:0] w_rdata
);
    reg [31:0] r_cnt=1;
    always @(posedge w_clk) r_cnt <= (r_cnt==0) ? 0 : r_cnt + 1;
    reg r_RES = 1;
    always @(posedge w_clk) begin
        r_RES <= (r_cnt==100_000) ? 0 : (r_cnt==200_000) ? 1 : r_RES;
    end
    assign st7789_RES = r_RES;    
       
    wire busy; 
    reg r_en = 0;
    reg init_done = 0;
    reg [4:0]  r_state  = 0;   
    reg [19:0] r_state2 = 0;   
    reg [8:0] r_dat = 0;
    reg [15:0] r_c = 16'hf800;
   
    reg [31:0] r_bcnt = 0;
    always @(posedge w_clk) r_bcnt <= (busy) ? 0 : r_bcnt + 1;
    
    always @(posedge w_clk) if(!init_done) begin
        r_en <= (r_cnt>1_000_000 && !busy && r_bcnt>1_000_000); 
    end else begin
        r_en <= (!busy);
    end
    
    always @(posedge w_clk) if(r_en && !init_done) r_state <= r_state  + 1;
    
    always @(posedge w_clk) if(r_en &&  init_done) begin
        r_state2 <= (r_state2==115210) ? 0 : r_state2 + 1; // 11 + 240x240*2 = 11 + 115200 = 115211
    end

    reg [7:0] r_x = 0;
    reg [7:0] r_y = 0;
    always @(posedge w_clk) if(r_en && init_done && r_state2[0]==1) begin
       r_x <= (r_state2<=10 || r_x==239) ? 0 : r_x + 1;
       r_y <= (r_state2<=10) ? 0 : (r_x==239) ? r_y + 1 : r_y;
    end
    assign w_raddr = {r_y, r_x};
    
    reg  [15:0] r_color = 0;
    always @(posedge w_clk) r_color <= w_rdata;  
 
    always @(posedge w_clk) begin
        case (r_state2) /////
            0:  r_dat<={1'b0, 8'h2A};   // Column Address Set
            1:  r_dat<={1'b1, 8'h00};   // [0]
            2:  r_dat<={1'b1, 8'h00};   // [0]
            3:  r_dat<={1'b1, 8'h00};   // [0]
            4:  r_dat<={1'b1, 8'd239};  // [239]
            5:  r_dat<={1'b0, 8'h2B};   // Row Address Set
            6:  r_dat<={1'b1, 8'h00};   // [0]
            7:  r_dat<={1'b1, 8'h00};   // [0]
            8:  r_dat<={1'b1, 8'h00};   // [0]
            9:  r_dat<={1'b1, 8'd239};  // [239]
            10: r_dat<={1'b0, 8'h2C};   // Memory Write
            default: r_dat <= (r_state2[0]) ? {1'b1, r_color[15:8]} :{ 1'b1, r_color[7:0]}; 
        endcase
    end
    
    reg [8:0] r_init = 0;
    always @(posedge w_clk) begin
        case (r_state) /////
            0:  r_init<={1'b0, 8'h01};  // Software Reset, wait 120msec
            1:  r_init<={1'b0, 8'h11};  // Sleep Out, wait 120msec
            2:  r_init<={1'b0, 8'h3A};  // Interface Pixel Format
            3:  r_init<={1'b1, 8'h55};  // [65K RGB, 16bit/pixel]
            4:  r_init<={1'b0, 8'h36};  // Memory Data Accell Control
            5:  r_init<={1'b1, 8'h00};  // [000000]
            6:  r_init<={1'b0, 8'h21};  // Display Inversion On
            7:  r_init<={1'b0, 8'h13};  // Normal Display Mode On
            8:  r_init<={1'b0, 8'h29};  // Display On
            9 : init_done <= 1;
        endcase
    end

    wire [8:0] w_data = (init_done) ? r_dat : r_init;
    m_spi spi0 (w_clk, r_en, w_data, st7789_SDA, st7789_SCL, st7789_DC, busy);
endmodule

/****** SPI send module,  SPI_MODE_2, MSBFIRST                                           *****/
/*********************************************************************************************/
module m_spi(
    input  wire w_clk,       // 100MHz input clock !!
    input  wire en,          // write enable
    input  wire [8:0] d_in,  // data in
    output wire SDA,         // Serial Data
    output wire SCL,         // Serial Clock
    output wire DC,          // Data/Control
    output wire busy         // busy
);
    reg [5:0] r_state = 0;
    reg [7:0] r_cnt = 0;
    reg r_SCL = 1;
    reg r_DC  = 0;
    reg [7:0] r_data = 0;
    reg r_SDA = 0;

    always @(posedge w_clk) begin
        if(en && r_state==0) begin
            r_state <= 1;
            r_data  <= d_in[7:0];
            r_DC    <= d_in[8];
            r_cnt   <= 0;
        end
        else if (r_state==1) begin
            r_SDA   <= r_data[7];
            r_data  <= {r_data[6:0], 1'b0};
            r_state <= 2;
            r_cnt   <= r_cnt + 1;
        end
        else if (r_state==2) begin
            r_SCL   <= 0;
            r_state <= 3;
        end
        else if (r_state==3) begin
            r_state <= 4;
        end
        else if (r_state==4) begin
            r_SCL   <= 1;
            r_state <= (r_cnt==8) ? 0 : 1;
        end
    end

    assign SDA = r_SDA;
    assign SCL = r_SCL;
    assign DC  = r_DC;
    assign busy = (r_state!=0 || en);
endmodule
/*********************************************************************************************/

module m_get_color #(
    parameter EMPTY_COLOR = 16'hffff,
    parameter YOUR_COLOR = 16'h00ff,
    parameter AI_COLOR = 16'h3333,
)
(
    input wire [`FIELD_SIZE-1:0] i_your_field,
    input wire [`FIELD_SIZE-1:0] i_ai_field,

    input wire [7:0] i_x,
    input wire [7:0] i_y,

    output [15:0] o_color
);
    wire [`COL_SIZE-1:0] w_col_idx = (i_x-8) / 32;
    wire [`ROW_SIZE-1:0] w_row_idx = (i_y-48) / 32;

    wire w_your = i_your_field[w_col_idx * `COL_COUNT + w_row_idx];
    wire w_ai = i_your_field[w_col_idx * `COL_COUNT + w_row_idx];

    assign o_color = (w_your) ? YOUR_COLOR : (w_ai) ? AI_COLOR : EMPTY_COLOR;

endmodule