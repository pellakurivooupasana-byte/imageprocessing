// ==========================================================
// DE10-Lite : Image processing on VGA (640x480 @ 60 Hz)
// 320x240 RGB444 image, 2x scaled, mode chosen by SW[3:0]
// Uses PLL -> real 25 MHz pixel clock
// ==========================================================

module top(
    input         MAX10_CLK1_50,
    input  [9:0]  SW,
    input  [1:0]  KEY,

    output reg [3:0] VGA_R,
    output reg [3:0] VGA_G,
    output reg [3:0] VGA_B,
    output reg       VGA_HS,
    output reg       VGA_VS
);

    wire clk_50m = MAX10_CLK1_50;

    // ------------------------------------------------------
    // PLL : 50 MHz -> 25 MHz
    // ------------------------------------------------------
    wire clk_25m;
    wire pll_locked;

    pll_25mhz PLL (
        .inclk0 (clk_50m),
        .c0     (clk_25m),
        .locked (pll_locked)
    );

    wire clk = clk_25m;

    // Reset while KEY0 pressed OR PLL not locked
    wire rst = ~KEY[0] | ~pll_locked;

    // ------------------------------------------------------
    // VGA counters : 800 x 525 total (640x480 visible)
    // ------------------------------------------------------
    reg [9:0] h = 10'd0;
    reg [9:0] v = 10'd0;

    always @(posedge clk) begin
        if (rst) begin
            h <= 10'd0;
            v <= 10'd0;
        end
        else begin
            if (h == 10'd799) begin
                h <= 10'd0;
                if (v == 10'd524)
                    v <= 10'd0;
                else
                    v <= v + 1'b1;
            end
            else
                h <= h + 1'b1;
        end
    end

    wire active = (h < 10'd640) && (v < 10'd480);

    // ------------------------------------------------------
    // 2x scaling : address = (y/2)*320 + (x/2)
    // ------------------------------------------------------
    wire [16:0] addr = active ? ((v[8:1] * 17'd320) + h[9:1]) : 17'd0;

    // ------------------------------------------------------
    // Image ROM
    // ------------------------------------------------------
    wire [11:0] pixel_data;

    image_rom IMAGE (
        .clock(clk),
        .address(addr),
        .q(pixel_data)
    );

    // ------------------------------------------------------
    // Image processor
    // ------------------------------------------------------
    wire [3:0] r_out, g_out, b_out;

    image_processor PROCESSOR (
        .mode  (SW[3:0]),
        .r_in  (pixel_data[11:8]),
        .g_in  (pixel_data[7:4]),
        .b_in  (pixel_data[3:0]),
        .r_out (r_out),
        .g_out (g_out),
        .b_out (b_out)
    );

    // ------------------------------------------------------
    // Registered VGA outputs
    // ------------------------------------------------------
    always @(posedge clk) begin
        if (rst) begin
            VGA_HS <= 1'b1;
            VGA_VS <= 1'b1;
            VGA_R  <= 4'h0;
            VGA_G  <= 4'h0;
            VGA_B  <= 4'h0;
        end
        else begin
            VGA_HS <= ~((h >= 10'd656) && (h < 10'd752));
            VGA_VS <= ~((v >= 10'd490) && (v < 10'd492));
            VGA_R  <= active ? r_out : 4'h0;
            VGA_G  <= active ? g_out : 4'h0;
            VGA_B  <= active ? b_out : 4'h0;
        end
    end

endmodule


// ==========================================================
// Image ROM  (loads rose.hex — 76800 lines of 3 hex digits)
// ==========================================================
module image_rom (
    input  wire        clock,
    input  wire [16:0] address,
    output reg  [11:0] q
);

    // Force M9K inference — critical for fast compile & correct timing
    (* ramstyle = "M9K, no_rw_check" *) reg [11:0] memory [0:76799];

    initial begin
        $readmemh("rose.hex", memory);
    end

    always @(posedge clock) begin
        q <= memory[address];
    end

endmodule


// ==========================================================
// Image processor
// ==========================================================
module image_processor (
    input  [3:0] mode,
    input  [3:0] r_in,
    input  [3:0] g_in,
    input  [3:0] b_in,
    output reg [3:0] r_out,
    output reg [3:0] g_out,
    output reg [3:0] b_out
);

    reg [7:0] gray_temp;
    reg [3:0] gray;

    always @(*) begin
        gray_temp = (5*r_in) + (9*g_in) + (2*b_in);
        gray      = gray_temp >> 4;

        case (mode)
            4'b0000: begin r_out = r_in;  g_out = g_in;  b_out = b_in;  end
            4'b0001: begin
                if (gray >= 4'd8) begin r_out = 4'hF; g_out = 4'hF; b_out = 4'hF; end
                else               begin r_out = 4'h0; g_out = 4'h0; b_out = 4'h0; end
            end
            4'b0010: begin r_out = gray;  g_out = gray;  b_out = gray;  end
            4'b0011: begin r_out = 4'h0;  g_out = 4'h0;  b_out = b_in;  end
            4'b0100: begin r_out = r_in;  g_out = 4'h0;  b_out = 4'h0;  end
            4'b0101: begin r_out = 4'h0;  g_out = g_in;  b_out = 4'h0;  end
            default: begin r_out = r_in;  g_out = g_in;  b_out = b_in;  end
        endcase
    end

endmodule