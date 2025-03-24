// Banco de memória virtual
module memory (
    // INPUTS ////////////////////
    input [3:0] addr1,
    input [3:0] addr2,
    input [3:0] addr3,
    input [2:0] opcode,
    input [15:0] valorGuardarRAM,
    input [1:0] stateCPU,
    input clk,
    //////////////////////////////

    // OUTPUTS ///////////////////
    output reg [15:0] v1RAM, v2RAM,
    output reg stored, read
    //////////////////////////////
);

    // ESTADOS DA CPU //////////
    parameter OFF = 3'b000,
              FETCH = 3'b001,
              DECODE = 3'b010,
              READ = 3'b011,
              CALC = 3'b100,
              DISPLAY = 3'b101,
              STORE = 3'b110;


    // OPCODES /////////////////
    parameter LOAD = 3'b000,
              ADD = 3'b001,
              ADDI = 3'b010,
              SUB = 3'b011,
              SUBI = 3'b100,
              MUL = 3'b101,
              CLEAR = 3'b110,
              DISPLAY = 3'b111;

    
    // VARIÁVEIS ////////////////////////////
    reg [15:0] ram [15:0]; // Variável da RAM

    reg [1:0] stateRAM; // Estado da RAM

    integer i;


    always @ (posedge clk) begin

        // Quando o estado da CPU for READ
        if (stateCPU == READ) begin

            case(opcode)
                ADD: begin
                    v1RAM <= ram[addr1];
                    v2RAM <= ram[addr2];
                end
                ADDI: v1RAM <= ram[addr1];
                SUB: begin
                    v1RAM <= ram[addr1];
                    v2RAM <= ram[addr2];
                end
                SUBI: v1RAM <= ram[addr1];
                MUL: v1RAM <= ram[addr1];
                DISPLAY: v1RAM <= ram[addr1];

                default begin end // Para quando for LOAD ou CLEAR (não ler nada)
        
                read <= 1'b1;

            endcase

        end
        /* Quando a CPU mudar de estado de READ para CALC,
        o read vai resetar para 0 novamente, e só voltará
        a ser 1 quando uma nova leitura for realizada
        */
        else read <= 1'b0;
    
        
    end


    always @ (posedge clk) begin

        // Quando o estado da CPU for STORE
        if (stateCPU == STORE) begin
            
            case(opcode)
                LOAD: ram[addr1] <= valorGuardarRAM;
                ADD: ram[addr3] <= valorGuardarRAM;
                ADDI: ram[addr2] <= valorGuardarRAM;
                SUB: ram[addr3] <= valorGuardarRAM;
                SUBI: ram[addr2] <= valorGuardarRAM;
                MUL: ram[addr2] <= valorGuardarRAM;
                CLEAR: for (i = 0; i < 16; i = i + 1) ram[i] <= 16'b000000000
            
                default begin end // Para quando for DISPLAY (não guardar nada)

                stored <= 1'b1;
            endcase
        end

        /* Quando a CPU mudar de estado de STORE para FETCH,
        o stored vai resetar para 0 novamente, e só voltará
        a ser 1 quando uma nova operação for realizada
        */
        else stored <= 1'b0;
    end


endmodule
