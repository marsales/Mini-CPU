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
	 output on, botao,
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

    reg ligarApertou; // Verificar ENVIAR e LIGAR

    reg [2:0] opcodeReg; // Guardar opcode

	 
	 
	 reg onReg;
	 reg [15:0] resultReg;
	 reg botaoReg;
	 reg [2:0] estadoReg;
	 reg inicio;
	 
	 

    // VERIFICAÇÕES //////////////////////////////////////////////////
    wire decoded; // Verifica se a ULA já descobriu qual é a operação
    wire calculated; // Verifica se a ULA já realizou a operação
    wire stored; // Verifica se a RAM já armazenou o resultado final
    wire read; // Verifica se a RAM já realizou as leituras necessárias



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
        .stored(stored),
        .read(read)
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
		  botaoReg <= 1'b0;
    end
	 

    always @ (posedge clk) begin

        case(state)
		  
		  
		 
            FETCH: begin    
               
					 
					 /*

                // Se ENVIAR estiver solto E ainda não verificou soltura
                if (enviar && ~enviarSolto) begin
                    enviarSolto <= 1'b1;
                    opcodeReg <= opcode;
                    state <= DECODE;
                end
					 
					 // Se ENVIAR estiver apertado OU se já verificou soltura
					 if (~enviar && enviarSolto) enviarSolto <= 1'b0;
	
					 */
					 onReg <= 1'b0;
					 
					 
					 if (ligar) botaoReg <= 1'b0;
					 else botaoReg <= 1'b1;
					 
					 estadoReg <= state;
					 
            end
				
				
				
				
				
				

            DECODE: begin
				
 
					 
					 if (decoded) state <= READ;
					 
					 onReg <= 1'b0;
					 
					 
					 if (ligar) botaoReg <= 1'b0;
					 else botaoReg <= 1'b1;
					 
					 estadoReg <= state;
            end
				
				
				
				
				
					
				

            READ: begin
				
              
					
	
                if (read) state <= CALC;
						
                
					 
					 onReg <= 1'b0;
					 
					 if (ligar) botaoReg <= 1'b0;
					 else botaoReg <= 1'b1;
					 
					 estadoReg <= state;
					 
            end
				
				
				
				
				
				
				

            CALC: begin
				
					 
					 
	 
					 
					if (calculated) state <= SHOW;
						 
					 
					 
					 onReg <= 1'b0;
					 
					 if (ligar) botaoReg <= 1'b0;
					 else botaoReg <= 1'b1;
					 
					 estadoReg <= state;
                
            end
				
				
				
				
				

            SHOW: begin



				    // A saída da CPU recebe o resultado da operação que vem da ULA
				    resultReg <= valorGuardarULA;

				    // Lógica do LCD //
					  
				    ///////////////////

				    state <= STORE;
					  
                    
                
					 
					 onReg <= 1'b0;
					 
					 if (ligar) botaoReg <= 1'b0;
					 else botaoReg <= 1'b1;
					 
					 
					 estadoReg <= state;
            end
				
				
				
				

            STORE: begin
				 
				
					if (stored) state <= FETCH;
				
					
					onReg <= 1'b0;
					
					if (ligar) botaoReg <= 1'b0;
					else botaoReg <= 1'b1;
                
					 
					 
					estadoReg <= state;
				end
            

            OFF: begin
					 
					 onReg <= 1'b1;
					 if (ligar) botaoReg <= 1'b0;
					 else botaoReg <= 1'b1;
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
	 assign botao = botaoReg;
	 assign estado = estadoReg;
	 
	 /*
	    // Se LIGAR estiver solto OU for inicio E entrou agora no estado
					 if ((ligar || inicio) && entrouAgoraEstado) begin
							entrouAgoraEstado <= 1'b0;
							inicio <= 1'b0;
					 end
					 
				
				
                // Se LIGAR estiver apertado E não entrou agora no estado
                else if (~ligar && ~entrouAgoraEstado) begin
                    ligarApertou <= 1'b1;
                end
					 
		
					 // Se LIGAR estiver solto E não entrou agora no estado E LIGAR foi apertado
					 else if (ligar && ~entrouAgoraEstado && ligarApertou) begin
							ligarApertou <= 1'b0;
							entrouAgoraEstado <= 1'b1;
							state <= FETCH;
					 end
	 */
	 
	 
endmodule
