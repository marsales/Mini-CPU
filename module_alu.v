module module_alu (
    input [2:0] opcode,
    input [15:0] valor1,
    input [15:0] valor2,
    input sinalImm,
    input [5:0] Imm,
    input clk,
    output [15:0] saida
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
        endcase
        
    end

    // Segundo always -> Saída
    always @ (posedge clk) begin

        case(state)
            LOAD: saida <= Imm;
            ADD: saida <= valor1 + valor2;
            ADDI: begin
                if (sinalImm) saida <= valor1 - Imm;
                else saida <= valor1 + Imm;
            end
            SUB: saida <= valor1 - valor2;
            SUBI: begin
                if (sinalImm) saida <= valor1 + Imm;
                else saida <= valor1 - Imm;
            end
            MUL: begin
                if (sinalImm) saida <= -1 * valor1 * Imm;
                else saida <= valor1 * Imm;
            end
            CLEAR: saida <= 0;
            DISPLAY: saida <= valor1;
        endcase

    end

endmodule
