`timescale 1ns / 1ps

module BCD8_Counter_Advanced (
    input clk,                // 100 MHz
    input reset,             
    input sw,                 // Pause =1, Resume=0

    input btn10,              
    input btn100,             
    input btn1000,            
    input btn10000,           

    output [6:0] seg,         // 7-segment segments
    output [7:0] an           // Anodes
);

    // INTERNAL VARIABLES
    integer temp;
    integer i;

    //------------------------------------------------------------
    // 8-digit BCD storage
    reg [3:0] bcd[7:0];

    //--------------------------------------------------------------------------------------------
    // CLOCK DIVIDER: 100MHz(period = 10 ns) = 6 Hz counter clock(one increment every 
                                               //0.16 seconds.
                                              //high for 0.083333 seconds
                                              //low for 0.083333 seconds)
    //0.083333 seconds × 100,000,000 cycles/sec = 8,333,333 cycles
    
    //83.33333 ms × 2 = 166.66666 ms
    //  1 / 0.1666666 = 6 Hz

    //---------------------------------------------------------------------------------------------
    reg [26:0] div_counter = 0;                  //Max value = 134,217,727  Needed value = 8,333,333
                                                 
    reg slow_clk = 0;    //square wave clock.
                         //It toggles every time div_counter reaches 8,333,333. 
                         //Since toggling means going from 0?1 or 1?0,
    always @(posedge clk or posedge reset) begin   // This block runs on every rising edge of the main 100 MHz clock
        if (reset) begin
            div_counter <= 0;
            slow_clk <= 0;
        end
        else if (div_counter == 8_333_333) begin
            div_counter <= 0;
            slow_clk <= ~slow_clk;                 // 0?1 or 1?0
        end
        else
            div_counter <= div_counter + 1;
    end

    // Slow clock edge detection (1-clock wide pulse)
    reg slow_clk_d;
    wire slow_clk_edge;
    always @(posedge clk) slow_clk_d <= slow_clk;
    assign slow_clk_edge = slow_clk & ~slow_clk_d;          //increment once RIGHT NOW

    // BUTTON DEBOUNCING
    wire db10, db100, db1000, db10000;

    Debounce DB10    (.clk(clk), .btn(btn10),    .result(db10));
    Debounce DB100   (.clk(clk), .btn(btn100),   .result(db100));
    Debounce DB1000  (.clk(clk), .btn(btn1000),  .result(db1000));
    Debounce DB10000 (.clk(clk), .btn(btn10000), .result(db10000));

    //------------------------------------------------------------
    // RISING EDGE DETECTION
    reg db10_d=0, db100_d=0, db1000_d=0, db10000_d=0;  // db = 1?button pressed  = 0 ? button released
    always @(posedge clk) begin
        db10_d    <= db10;
        db100_d   <= db100;
        db1000_d  <= db1000;
        db10000_d <= db10000;    //On every clock tick, we store the current debounced button state into db_d.last clock cycle
    end

    wire inc10    = db10    & ~db10_d;            
    wire inc100   = db100   & ~db100_d;
    wire inc1000  = db1000  & ~db1000_d;
    wire inc10000 = db10000 & ~db10000_d;

    //------------------------------------------------------------
    // TASK: Increment BCD value
    task increment_by(input integer value);
    begin
        temp =
            bcd[7]*10000000 +
            bcd[6]*1000000 +
            bcd[5]*100000 +
            bcd[4]*10000 +
            bcd[3]*1000 +
            bcd[2]*100 +
            bcd[1]*10 +
            bcd[0];

        temp = temp + value;

        if (temp > 99_999_999)
            temp = 0;

        for (i=0; i<8; i=i+1) begin
            bcd[i] = temp % 10;
            temp   = temp / 10;   //Using %10 and /10 is a simple way to extract digits one by one from right to left.
        end
    end
    endtask
//   This loop takes the integer temp and separates it into individual decimal digits. temp % 10 gets the least significant digit and stores it in bcd[i]. Then temp / 10 removes that digit, and the loop repeats for all 8 digits. This converts a normal integer into an 8-digit BCD array.
    //------------------------------------------------------------
    // MAIN COUNTER: single always block for all updates
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i=0; i<8; i=i+1)
                bcd[i] <= 0;                 
        end
        else begin
            // Automatic increment
            if (!sw && slow_clk_edge)
                increment_by(1);

            // Button increments (immediate)
            if (inc10)    increment_by(10);
            if (inc100)   increment_by(100);
            if (inc1000)  increment_by(1000);
            if (inc10000) increment_by(10000);
        end
    end

    //------------------------------------------------------------
    // DISPLAY MULTIPLEXING (~2 kHz) ideal for time-multiplexing 8-digit display
    //Here: 0.5 ms / 10 ns - 1 = 49,999
    reg [15:0] mux_counter = 0;
    reg mux_clk = 0;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            mux_counter <= 0;
            mux_clk <= 0;
        end else if (mux_counter == 49_999) begin
            mux_counter <= 0;       //reset counter
            mux_clk <= ~mux_clk;    //toggle slow clock (0 ? 1 or 1 ? 0)
        end else
            mux_counter <= mux_counter + 1;
    end

    reg [2:0] current_digit = 0;    //3-bit register to store which digit (0-7) is currently active.
    always @(posedge mux_clk or posedge reset) begin
        if (reset)
            current_digit <= 0;
        else
            current_digit <= current_digit + 1;
    end

    reg [6:0] seg_r;
    reg [7:0] an_r;

    always @(*) begin
        case (bcd[current_digit])
            0: seg_r = 7'b1000000;
            1: seg_r = 7'b1111001;
            2: seg_r = 7'b0100100;
            3: seg_r = 7'b0110000;
            4: seg_r = 7'b0011001;
            5: seg_r = 7'b0010010;
            6: seg_r = 7'b0000010;
            7: seg_r = 7'b1111000;
            8: seg_r = 7'b0000000;
            9: seg_r = 7'b0010000;
            default: seg_r = 7'b1111111;
        endcase
        an_r = ~(8'b00000001 << current_digit);    //<< current_digit ? shift left by current_digit bits
    end                                            //invert all bits--active low

    assign seg = seg_r;
    assign an  = an_r;

endmodule

//=================================================================
// DEBOUNCE MODULE

module Debounce(
    input clk,
    input btn,
    output reg result
);
    reg [19:0] count = 0;  //Each clock period = 10 ns
                           //Counter max = 1,048,575
                           //Time = 1,048,575 × 10 ns ? 10.485 ms
    reg stable = 0;        //not pressed

    always @(posedge clk) begin
        if (btn == stable)
            count <= 0;
        else begin
            count <= count + 1;
            if (count == 20'hFFFFF) begin  //20'hFFFFF = 1,048,575 (maximum value for 20-bit counter).
                stable <= btn;
                result <= btn;
            end
        end
    end
endmodule