module module_mini_cpu (
    input [2:0] opcode,
    input [3:0] src1,
    input [3:0] src2,
    input sinalImm,
    input [5:0] Imm
    input [3:0] dest,
    input clk,
    input ligar, enviar,
    input we,

    output [15:0] valorFinal
);

    // Operações
    parameter LOAD = 3'b000,
              ADD = 3'b001,
              ADDI = 3'b010,
              SUB = 3'b011,
              SUBI = 3'b100,
              MUL = 3'b101,
              CLEAR = 3'b110,
              DISPLAY = 3'b111;

    reg [2:0] state;
    reg [15:0] dadosRAM [15:0];
    reg [15:0] leituraRAM;
    reg mostrarNumsLCD = 0 // 0 - Não mostrar, 1 - Mostrar

    // RAM
    memory ram (
        data.(dadosRAM),
        addr1.(src1),
        addr2.(src2),
        dest.(dest),
        we.(we),
        clk.(clk),
        q.(leituraRAM)
    );

    // ULA
    module_alu ula (
        opcode.(opcode),
        valor1.(dadosRAM[src1]),
        valor2.(dadosRAM[src2]),
        clk.(clk),
        saida.(valorFinal)
    );

    // Inicialização
    initial begin
        we <= 0;
        mostrarNumsLCD <= 0;
    end

    // Primeiro always -> Estado próximo
    always @ (posedge enviar) begin

        // Mudar o estado baseado no opcode
        case(opcode)

            LOAD: begin 
                state <= LOAD;
                we <= 1;
                mostrarNumsLCD <= 1;
            end
            ADD: begin 
                state <= ADD;
                we <= 1;
                mostrarNumsLCD <= 1;
            end
            ADDI: begin
                state <= ADDI;
                we <= 1;
                mostrarNumsLCD <= 1;
            end
            SUB: begin 
                state <= SUB;
                we <= 1;
                mostrarNumsLCD <= 1;
            end
            SUBI: begin 
                state <= SUBI;
                we <= 1;
                mostrarNumsLCD <= 1;
            end
            MUL: begin 
                state <= MUL;
                we <= 1;
                mostrarNumsLCD <= 1;
            end
            CLEAR: begin 
                state <= CLEAR;
                we <= 1;
                mostrarNumsLCD <= 0;
            end
            DISPLAY: begin 
                state <= DISPLAY;
                we <= 0;
                mostrarNumsLCD <= 1;
            end

        endcase

    end

    // Segundo always -> Saída
    always @ (posedge clk) begin

        case (state)

            LOAD:
            ADD:
            ADDI:
            SUB:
            SUBI:
            MUL:
            CLEAR:
            DISPLAY:

        endcase

    end
    
endmodule
