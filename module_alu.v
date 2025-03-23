module module_alu (
    // INPUTS //////////////////////
    input [2:0] opcode,
    input sinalImm,
    input [5:0] Imm,
    input [15:0] v1ULA,
    input [15:0] v2ULA,
    input clk,
    /////////////////////////////////

    // OUTPUTS /////////////////////
    output [15:0] valorGuardarULA
    ////////////////////////////////
);

    // ESTADOS /////////////////
    parameter LOAD = 3'b000,
              ADD = 3'b001,
              ADDI = 3'b010,
              SUB = 3'b011,
              SUBI = 3'b100,
              MUL = 3'b101,
              CLEAR = 3'b110,
              DISPLAY = 3'b111;
    ////////////////////////////

    // REGS ////////////////////

    reg [2:0] state; // Estado da ULA

    ////////////////////////////

    // PRIMEIRO ALWAYS - ESTADO PRÓXIMO ////////////
    always @ (posedge clk) begin
        /*
            Esse always altera o estado da ULA
        */
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
    /////////////////////////////////////////////////

    // SEGUNDO ALWAYS - SAÍDA /////////////////////////////////////
    always @ (state) begin
        /*
            Esse always produz a saída da ULA;
            ou seja, o resultado da operação
        */
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

            // Se for DISPLAY, nada será guardado na RAM
            DISPLAY: valorGuardarULA <= valorGuardar;
        endcase
    end
    //////////////////////////////////////////////////////////////

endmodule
