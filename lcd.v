module lcd (
    input [2:0] opcode,
    input [15:0] result,
    input [3:0] reg1, reg2, reg3,
    input [3:0] estadoCpu,
    input clk,

    output reg EN, RW, RS,
    output reg shown,
    output reg [7:0] data
);

    // estado da CPU para mostrar o display
    parameter SHOW = 3'b101;
    parameter OFF = 3'b000;

    // OPCODES ////////
    parameter LOAD = 3'b000,
              ADD = 3'b001,
              ADDI = 3'b010,
              SUB = 3'b011,
              SUBI = 3'b100,
              MUL = 3'b101,
              CLEAR = 3'b110,
              DISPLAY = 3'b111;
    ///////////////////////////

    

    parameter MS = 50_000;
    parameter WRITE = 0, WAIT = 1;
    reg state = WRITE;

    reg [7:0] instructions = 0;
    reg [31:0] counter = 0;
    reg [7:0] d_milhar, milhar, centena, dezena, unidade, dm, m, c, d, u;
    reg sinal;


    initial begin
        d_milhar = 0;
        milhar = 0; 
        centena = 0; 
        dezena = 0; 
        unidade = 0;
        sinal = 0;
        EN = 0;
        RW = 0;
        RS = 0;
        data = 0;
        shown = 0;
    end


    always @(posedge clk) begin

        if (estadoCpu == OFF) begin 

            case(state)

                WRITE: begin
                    if(counter == MS - 1) begin
                        counter <= 0;
                        state <= WAIT;
                    end
                    else counter <= counter + 1;
                end

                WAIT : begin
                    if(counter == MS - 1) begin
                        counter <= 0;
                        state <= WRITE;
                        if (instructions < 1) instructions <= instructions + 1;

                    end
                    else counter <= counter + 1;

                end
                default: begin end
            endcase


        end

        else if (estadoCpu == SHOW && ~shown) begin

            case(state)

                WRITE: begin
                    if(counter == MS - 1) begin
                        counter <= 0;
                        state <= WAIT;
                    end
                    else counter <= counter + 1;
                end

                WAIT: begin
                    if(counter == MS - 1) begin
                        counter <= 0;
                        state <= WRITE;

                        if (opcode != LOAD) begin 
                            if (instructions < 38) instructions <= instructions + 1;

                        end
                    end
                    else counter <= counter + 1;

                end
                default: begin end
            endcase
        end

    end

    

    always @(posedge clk) begin

        if (estadoCpu == OFF) begin 

            case (state)
                WRITE: EN <= 1;
                WAIT: EN <= 0;
                default: EN <= EN;
            endcase

            case (instructions) 

                1: begin data <= 8'h08; RS <= 0; end // apaga

            endcase


        end

        else if (estadoCpu == SHOW && ~shown) begin

            case (state)
                WRITE: EN <= 1;
                WAIT: EN <= 0;
                default: EN <= EN;
            endcase

            if (opcode != LOAD) begin

                unidade <= result[14:0] % 10;             // Obtém a unidade
                dezena <= (result[14:0] / 10) % 10;       // Obtém a dezena
                centena <= (result[14:0] / 100) % 10;     // Obtém a centena
                milhar <= (result[14:0] / 1000) % 10;     // Obtém o milhar
                d_milhar <= (result[14:0] / 10000) % 10;  // Obtém a dezena de milhar
                sinal <= result[15];                      // bit de sinal

              

                case (instructions)
                    
                    1: begin data <= 8'h38; RS <= 0; end // seta duas linhas
                    2: begin data <= 8'h0E; RS <= 0; end // ativa o cursor
                    3: begin data <= 8'h01; RS <= 0; end // limpa o display
                    4: begin data <= 8'h02; RS <= 0; end // home
                    5: begin data <= 8'h06; RS <= 0; end // home de vdd

                    // operação de addi ou subi escrita (4 letras)
                    6: begin 
                        if (opcode == ADDI || opcode == ADD) begin data <= 8'h41; RS <= 1; end // A
                        else if (opcode == SUBI || opcode == SUB) begin data <= 8'h53; RS <= 1; end // S
                        else if (opcode == MUL) begin data <= 8'h4D; RS <= 1; end // M
                        else if (opcode == DISPLAY) begin data <= 8'h44; RS <= 1; end // D
                        else if (opcode == CLEAR) begin data <= 8'h43; RS <= 1; end   // C
                    end 
                        

                    7: begin 
                        if (opcode == ADDI || opcode == ADD) begin data <= 8'h44; RS <= 1; end // D 
                        else if (opcode == SUBI || opcode == SUB || opcode == MUL) begin data <= 8'h55; RS <= 1; end // U 
                        else if (opcode == DISPLAY) begin data <= 8'h50; RS <= 1; end // P
                        else if (opcode == CLEAR) begin data <= 8'h4C; RS <= 1; end // L          
                    end


                    8:  begin 
                        if (opcode == ADDI || opcode == ADD) begin data <= 8'h44; RS <= 1; end // D 
                        else if (opcode == SUB || opcode == SUBI) begin data <= 8'h42; RS <= 1; end // B
                        else if (opcode == MUL || opcode == DISPLAY) begin data <= 8'h4C; RS <= 1; end // L
                        else if (opcode == CLEAR) begin data <= 8'h45; RS <= 1; end // E
                    end

                    9: begin 
                        if (opcode == ADDI || opcode == SUBI) begin data <= 8'h44; RS <= 1; end   // I
                        else if (opcode == CLEAR) begin data <= 8'h41; RS <= 1; end // A
                        else begin data <= 8'h20; RS <= 1; end                                    // espaço para os casos que a operação tem três letras
                    end
        

                    // espaços (6 deles)
                    10: begin
                        if(opcode == CLEAR) begin data <= 8'h52; RS <= 1; end // R             
                        else begin data <= 8'h20; RS <= 1; end // espaço
                    end

                    11: begin data <= 8'h20; RS <= 1; end // espaço
                    12: begin data <= 8'h20; RS <= 1; end // espaço
                    13: begin data <= 8'h20; RS <= 1; end // espaço
                    14: begin data <= 8'h20; RS <= 1; end // espaço
                    15: begin data <= 8'h20; RS <= 1; end // espaço
                       

                    // qual registrador print
                    16: begin 
                        if (opcode == CLEAR) begin data <= 8'h20; RS <= 1; end // espaço
                        else begin data <= 8'h5B; RS <= 1; end // [ 
                    end

                    17: begin 

                        if (opcode == ADD || opcode == SUB) begin
                            data <= reg3[0]; RS <= 1;
                        end

                        else if (opcode == ADDI || opcode == SUBI || opcode == MUL) begin 
                            data <= reg2[0]; RS <= 1;
                        end

                        else if (opcode == DISPLAY) begin
                            data <= reg1[0]; RS <= 1;
                        end

                        else if (opcode == CLEAR) begin 
                            data <= 8'h20; RS <= 1;     // espaço
                        end 

                    end

                    18: begin

                        if (opcode == ADD || opcode == SUB) begin
                            data <= reg3[1]; RS <= 1;
                        end

                        else if (opcode == ADDI || opcode == SUBI || opcode == MUL) begin 
                            data <= reg2[1]; RS <= 1;
                        end

                        else if (opcode == DISPLAY) begin
                            data <= reg1[1]; RS <= 1;
                        end

                        else if (opcode == CLEAR) begin 
                            data <= 8'h20; RS <= 1;     // espaço
                        end 

                    end

                    19: begin 
                        if (opcode == ADD || opcode == SUB) begin
                            data <= reg3[2]; RS <= 1;
                        end

                        else if (opcode == ADDI || opcode == SUBI || opcode == MUL) begin 
                            data <= reg2[2]; RS <= 1;
                        end

                        else if (opcode == DISPLAY) begin
                            data <= reg1[2]; RS <= 1;
                        end

                        else if (opcode == CLEAR) begin 
                            data <= 8'h20; RS <= 1;     // espaço
                        end 
                    end

                    20: begin 

                        if (opcode == ADD || opcode == SUB) begin
                            data <= reg3[3]; RS <= 1;
                        end

                        else if (opcode == ADDI || opcode == SUBI || opcode == MUL) begin 
                            data <= reg2[3]; RS <= 1;
                        end

                        else if (opcode == DISPLAY) begin
                            data <= reg1[3]; RS <= 1;
                        end

                        else if (opcode == CLEAR) begin 
                            data <= 8'h20; RS <= 1;     // espaço
                        end 
                    end

                    21: begin 
                        if (opcode == CLEAR) begin data <= 8'h20; RS <= 1; end // espaço
                        else begin data <= 8'h5D; RS <= 1; end // ]
                    end



                    // pula linha
                    22: begin data <= 8'hC0; RS <= 0; end 



                    // espaços linha 2 (10 deles)
                    23: begin data <= 8'h20; RS <= 1; end // espaço
                    24: begin data <= 8'h20; RS <= 1; end // espaço
                    25: begin data <= 8'h20; RS <= 1; end // espaço
                    26: begin data <= 8'h20; RS <= 1; end // espaço
                    27: begin data <= 8'h20; RS <= 1; end // espaço
                    28: begin data <= 8'h20; RS <= 1; end // espaço
                    29: begin data <= 8'h20; RS <= 1; end // espaço
                    30: begin data <= 8'h20; RS <= 1; end // espaço
                    31: begin data <= 8'h20; RS <= 1; end // espaço
                    32: begin data <= 8'h20; RS <= 1; end // espaço

                    // sinal do resultado
                    33: begin 

                        if (opcode == CLEAR) begin data <= 8'h20; RS <= 1; end // espaço
                        else begin
                            if (sinal == 0) begin  data <= 8'h2B; RS <= 1; end       // +
                            else begin data <= 8'h2D; RS <= 1; end                   // -
                        end
                    end

                    // módulo do resultado
                    34: begin 
                        if (opcode == CLEAR) begin data <= 8'h20; RS <= 1; end // espaço
                        else begin data <= 8'h30 + d_milhar; RS <= 1; end
                    end
                    35: begin 
                        if (opcode == CLEAR) begin data <= 8'h20; RS <= 1; end // espaço
                        else begin data <= 8'h30 + milhar; RS <= 1; end
                    end
                    36: begin 
                        if (opcode == CLEAR) begin data <= 8'h20; RS <= 1; end // espaço
                        else begin data <= 8'h30 + centena; RS <= 1; end
                    end
                    37: begin 
                        if (opcode == CLEAR) begin data <= 8'h20; RS <= 1; end // espaço
                        else begin data <= 8'h30 + dezena; RS <= 1; end
                    end
                    38: begin 
                        if (opcode == CLEAR) begin data <= 8'h20; RS <= 1; end // espaço
                        else begin data <= 8'h30 + unidade; RS <= 1; end
                    end

                    default: begin data <= 8'h02; RS <= 0; end // volta para home
                
                endcase                
            end
        end

        shown <= 1;

    end

endmodule
