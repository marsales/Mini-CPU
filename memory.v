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

    // OUTPUTS ///////////////////
    output [15:0] v1RAM, v2RAM,
    output reg stored
);

    // ESTADOS DA CPU ///////////////
    parameter OFF = 3'b000,
              FETCH = 3'b001,
              DECODE = 3'b010,
              CALC = 3'b011,
              DISPLAY_STORE = 3'100;

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

    reg [3:0] addrL1, addrL2, addrE; // Endereços

    integer i;


    always @ (posedge clk) begin
        // Quando precisar escrever algo na RAM
        if (stateCPU == STORE) begin
            
            case(opcode)
                LOAD: ram[addr1] <= valorGuardarRAM;
                ADD: ram[addr3] <= valorGuardarRAM;
                ADDI: ram[addr2] <= valorGuardarRAM;
                SUB: ram[addr3] <= valorGuardarRAM;
                SUBI: ram[addr2] <= valorGuardarRAM;
                MUL: ram[addr2] <= valorGuardarRAM;
                CLEAR: for (i = 0; i < 16; i = i + 1) ram[i] <= 16'b0000000000000000;
            
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

  
    always @ (stateRAM) begin

        case(stateRAM)

            WRITEONLY: begin
                ram[addrE] <= valorGuardarRAM;
            end

            READANDWRITE: begin
                ram[addrE] <= valorGuardarRAM;
                v1RAM <= ram[addrL1];
                v2RAM <= ram[addrL2];

            end
            
            RESET: begin
                for (i = 0; i < 16; i = i + 1) ram[i] <= 16'b0000000000000000;
            end
                
            READONLY: begin
                v1RAM <= ram[addrL1];
            end
            

        endcase
        
    end
    ////////////////////////////////////////////

endmodule
