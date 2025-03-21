module module_mini_cpu (
    // INPUTS ////////////////
    input [2:0] opcode,
    input [3:0] addr1,
    input [3:0] addr2,
    input [6:0] addr3OuImm, // São os mesmos switches pro addr3 e o Imm
    input ligar, enviar
    ///////////////////////////

    // OUTPUTS ////////////////

    // Falta adicionar os outputs (relativos ao LCD)

    ///////////////////////////
);

    // ESTADOS ///////////////
    parameter LOAD = 3'b000,
              ADD = 3'b001,
              ADDI = 3'b010,
              SUB = 3'b011,
              SUBI = 3'b100,
              MUL = 3'b101,
              CLEAR = 3'b110,
              DISPLAY = 3'b111;
    ///////////////////////////


    // WIRES //////////////////////////////////////////////

    // Joga o resultado da operação da ULA para a RAM e o LCD
    wire [15:0] resultadoULA;

    // Joga os valores guardados na RAM para a ULA e o LCD
    wire [15:0] v1RAMpULALCD, v2RAMpULALCD;

    ///////////////////////////////////////////////////////


    // REGS ///////////////////////////////////////////////

    // Estado da CPU
    reg [2:0] state;

    // Registrar opcode após soltar botão "enviar"
    reg [2:0] opcodeReg;

    ///////////////////////////////////////////////////////


    // RAM ////////////////////////////////////
    memory memoriaRAM (
        .addr1(addr1),
        .addr2(addr2),
        .addr3(addr3OuImm[6:3]),
        .opcode(opcodeReg),
        .valorGuardarRAM(valorGuardarULA),
        .enviar(enviar),
        .v1RAM(v1RAMpULALCD),
        .v2RAM(v2RAMpULALCD)
    );
    ////////////////////////////////////////////


    // ULA /////////////////////////////////
    module_alu ula (
        .opcode(opcodeReg),
        .sinalImm(addr3OuImm[6]),
        .Imm(addr3OuImm[5:0]),
        .v1ULA(v1RAM),
        .v2ULA(v2RAM),
        .enviar(enviar),
        .valorGuardarULA(resultadoULA)
    );
    /////////////////////////////////////////


    // INICIALIZAÇÃO ////////////////////////
    initial begin
    end
    /////////////////////////////////////////


    // PRIMEIRO ALWAYS - ESTADO PRÓXIMO ///////////////////
    always @ (posedge enviar) begin
        /*
            Esse always mudará o estado de acordo com:
                - O opcode atual
                - O botão "enviar"
        */
        case(opcode)
            LOAD: begin 
                state <= LOAD;
            end
            ADD: begin 
                state <= ADD;
            end
            ADDI: begin
                state <= ADDI;
            end
            SUB: begin 
                state <= SUB;
            end
            SUBI: begin 
                state <= SUBI;
            end
            MUL: begin 
                state <= MUL;
            end
            CLEAR: begin 
                state <= CLEAR;
            end
            DISPLAY: begin 
                state <= DISPLAY;
            end
        endcase

        // Guardar opcode
        opcodeReg <= opcode;
    end
    ///////////////////////////////////////////////////


    // SEGUNDO ALWAYS - SAÍDA /////////////////////////
    always @ (state) begin
    /*
        Esse always controlará o que é mostrado no LCD de acordo com:
            - O estado atual
            - O botão "ligar"
    */
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
    /////////////////////////////////////////////////////
    
endmodule
