`include "config.vh"
`include "seaquence_checker.v"

module tb_m_seaquence_checker ();
    reg [`FIELD_SIZE-1:0] r_field;

    wire w_detected;

    m_seaquence_checker sc(
        .i_field(r_field),
        .o_detected(w_detected)
    );
    initial begin
        $monitor("%b %b", r_field, w_detected); 
    end

    initial begin
        #50 r_field <= {{7'b1101000}, 35'd0};
        #50 r_field <= {{3{7'b1000000}}, 21'd0};
        #50 r_field <= {{7'b1111000}, 35'd0};
        #50 r_field <= {6{7'b1000000}};
        #50 r_field <= {{7'b1000000}, {7'b0100000}, {7'b0010000}, {7'b0001000}, 14'd0};
        #50 r_field <= {{7'b0001000}, {7'b0010000}, {7'b0100000}, {7'b1000000}, 14'd0};

        #50 $finish;
    end
endmodule