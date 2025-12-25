`timescale 1ns / 1ps

module BCD8_Counter_Advanced_tb;

    // Parameters
    parameter CLK_PERIOD = 2; // 500 MHz Clock (2ns perizod)

    // Constant for Debounce Wait in the stimulus (MOVED TO MODULE LEVEL)
    localparam DEBOUNCE_WAIT = 250000; // 250us delay at 1ns/1ps timescale

    // DUT Inputs (Testbench must drive these)
    reg clk;
    reg reset;
    reg sw;
    reg btn10;
    reg btn100;
    reg btn1000;
    reg btn10000;

    // DUT Outputs (Connected, but not strictly analyzed in this TB)
    wire [6:0] seg;
    wire [7:0] an;

    // Testbench Variables for Monitoring (Declared at module level as regs for maximum compatibility)
    reg [31:0] current_count = 0; 
    reg [31:0] paused_value; 

    
    // Instantiate the Unit Under Test (UUT)
    BCD8_Counter_Advanced UUT (
        .clk(clk),
        .reset(reset),
        .sw(sw),
        .btn10(btn10),
        .btn100(btn100),
        .btn1000(btn1000),
        .btn10000(btn10000),
        .seg(seg),
        .an(an)
    );

    // 1. Clock Generation: 100MHz
    always
    begin
        clk = 1'b0;
        #(CLK_PERIOD/2);
        clk = 1'b1;
        #(CLK_PERIOD/2);
    end
    
    // 2. Continuous Value Calculation and Live Monitoring
    always @(UUT.bcd) begin
        // Hierarchical reference to access the internal BCD array (UUT.bcd)
        current_count = 
            UUT.bcd[7]*10000000 + 
            UUT.bcd[6]*1000000 +  
            UUT.bcd[5]*100000 +    
            UUT.bcd[4]*10000 +     
            UUT.bcd[3]*1000 +      
            UUT.bcd[2]*100 +        
            UUT.bcd[1]*10 +         
            UUT.bcd[0];             
            
        $monitor("[%0t] **LIVE COUNT**: %0d | Pause (sw): %b", $time, current_count, sw);
        //Converts BCD to decimal current_count
        //$monitor prints live count whenever BCD changes
    end

    // 3. Test Stimulus Sequence
    initial
    begin
        $display("-----------------------------------------------------");
        $display("Starting BCD8_Counter_Advanced Simulation");
        $display("-----------------------------------------------------");

        // --- PHASE 0: Initial Reset ---
        reset = 1'b1;
        sw = 1'b1; // Start paused
        btn10 = 1'b0; btn100 = 1'b0; btn1000 = 1'b0; btn10000 = 1'b0;
        #500; // Wait for system to stabilize

        reset = 1'b0;
        $display("[%0t] **PHASE 0: RESET Complete**. Counter is 0.", $time);
        
        // --- PHASE 1: Automatic Counting ---
        sw = 1'b0; // Resume counting (sw=0)
        $display("[%0t] **PHASE 1: AUTOMATIC COUNTING (sw=0)**. Counter increments at 6 Hz.", $time);
        #1500_000_000; // Wait 1.5 seconds 
        $display("[%0t] **PHASE 1 Complete**. Current Count: %0d", $time, current_count);


        // --- PHASE 2: Pause and Resume ---
        $display("[%0t] **PHASE 2: PAUSE TEST (sw=1)**. Live count should freeze.", $time);
        sw = 1'b1; // Pause
        paused_value = current_count; 

        #500_000_000; // Wait 0.5 seconds
        
        if (current_count == paused_value) 
            $display("[%0t] Counter successfully PAUSED at: %0d.", $time, current_count);

        $display("[%0t] **RESUME TEST (sw=0)**. Live count should continue increasing.", $time);
        sw = 1'b0; // Resume
        #500_000_000; // Wait 0.5 seconds
        $display("[%0t] **PHASE 2 Complete**. Count resumed and reached: %0d.", $time, current_count);


        // --- PHASE 3: Manual Increments (Paused) ---
        sw = 1'b1; // Ensure pause mode for clean manual testing
        $display("[%0t] **PHASE 3: MANUAL INCREMENTS (sw=1)**. Immediate changes expected.", $time);
        
        // Use the module-level localparam DEBOUNCE_WAIT
        
        // +10
        $display("[%0t] Action: +10 (btn10)", $time);
        btn10 = 1'b1; #100; btn10 = 1'b0; 
        #DEBOUNCE_WAIT; 
        
        // +100
        $display("[%0t] Action: +100 (btn100)", $time);
        btn100 = 1'b1; #100; btn100 = 1'b0; 
        #DEBOUNCE_WAIT;
        
        // +1000
        $display("[%0t] Action: +1000 (btn1000)", $time);
        btn1000 = 1'b1; #100; btn1000 = 1'b0; 
        #DEBOUNCE_WAIT;
        
        // +10000
        $display("[%0t] Action: +10000 (btn10000)", $time);
        btn10000 = 1'b1; #100; btn10000 = 1'b0; 
        #DEBOUNCE_WAIT; 

        $display("[%0t] **PHASE 3 Complete**. Final Count: %0d", $time, current_count);
        
        // --- PHASE 4: Final Reset ---
        $display("[%0t] **PHASE 4: FINAL RESET**. Count should return to 0.", $time);
        reset = 1'b1;
        #100;
        reset = 1'b0;
        #100;

        $display("-----------------------------------------------------");
        $display("[%0t] Simulation finished.", $time);
        $display("-----------------------------------------------------");

        // Finish the simulation
        $finish;
    end

endmodule