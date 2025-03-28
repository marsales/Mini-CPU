module module_mini_cpu (
    // INPUTS ////////////////
    input [2:0] opcode,
    input [3:0] addr1,
    input [3:0] addr2,
    input [6:0] addr3OuImm, // São os mesmos switches pro addr3 e o Imm
    input ligar, enviar, clk,
    ///////////////////////////

    // OUTPUTS ////////////////
    output [15:0] result,
	 output on,
	 output [2:0] estado
    ///////////////////////////
);

    // ESTADOS DA CPU //////////
    parameter OFF = 3'b000,
              FETCH = 3'b001,
              DECODE = 3'b010,
              READ = 3'b011,
              CALC = 3'b100,
              SHOW = 3'b101,
              STORE = 3'b110;


    // OPERAÇÕES ///////////////
    parameter LOAD = 3'b000,
              ADD = 3'b001,
              ADDI = 3'b010,
              SUB = 3'b011,
              SUBI = 3'b100,
              MUL = 3'b101,
              CLEAR = 3'b110,
              DISPLAY = 3'b111;



    wire [15:0] resultadoULA; // Joga o resultado da operação da ULA para a RAM e o LCD

    wire [15:0] v1RAMpULALCD, v2RAMpULALCD; // Joga os valores guardados na RAM para a ULA e o LCD

    reg [2:0] state = OFF; // Estado da CPU

    reg ligarApertou, enviarApertou; // Verificar ENVIAR e LIGAR

    reg [2:0] opcodeReg; // Guardar opcode
	 reg [3:0] addr1Reg;
	 reg [3:0] addr2Reg;
	 reg [6:0] addr3OuImmReg;

	 
	 
	 reg onReg;
	 reg [15:0] resultReg;
	 reg [2:0] estadoReg;
	 
	 

    // VERIFICAÇÕES //////////////////////////////////////////////////
    wire decoded; // Verifica se a ULA já descobriu qual é a operação
    wire calculated; // Verifica se a ULA já realizou a operação
    wire stored; // Verifica se a RAM já armazenou o resultado final
    wire read; // Verifica se a RAM já realizou as leituras necessárias



    // RAM ////////////////////////////////////
    memory memoriaRAM (
		  // ENTRADAS
        .addr1(addr1Reg),
        .addr2(addr2Reg),
        .addr3(addr3OuImmReg[6:3]),
        .opcode(opcodeReg),
        .valorGuardarRAM(valorGuardarULA),
		  .stateCPU(state),
        .clk(clk),
		  // SAÍDAS
        .v1RAM(v1RAMpULALCD),
        .v2RAM(v2RAMpULALCD),
        .stored(stored),
        .read(read)
    );

    // ULA /////////////////////////////////
    module_alu ula (
		  // ENTRADAS
        .opcode(opcodeReg),
        .sinalImm(addr3OuImmReg[6]),
        .Imm(addr3OuImmReg[5:0]),
        .v1ULA(v1RAM),
        .v2ULA(v2RAM),
        .clk(clk),
		  .stateCPU(state),
		  // SAÍDAS
        .valorGuardarULA(resultadoULA),
        .decoded(decoded),
        .calculated(calculated)
    );
	 
	/*
    // LCD ///////////////////////////////
    lcd instLCD (
        .opcode(opcodeReg),
        .result(result),
        .clk(clk)
    );
	 */

    // INICIALIZAÇÃO ////////////////////////
    initial begin
        state <= OFF;
    end
	 

    always @ (posedge clk) begin

        case(state)
		  
		  
		 
            FETCH: begin    
               
					 
					 // ---------------------- ENVIAR ---------------------- //
					
					  // Se estiver apertando ENVIAR
					  if (~enviar) enviarApertou <= 1'b1;
								
					  // Se LIGAR estiver solto
					  else begin
								
							// Se tiver apertado ENVIAR
							if (enviarApertou) begin
									enviarApertou <= 1'b0;
									opcodeReg <= opcode;
									addr1Reg <= addr1;
									addr2Reg <= addr2;
									addr3OuImmReg <= addr3OuImm;
									state <= DECODE;
							end
					  end
					
					// --------------------------------------------------- //
					 
					 
					 
					 onReg <= 1'b0;
					 
					 
			
					 
					 estadoReg <= state;
					 
            end
				
				
				
				
				
				

            DECODE: begin
				
					 
					 if (decoded) state <= READ;
					 
					 onReg <= 1'b0;
					 
	
					 
					 estadoReg <= state;
            end
				
				
				
				
				
					
				

            READ: begin
				
          
	
                if (read) state <= CALC;
						
                
					 
					 onReg <= 1'b0;
					 
	
					 
					 estadoReg <= state;
					 
            end
				
				
				
				
				
				
				

            CALC: begin
				
					 
					 
	 
					 
					if (calculated) state <= SHOW;
						 
					 
					 
					 onReg <= 1'b0;
					 
			
					 
					 estadoReg <= state;
                
            end
				
				
				
				
				

            SHOW: begin



				    // A saída da CPU recebe o resultado da operação que vem da ULA
				    resultReg <= valorGuardarULA;

				    // Lógica do LCD //
					  
				    ///////////////////

				    state <= STORE;
					  
                    
                
					 
					 onReg <= 1'b0;
					 
		
					 
					 estadoReg <= state;
            end
				
				
				
				

            STORE: begin
				 
				
					if (stored) state <= FETCH;
				
					
					onReg <= 1'b0;
                
					 
					 
					estadoReg <= state;
				end
            

            OFF: begin
					 
					 onReg <= 1'b1;
					 
					 estadoReg <= state;
		
            end
				
				

        endcase
		  
		  // ---------------------- LIGAR ---------------------- //
					
		  // Se estiver apertando LIGAR
		  if (~ligar) ligarApertou <= 1'b1;
					
		  // Se LIGAR estiver solto
		  else begin
					
				// Se tiver apertado LIGAR
				if (ligarApertou) begin
							ligarApertou <= 1'b0;
							if (state == OFF) state <= FETCH;
							else state <= OFF;
				end
		  end
					
			// --------------------------------------------------- //
		  
		
		  
    end
	 
	 assign on = onReg;
	 assign result = resultReg;
	 assign estado = estadoReg;
	 
endmodule
