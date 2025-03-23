module module_mini_cpu (
    // INPUTS ////////////////
    input [2:0] opcode,
    input [3:0] addr1,
    input [3:0] addr2,
    input [6:0] addr3OuImm, // São os mesmos switches pro addr3 e o Imm
    input ligar, enviar, clk
    ///////////////////////////

    // OUTPUTS ////////////////

    // Falta adicionar os outputs (relativos ao LCD)

    ///////////////////////////
);

    // ESTADOS
    parameter OFF = 2'b00,
              FETCH = 2'b01,
              DECODE = 2'b10,
              DISPLAY_STORE = 2'b11;

    // OPERAÇÕES ///////////////
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

    wire [15:0] resultadoULA; // Joga o resultado da operação da ULA para a RAM e o LCD

    wire [15:0] v1RAMpULALCD, v2RAMpULALCD; // Joga os valores guardados na RAM para a ULA e o LCD

    ///////////////////////////////////////////////////////


    // REGS ///////////////////////////////////////////////

    reg [1:0] state; // Estado da CPU

    reg enviarPush, ligarPush;

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
        state <= FETCH;
        enviarPush <= 1'b1;
        ligarPush <= 1'b1;
    end
    /////////////////////////////////////////


    // PRIMEIRO ALWAYS - ESTADO PRÓXIMO ///////////////////
    always @ (posedge enviar, posedge ligar, posedge clk, negedge enviar, negedge ligar) begin

        case(state)

        FETCH: begin
            // Se LIGAR estiver sendo apertado
            if (~ligar && ligarPush == 1'b1) ligarPush <= 1'b0;

            // Se LIGAR estiver sendo solto
            if

            // Se ENVIAR estiver sendo apertado
            if (~enviar && enviarPush == 1'b1) enviarPush <= 1'b0;

            // Se ENVIAR estiver sendo solto
            if (enviar && enviarPush == 1'b0) begin
                enviarPush <= 1'b1;
                opcodeReg <= opcode;
                state <= DECODE;
            end

        DECODE: begin

        end


        end

        endcase


        /// nao alterei ainda a partir daq
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
