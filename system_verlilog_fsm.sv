`timescale 1ns/1ns

module part3 (Clock, Reset, Go, Divisor, Dividend, 
              Quotient, Remainder, ResultValid);
input logic Clock, Reset, Go;
input logic [3:0] Divisor, Dividend;
output logic [3:0] Quotient, Remainder;
output logic ResultValid;

logic ld_1, ld_2;

control_path control(Clock, Reset, Go, ld_1, ld_2, ResultValid);
data_path data(Clock, Reset, Go, Divisor, Dividend, ld_1, ld_2, Quotient, Remainder);

endmodule


module control_path (Clock, Reset, Go, ld_1, ld_2, ResultValid);

input logic Clock, Reset, Go;
output logic ld_1, ld_2, ResultValid; 

// Defining logic states
typedef enum logic [4:0] { rst_state            = 'd0,
                           load_state           = 'd1,
                           shift_1              = 'd2,
                           shift_2              = 'd3,
                           shift_3              = 'd4,
                           shift_4              = 'd5} statetype;

statetype current_state, next_state;

// Next state logic
always_comb
begin
    case(current_state)
        rst_state: next_state = Go ? shift_1 : load_state;
        load_state: next_state = Go ? shift_1 : load_state;

        shift_1: next_state = shift_2;
        shift_2: next_state = shift_3;
        shift_3: next_state = shift_4;
        shift_4: next_state = load_state;
    endcase
end

always_comb
begin
    // Defining default
    ld_1 = 1'b0;
    ld_2 = 1'b0;
    ResultValid = 1'b0;

    // Defining state specific changes
    case (current_state)
        rst_state: begin
            ld_1 = 1'b1;
            ld_2 = 1'b1;
        end
        load_state: begin
            ld_1 = 1'b1;
            ld_2 = 1'b1;
            ResultValid = 1'b1;
        end
    endcase
end

// current state logicisters
always_ff @(posedge Clock)
begin
    if(Reset)
        current_state <= rst_state;
    else
        current_state <= next_state;
end

endmodule


module data_path (Clock, Reset, Go, Divisor, Dividend, 
                  ld_1, ld_2, Quotient, Remainder);

input logic Clock, Reset, ld_1, ld_2, Go;
input logic [3:0] Divisor, Dividend;
output logic [3:0] Quotient, Remainder;

// Registers
logic [3:0] R_1, R_2, shift_out_2;
logic [4:0] R_A, alu_out, shift_out_A;
logic A5;

// Loading register logic
always_ff @(posedge Clock)
begin
    if(Reset)
    begin
        R_1 <= 4'b0;
        R_2 <= 4'b0;
        R_A <= 5'b0;
    end
    else
    begin
        if (ld_1) R_1 <= Divisor;
        R_2 <= ld_2 ? Dividend : shift_out_2;
        if (~(ld_1 & ld_2)) R_A <= A5 ? shift_out_A : alu_out;
    end

    if (Go) R_A <= 5'b0;
end

// ALU
logic [4:0] alu_temp;
always_comb
begin
    alu_temp = R_A << 1;
    alu_temp[0] = R_2[3];
    alu_out = alu_temp - {1'b0, R_1};
end
assign A5 = alu_out[4];

// Shifting
always_comb
begin
    if (A5 == 1'b1) 
    begin
        shift_out_A = R_A << 1;
        shift_out_2 = R_2 << 1;
    end
    else 
    begin
        shift_out_2 = R_2 << 1;
        shift_out_2[0] = 1'b1;
    end

    shift_out_A[0] = R_2[3];
end

// Assigning values to outputs
always_comb
begin
    if (Reset || Go)
    begin
        Quotient = 4'b0;
        Remainder = 4'b0; 
    end
    else if (~(ld_1 & ld_2))
    begin
        Quotient = R_2;
        Remainder = R_A;
    end
end

endmodule