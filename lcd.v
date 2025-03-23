module lcd (
    input [2:0] opcode,
    input [15:0] result,
    input clk,

    output reg EN, RW, RS,
    output reg [15:0] data
);


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
                        // if (instructions < 10) ??? FALTA FAZER!

                    end
                end
                else counter <= counter + 1;

            end
    


            default: begin end
        endcase
    end

    

    always @(posedge clk) begin
   
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

            endcase


        end

        else if (opcode != LOAD) begin

            unidade = result % 10;             // Obtém a unidade
            dezena = (result / 10) % 10;       // Obtém a dezena
            centena = (result / 100) % 10;     // Obtém a centena
            milhar = (result / 1000) % 10;     // Obtém o milhar
            d_milhar = (result / 10000) % 10; // Obtém a dezena de milhar

            case (instructions)
                1: begin data <= 8'h0E; RS <= 0; end // ativa o cursor
                2: begin data <= 8'h01; RS <= 0; end // limpa o display
                3: begin data <= 8'h02; RS <= 0; end // home
                4: begin data <= 8'h06; RS <= 0; end // home de vdd

                ///// FALTA COISA AQUI NO MEIO, ESSA É A EXIBIÇÃO APENAS DO RESULTADO E NÃO DO RESTO (mudar os numeros das instruções e add as outras coisas)
                5: begin data <= 8'h30 + d_milhar; RS <= 1; end
                6: begin data <= 8'h30 + milhar; RS <= 1; end
                7: begin data <= 8'h30 + centena; RS <= 1; end
                8: begin data <= 8'h30 + dezena; RS <= 1; end
                9: begin data <= 8'h30 + unidade; RS <= 1; end


                default: begin data <= 8'h02; RS <= 0; end
           
            endcase

        end



    end




endmodule