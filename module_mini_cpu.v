module module_mini_cpu (
    // INPUTS ////////////////
    input [2:0] opcode,
    input [3:0] addr1,
    input [3:0] addr2,
    input [6:0] addr3OuImm, // São os mesmos switches pro addr3 e o Imm
    input ligar, enviar, clk
    ///////////////////////////

    // OUTPUTS ////////////////

    output reg [15:0] result;

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


    // A MODIFICAR
    // RAM ////////////////////////////////////
    memory memoriaRAM (
        .addr1(addr1),
        .addr2(addr2),
        .addr3(addr3OuImm[6:3]),
        .opcode(opcodeReg),
        .valorGuardarRAM(valorGuardarULA),
        .clk(clk),
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
        .clk(clk),
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

    always @ (posedge enviar, posedge ligar, posedge clk, negedge enviar, negedge ligar) begin

        case(state)

        FETCH: begin
            // Se LIGAR estiver sendo apertado
            if (~ligar && ligarPush == 1'b1) ligarPush <= 1'b0;

            // Se LIGAR estiver sendo solto
            if (ligar && ligarPush == 1'b0) begin
                ligarPush <= 1'b1;
                state <= OFF;
            end

            // Se ENVIAR estiver sendo apertado
            if (~enviar && enviarPush == 1'b1) enviarPush <= 1'b0;

            // Se ENVIAR estiver sendo solto
            if (enviar && enviarPush == 1'b0) begin
                enviarPush <= 1'b1;
                opcodeReg <= opcode;
                state <= DECODE;
            end
        end

        DECODE: begin
            // Se LIGAR estiver sendo apertado
            if (~ligar && ligarPush == 1'b1) ligarPush <= 1'b0;

            // Se LIGAR estiver sendo solto
            else if (ligar && ligarPush == 1'b0) begin
                ligarPush <= 1'b1;
                state <= OFF;
            end

            else begin
                result <= valorGuardarULA;
                state <= DISPLAY_STORE;
            end
        end

        DISPLAY_STORE: begin
        
            // Se LIGAR estiver sendo apertado
            if (~ligar && ligarPush == 1'b1) ligarPush <= 1'b0;

            // Se LIGAR estiver sendo solto
            else if (ligar && ligarPush == 1'b0) begin
                ligarPush <= 1'b1;
                state <= OFF;
            end

            else begin

                module lcd(
                    .opcode(opcodeReg),
                    .result(result),
                    .clk(clk),
                );
            
            end



        end

        endcase
    end

        

