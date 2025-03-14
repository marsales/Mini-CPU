module module_mini_cpu (
    input [2:0] opcode,
    input [3:0] src1,
    input [3:0] src2,
    input sinalImm,
    input [5:0] Imm
    input [3:0] dest,
    input clk,
    input ligar, enviar
);

    // OPERAÇÕES
    parameter LOAD = 3'b000,
              ADD = 3'b001,
              ADDI = 3'b010,
              SUB = 3'b011,
              SUBI = 3'b100,
              MUL = 3'b101,
              CLEAR = 3'b110,
              DISPLAY = 3'b111;

    reg [2:0] state;

    // Primeiro always -> Estado próximo
    always @ (posedge clk) begin

        case(opcode)

            LOAD: state <= LOAD;
            ADD: state <= ADD;
            ADDI: state <= ADDI;
            SUB: state <= SUB;
            SUBI: state <= SUBI;
            MUL: state <= MUL;
            CLEAR: state <= CLEAR;
            DISPLAY: state <= DISPLAY;

        endcase

    end

    // Segundo always -> Saída
    

endmodule
