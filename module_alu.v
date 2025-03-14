module module_alu (
    input [2:0] opcode,
    input [15:0] valor1,
    input [15:0] valor2
    input clk
);

    // OPERAÇÕES DA CPU
    parameter LOAD = 3'b000,
              ADD = 3'b001,
              ADDI = 3'b010,
              SUB = 3'b011,
              SUBI = 3'b100,
              MUL = 3'b101,
              CLEAR = 3'b110,
              DISPLAY = 3'b111;

    // OPERAÇÕES DA ULA
    parameter SOMA = 2'00,
              SUBTRACAO = 2'b01,
              MULTIPLICACAO = 2'b10,
              NADA = 2'b11;

    reg [2:0] state;

    // Primeiro always -> Estado próximo
    always @ (posedge clk) begin

        case(opcode)
            ADD: state <= SOMA;
            ADDI: state <= SOMA;
            SUB: state <= SUBTRACAO;
            SUBI: state <= SUBTRACAO;
            MUL: state <= MULTIPLICACAO;
            default: state <= NADA;
        endcase
        
    end

    // Segundo always -> Saída

endmodule
