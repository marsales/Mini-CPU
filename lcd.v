module lcd (
    input [2:0] opcode,
    input [15:0] result,
    input [3:0] reg1, reg2, reg3;
    input [3:0] estadoCpu;
    input clk,

    output reg EN, RW, RS,
    output reg [15:0] data
);

    // estado da CPU para ligar o display
    parameter SHOW = 3'b101;

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


    initial begin
        d_milhar = 0;
        milhar = 0; 
        centena = 0; 
        dezena = 0; 
        unidade = 0;
        EN = 0;
        RW = 0;
        RS = 0;
        data = 0;
    end


    always @(posedge clk) begin

        if(estadoCpu == SHOW) begin
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

                        if (opcode == CLEAR) begin
                            if (instructions < 10) instructions <= instructions + 1;
                        end

                        else if (opcode != LOAD) begin 
                            // if (instructions < ???) instyructions <= instructions + 1; ??? FALTA FAZER!

                        end
                    end
                    else counter <= counter + 1;

                end
                default: begin end
            endcase
        end

    end

    

    always @(posedge clk) begin

        if (estadoCpu == SHOW) begin

            case (state)
            WRITE: EN <= 1;
            WAIT: EN <= 0;
            default: EN <= EN;
            endcase

            if (opcode == CLEAR) begin 
                case (instructions)
                    1: begin data <= 8'h38; RS <= 0; end // seta duas linhas
                    2: begin data <= 8'h0E; RS <= 0; end // ativa o cursor
                    3: begin data <= 8'h01; RS <= 0; end // limpa o display
                    4: begin data <= 8'h02; RS <= 0; end // home
                    5: begin data <= 8'h06; RS <= 0; end // home de vdd


                    6: begin data <= 8'h43; RS <= 1; end // C
                    7: begin data <= 8'h4C; RS <= 1; end // L
                    8: begin data <= 8'h45; RS <= 1; end // E
                    9: begin data <= 8'h41; RS <= 1; end // A
                    10: begin data <= 8'h52; RS <= 1; end // R

                    default: begin data <= 8'h02; RS <= 0; end // volta para home

                endcase


            end

            else if (opcode != LOAD) begin

                    unidade <= result % 10;             // Obtém a unidade
                    dezena <= (result / 10) % 10;       // Obtém a dezena
                    centena <= (result / 100) % 10;     // Obtém a centena
                    milhar <= (result / 1000) % 10;     // Obtém o milhar
                    d_milhar <= (result / 10000) % 10;  // Obtém a dezena de milhar

              

                case (instructions)

                    1: begin data <= 8'h0E; RS <= 0; end // ativa o cursor
                    2: begin data <= 8'h01; RS <= 0; end // limpa o display
                    3: begin data <= 8'h02; RS <= 0; end // home
                    4: begin data <= 8'h06; RS <= 0; end // home de vdd

                    // operação de addi ou subi escrita (4 letras)
                    5: begin 
                        if (opcode == ADDI || opcode == ADD) data <= 8'h41; RS <= 1; // A
                        else if (opcode == SUBI || opcode == SUB) data <= 8'h53; RS <= 1; // S
                        else if (opcode == MUL) data <= 8'h4D; RS <= 1; // M
                        else if (opcode == DISPLAY) data <= 8'h44; RS <= 1; // D
                        end 

                    6: begin 
                        if (opcode == ADDI || opcode == ADD) data <= 8'h44; RS <= 1; // D 
                        else if (opcode == SUBI || opcode == SUB || opcode == MUL) data <= 8'h55; RS <= 1; // U 
                        else if (opcode == DISPLAY) data <= 8'h50; RS <= 1; // P
                        
                    end


                    7:  begin 
                        if (opcode == ADDI || opcode == ADD) data <= 8'h44; RS <= 1; // D 
                        else if (opcode == SUB || opcode == SUBI) data <= 8'h42; RS <= 1; // B
                        else if (opcode == MUL || opcode == DISPLAY) data <= 8'h4C; RS <= 1; // L
                    end

                    8: begin 
                        if (opcode == ADDI || opcode == SUBI) data <= 8'h44; RS <= 1; // I
                    end
        

                    // espaços
                    9: begin data <= 8'h20; RS <= 1; end // espaço
                    10: begin data <= 8'h20; RS <= 1; end // espaço
                    11: begin data <= 8'h20; RS <= 1; end // espaço
                    12: begin data <= 8'h20; RS <= 1; end // espaço
                    13: begin data <= 8'h20; RS <= 1; end // espaço
                    14: begin 
                        if (opcode == ADD || opcode == SUB || opcode == MUL || opcode == DISPLAY) data <= 8'h20; RS <= 1;  // espaço
                        end 


                    // qual registrador print
                    15: begin data <= 8'h5B; RS <= 1; end // [

                    16: begin 

                        if (opcode == ADD || opcode == SUB) begin
                            data <= reg3[0]; RS <= 1;
                        end

                        else if (opcode == ADDI || opcode == SUBI || opcode == MUL) begin 
                            data <= reg2[0]; RS <= 1;
                        end

                        else if (opcode == DISPLAY) begin
                            data <= reg1[0]; RS <= 1;
                         end

                    end

                    17: begin

                        if (opcode == ADD || opcode == SUB) begin
                            data <= reg3[1]; RS <= 1;
                        end

                        else if (opcode == ADDI || opcode == SUBI || opcode == MUL) begin 
                            data <= reg2[1]; RS <= 1;
                        end

                        else if (opcode == DISPLAY) begin
                            data <= reg1[1]; RS <= 1;
                         end

                    end

                    18:begin 
                        if (opcode == ADD || opcode == SUB) begin
                            data <= reg3[2]; RS <= 1;
                        end

                        else if (opcode == ADDI || opcode == SUBI || opcode == MUL) begin 
                            data <= reg2[2]; RS <= 1;
                        end

                        else if (opcode == DISPLAY) begin
                            data <= reg1[2]; RS <= 1;
                         end
                    end

                    19: begin 

                        if (opcode == ADD || opcode == SUB) begin
                            data <= reg3[3]; RS <= 1;
                        end

                        else if (opcode == ADDI || opcode == SUBI || opcode == MUL) begin 
                            data <= reg2[3]; RS <= 1;
                        end

                        else if (opcode == DISPLAY) begin
                            data <= reg1[3]; RS <= 1;
                         end
                    end

                    20: begin data <= 8'h5D; RS <= 1; end // ]

                    // pula linha
                    21: begin data <= 8'hC0; RS <= 0; end 


                    // espaços linha 2 (10 deles)
                    22: begin data <= 8'h20; RS <= 1; end // espaço
                    23: begin data <= 8'h20; RS <= 1; end // espaço
                    24: begin data <= 8'h20; RS <= 1; end // espaço
                    25: begin data <= 8'h20; RS <= 1; end // espaço
                    26: begin data <= 8'h20; RS <= 1; end // espaço
                    27: begin data <= 8'h20; RS <= 1; end // espaço
                    28: begin data <= 8'h20; RS <= 1; end // espaço
                    29: begin data <= 8'h20; RS <= 1; end // espaço
                    30: begin data <= 8'h20; RS <= 1; end // espaço
                    31: begin data <= 8'h20; RS <= 1; end // espaço


                    // resultado
                    //: begin data <= 8'h30 + d_milhar; RS <= 1; end
                    //: begin data <= 8'h30 + milhar; RS <= 1; end
                    //: begin data <= 8'h30 + centena; RS <= 1; end
                    //: begin data <= 8'h30 + dezena; RS <= 1; end
                    //: begin data <= 8'h30 + unidade; RS <= 1; end


















                        default: begin data <= 8'h02; RS <= 0; end // volta para home
                
                endcase
                
            end
        end



    end




endmodule
