// Banco de memória virtual
module memory (
    // INPUTS ////////////////////
    input [3:0] addr1,
    input [3:0] addr2,
    input [3:0] addr3,
    input [2:0] opcode,
    input [15:0] valorGuardarRAM,
    input [2:0] stateCPU,
    input clk,
    //////////////////////////////

    // OUTPUTS ///////////////////
    output [15:0] v1RAM, 
	 output [15:0] v2RAM,
    output stored, read, cleared
    //////////////////////////////
);

	 reg [15:0] v1RAMReg;
	 reg [15:0] v2RAMReg;

	 reg storedReg;
	 reg readReg;
	 reg clearedReg;
	 
    // ESTADOS DA CPU //////////
    parameter OFF = 3'b000,
              FETCH = 3'b001,
              DECODE = 3'b010,
              READ = 3'b011,
              CALC = 3'b100,
				  WAIT = 3'b101,
				  STORE = 3'b110,
              SHOW = 3'b111;


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

    integer i;
	 integer j;
	 
	 initial begin
		storedReg <= 1'b0;
		readReg <= 1'b0;
		clearedReg <= 1'b0;
	 end


    always @ (posedge clk) begin

        // Quando o estado da CPU for READ
        if (stateCPU == READ) begin

            case(opcode)
                ADD: begin
                    v1RAMReg <= ram[addr1];
                    v2RAMReg <= ram[addr2];
                end
                ADDI: v1RAMReg <= ram[addr1];
                SUB: begin
                    v1RAMReg <= ram[addr1];
                    v2RAMReg <= ram[addr2];
                end
                SUBI: v1RAMReg <= ram[addr1];
                MUL: v1RAMReg <= ram[addr1];
                DISPLAY: v1RAMReg <= ram[addr1];

                default: begin end // Para quando for LOAD ou CLEAR (não ler nada)
     

            endcase
				
				readReg <= 1'b1;

        end
        /* Quando a CPU mudar de estado de READ para CALC,
        o read vai resetar para 0 novamente, e só voltará
        a ser 1 quando uma nova leitura for realizada
        */
        else readReg <= 1'b0;
    
        
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
                CLEAR: for (i = 0; i < 16; i = i + 1) ram[i] <= 16'b0000000000000000;
            
                default: begin end // Para quando for DISPLAY (não guardar nada)

                
            endcase
				
				storedReg <= 1'b1;
        end
		  
		  
		  else if (stateCPU == OFF && ~clearedReg) begin
		  
			 for (j = 0; j < 16; j = j + 1) ram[j] <= 16'b0000000000000000;
		  
		  end
		  
		 
		  
		  /* Quando a CPU mudar de estado de STORE para SHOW,
        o stored vai resetar para 0 novamente, e só voltará
        a ser 1 quando uma nova operação for realizada
        */
		  
		  else if (stateCPU == FETCH) begin
				storedReg <= 1'b0;
				clearedReg <= 1'b0;
				
		  end
		  
		  
		  
    end
	 
	 
	 
	 assign stored = storedReg;
	 assign read = readReg;
	 assign cleared = clearedReg;
	 
	 assign v2RAM = v2RAMReg;
	 assign v1RAM = v1RAMReg;
	


endmodule
