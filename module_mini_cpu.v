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
    parameter OFF = 3'b000,
              FETCH = 3'b001,
              DECODE = 3'b010,
              CALC = 3'b011,
              DISPLAY = 3'100,
              STORE = 3'101;

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

    reg [2:0] state; // Estado da CPU

    reg enviarPush, ligarPush;

    reg [2:0] opcodeReg;

    reg decoded; // Verifica se a ULA já descobriu qual é a operação
    reg calculated; // Verifica se a ULA já realizou a operação
    reg stored // Verifica se a RAM já armazenou o resultado final

    ///////////////////////////////////////////////////////


    // RAM ////////////////////////////////////
    memory memoriaRAM (
        .addr1(addr1),
        .addr2(addr2),
        .addr3(addr3OuImm[6:3]),
        .opcode(opcodeReg),
        .valorGuardarRAM(valorGuardarULA),
        .clk(clk),
        .v1RAM(v1RAMpULALCD),
        .v2RAM(v2RAMpULALCD),
        .stored(stored)
    );

    // ULA /////////////////////////////////
    module_alu ula (
        .opcode(opcodeReg),
        .sinalImm(addr3OuImm[6]),
        .Imm(addr3OuImm[5:0]),
        .v1ULA(v1RAM),
        .v2ULA(v2RAM),
        .clk(clk),
        .valorGuardarULA(resultadoULA),
        .decoded(decoded),
        .calculated(calculated)
    );

    // LCD ///////////////////////////////
    lcd instLCD (
        .opcode(opcodeReg),
        .result(result),
        .clk(clk)
    );

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

            // Se a ULA descobriu a operação, fazer o cálculo
            else begin
                if (decoded) state <= CALC;
            end
        end

        CALC: begin

            // Se LIGAR estiver sendo apertado
            if (~ligar && ligarPush == 1'b1) ligarPush <= 1'b0;

            // Se LIGAR estiver sendo solto
            else if (ligar && ligarPush == 1'b0) begin
                ligarPush <= 1'b1;
                state <= OFF;
            end

            else begin
                // Se a ULA realizou a operação, ir para DISPLAY_STORE
                if (calculated) state <= DISPLAY_STORE;
            end
        end

        DISPLAY: begin
        
            // Se LIGAR estiver sendo apertado
            if (~ligar && ligarPush == 1'b1) ligarPush <= 1'b0;

            // Se LIGAR estiver sendo solto
            else if (ligar && ligarPush == 1'b0) begin
                ligarPush <= 1'b1;
                state <= OFF;
            end

            else begin

                // A saída da CPU recebe o resultado da operação que vem da ULA
                result <= valorGuardarULA;

                // Lógica do LCD //

                ///////////////////

                state <= STORE;
                
            end
        end

        STORE: begin

            // Se LIGAR estiver sendo apertado
            if (~ligar && ligarPush == 1'b1) ligarPush <= 1'b0;

            // Se LIGAR estiver sendo solto
            else if (ligar && ligarPush == 1'b0) begin
                ligarPush <= 1'b1;
                state <= OFF;
            end
        
            else begin
                if (stored)
            end
        end

        OFF: begin

            // Se LIGAR estiver sendo apertado
            if (~ligar && ligarPush == 1'b1) ligarPush <= 1'b0;

            // Se LIGAR estiver sendo solto
            else if (ligar && ligarPush == 1'b0) begin
                ligarPush <= 1'b1;
                state <= FETCH;
            end

            else begin

                

            end
        end

        endcase
    end
endmodule
        

