module module_alu (
    // INPUTS //////////////////////
    input [2:0] opcode,
    input sinalImm,
    input [5:0] Imm,
    input [15:0] v1ULA,
    input [15:0] v2ULA,
    input [1:0] stateCPU,
    input clk,
    /////////////////////////////////

    // OUTPUTS /////////////////////
    output [15:0] valorGuardarULA,
    output reg decoded,
    output reg calculated
    ////////////////////////////////
);

    // ESTADOS DA CPU ////////
    parameter OFF = 3'b000,
              FETCH = 3'b001,
              DECODE = 3'b010,
              READ = 3'b011,
              CALC = 3'b100,
              DISPLAY = 3'101,
              STORE = 3'110;

    // OPERAÇÕES /////////////////
    parameter LOAD = 3'b000,
              ADD = 3'b001,
              ADDI = 3'b010,
              SUB = 3'b011,
              SUBI = 3'b100,
              MUL = 3'b101,
              CLEAR = 3'b110,
              DISPLAY = 3'b111;

    reg [2:0] state; // Estado da ULA


    always @ (posedge clk) begin

        // Quando o estado for para DECODE, descobrir qual é a operação
        if (stateCPU == DECODE) begin
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
            decoded <= 1'b1;
        end
        
        /* Quando a CPU mudar de estado de DECODE para CALC,
        o decoded vai resetar para 0 novamente, e só voltará
        a ser 1 quando uma nova instrução for decodificada
        */
        else decoded <= 1'b0;
    end

    
    always @ (posedge clk) begin
        
        // Só fará o cálculo quando a CPU estiver no estado CALC
        if (stateCPU == CALC) begin
            case(state)
                // Se for LOAD, apenas armazenar Imm
                LOAD: valorGuardarULA <= {sinalImm, Imm}; 

                ADD: valorGuardarULA <= v1ULA + v2ULA;

                ADDI: begin
                    // Se Imm for negativo, vira subtração
                    if (sinalImm) valorGuardarULA <= v1ULA - Imm;
                    else valorGuardarULA <= v1ULA + Imm;
                end

                SUB: valorGuardarULA <= v1ULA - v2ULA;

                SUBI: begin
                    // Se Imm for negativo, vira soma
                    if (sinalImm) valorGuardarULA <= v1ULA + Imm;
                    else valorGuardarULA <= v1ULA - Imm;
                end

                MUL: begin
                    // Se Imm for negativo, troca o sinal do resultado
                    if (sinalImm) valorGuardarULA <= v1ULA * Imm * -1;
                    else valorGuardarULA <= v1ULA * Imm;
                end

                // Se for CLEAR, resetar a RAM com todos os registradores iguais a zero
                CLEAR: valorGuardarULA <= 16'b0000000000000000;

                // Se for DISPLAY, nada será guardado na RAM (verificar isso depois)
                DISPLAY: valorGuardarULA <= valorGuardarULA;
            endcase

            calculated <= 1'b1;
        end

        /* Quando a CPU mudar de estado de CALC para DISPLAY_STORE,
        o calculated vai resetar para 0 novamente, e só voltará
        a ser 1 quando um novo cálculo for realizado
        */
        else calculated <= 1'b0;
    end

endmodule
