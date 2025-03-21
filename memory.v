// Banco de memória virtual
module memory (
    // INPUTS ////////////////////
    input [3:0] addr1,
    input [3:0] addr2,
    input [3:0] addr3,
    input [2:0] opcode,
    input [15:0] valorGuardarRAM,
    input enviar,
    //////////////////////////////

    // OUTPUTS ///////////////////
    output [15:0] v1RAM, v2RAM
    //////////////////////////////
);

    // ESTADOS DA RAM ///////////////
    /*
        OBS: Em todos os estados, a leitura é realizada
    */
    parameter WRITE = 2'b00,
              RESET = 2'b01,
              READONLY = 2'b10;
    //////////////////////////////

    // ESTADOS DA CPU ////////
    parameter LOAD = 3'b000,
              ADD = 3'b001,
              ADDI = 3'b010,
              SUB = 3'b011,
              SUBI = 3'b100,
              MUL = 3'b101,
              CLEAR = 3'b110,
              DISPLAY = 3'b111;
    ///////////////////////////

    
    // REGS /////////////////////

    // Variável da RAM
    reg [15:0] ram [15:0];

    // Estado da RAM
    reg [1:0] stateRAM;

    reg [3:0] addrL1, addrL2, addrE;

    /////////////////////////////

    integer i;


    always @ (posedge enviar) begin
        case(opcode)

            LOAD: begin
                addrE <= addr1;
                stateRAM <= WRITE;
            end

            ADD: begin
                addrL1 <= addr1;
                addrL2 <= addr2;
                addrE <= addr3;
                stateRAM <= WRITE;
            end

            ADDI: begin
                addrL1 <= addr1;
                addrE <= addr2;
                stateRAM <= WRITE;
            end

            SUB: begin
                addrL1 <= addr1;
                addrL2 <= addr2;
                addrE <= addr3;
                stateRAM <= WRITE;
            end

            SUBI: begin
                addrL1 <= addr1;
                addrE <= addr2;
                stateRAM <= WRITE;
            end

            MUL: begin
                addrL1 <= addr1;
                addrE <= addr2;
                stateRAM <= WRITE;
            end

            CLEAR: stateRAM <= RESET;
            
            DISPLAY: begin
                addrL1 <= addr1;
                stateRAM <= READONLY;
            end

        endcase
    end

    // SEGUNDO ALWAYS - SAÍDA ///////////////////
    always @ (posedge enviar) begin

        case(stateRAM)
            WRITE: begin
                v1RAM <= ram[addrL1];
                v2RAM <= ram[addrL2];
                ram[addrE] <= valorGuardarRAM;
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
