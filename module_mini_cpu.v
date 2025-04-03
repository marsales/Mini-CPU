module module_mini_cpu (
    input [2:0] opcode,
    input [3:0] addr1,
    input [3:0] addr2,
    input [6:0] addr3OuImm, // São os mesmos switches pro addr3 e o Imm
    input ligar, enviar, clk,
    ///////////////////////////

    // OUTPUTS ////////////////
    output [15:0] result,
	 output on,
	 output [2:0] estado,
	 output reg EN, RW, RS,
	 output reg [7:0] saidaLCD
    ///////////////////////////
	 
);

    // ESTADOS DA CPU //////////
    parameter OFF = 3'b000,
              FETCH = 3'b001,
              DECODE = 3'b010,
              READ = 3'b011,
              CALC = 3'b100,
			     ESPERA = 3'b101,
			     STORE = 3'b110,
              SHOW = 3'b111;
 
				  
    // OPERAÇÕES ///////////////
    parameter LOAD = 3'b000,
              ADD = 3'b001,
              ADDI = 3'b010,                                             
              SUB = 3'b011,
              SUBI = 3'b100,
              MUL = 3'b101,                                                               
              CLEAR = 3'b110,
              DISPLAY = 3'b111;

    
	 // VARIÁVEIS DO LCD --------------------------------------------------
	 parameter MS = 50_000;
    parameter WRITE = 0, WAIT = 1;
    reg stateLCD = WRITE;
    reg [7:0] instructions = 0;
    reg [31:0] counter = 0;
    reg [7:0] d_milhar, milhar, centena, dezena, unidade, dm, m, c, d, u;
    reg sinal;		  
		

	 // VARIÁVEIS DA CPU -------------------------------------------------
    wire [15:0] resultadoULA; 
    wire [15:0] v1RAMpULALCD, v2RAMpULALCD; 
    reg [2:0] state = OFF;
    reg ligarApertou, enviarApertou; 
	 reg done;
	 reg doneligou;
	 reg ligou;
    
	 
	 // REGISTRADORES DOS SWITCHES --------------------------------
	 reg [2:0] opcodeReg; 
	 reg [3:0] addr1Reg;
	 reg [3:0] addr2Reg;
	 reg [6:0] addr3OuImmReg;
	 
	 
	 // REGISTRADORES DE DEBUG -----------------------------------
	 reg onReg;
	 reg [2:0] estadoReg;
	 
	 // REGISTRADORES DE RESULTADO ------------------------------
	 reg signed [15:0] valorAbs;
	 reg signed [15:0] resultReg;
	 
	 
	 

    // VERIFICAÇÕES --------------------------------------
    wire decoded;
    wire calculated;
    wire stored;
    wire read;
	 wire cleared;



    // RAM ////////////////////////////////////
    memory memoriaRAM (
		  // ENTRADAS
        .addr1(addr1Reg),
        .addr2(addr2Reg),
        .addr3(addr3OuImmReg[6:3]),
        .opcode(opcodeReg),
        .valorGuardarRAM(resultadoULA),
		  .stateCPU(state),
        .clk(clk),
		  // SAÍDAS
        .v1RAM(v1RAMpULALCD),
        .v2RAM(v2RAMpULALCD),
        .stored(stored),
        .read(read),
		  .cleared(cleared)
    );





    // ULA /////////////////////////////////
    module_alu ula (
		  // ENTRADAS
        .opcode(opcodeReg),
        .sinalImm(addr3OuImmReg[6]),
        .Imm(addr3OuImmReg[5:0]),
        .v1ULA(v1RAMpULALCD),
        .v2ULA(v2RAMpULALCD),
        .clk(clk),
		  .stateCPU(state),
		  // SAÍDAS
        .valorGuardarULA(resultadoULA),
        .decoded(decoded),
        .calculated(calculated)
    );




	
	 
    // INICIALIZAÇÃO ////////////////////////
    initial begin
        state <= OFF;
        d_milhar <= 0;
        milhar <= 0; 
        centena <= 0; 
        dezena <= 0; 
        unidade <= 0;
        sinal <= 0;
        EN <= 0;
        RW <= 0;
        RS <= 0;
        saidaLCD <= 0;
		  done <= 0;
		  
		  ligou <= 0;
		  doneligou <= 0;
    end
	 




    always @ (posedge clk) begin

        case(state)
		 
            FETCH: begin   
				
				
					 // ---------------------- ENVIAR ---------------------- //
					
					  // Se estiver apertando ENVIAR
					  if (~enviar) enviarApertou <= 1'b1;
								
					  // Se ENVIAR estiver solto
					  else begin
								
							// Se tiver apertado ENVIAR
							if (enviarApertou) begin
									enviarApertou <= 1'b0;
									opcodeReg <= opcode;
									addr1Reg <= addr1;
									addr2Reg <= addr2;
									addr3OuImmReg <= addr3OuImm;
	
							
									if (ligou) begin 
										state <= DECODE;
									end
									else begin 
										state <= DECODE;
									end
									
									
							end
							
						
							
							
								
					  end
					  
					
					// --------------------------------------------------- //
					 
					 
					 
					 onReg <= 1'b0;
					 
					 estadoReg <= state;
					 
            end
				
				
				
			
            DECODE: begin		
				
					 ligou <= 0;
					 
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
					 	 
					if (calculated) state <= ESPERA;
					 
					onReg <= 1'b0;
					
					estadoReg <= state;
                
            end
				
				
				
				
				
				ESPERA: begin
				
					state <= STORE;
				
				end
				
				
				
				
				STORE: begin
				
					if (stored) state <= SHOW;
				
					onReg <= 1'b0;
                
					estadoReg <= state;
					
				end
				
				

            SHOW: begin

				    resultReg <= resultadoULA;
					 
					 if (done) state <= FETCH;
                 
					 onReg <= 1'b0;
	
					 estadoReg <= state;
            end
				
				

            OFF: begin 
					 
					 onReg <= 1'b1;
					 
					 estadoReg <= state;
					 
					 resultReg <= 16'b0000000000000000;
		
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
						if (state == OFF) begin
							
							state <= FETCH;
							ligou <= 1;
							
						end
						else begin
							state <= OFF;
						end
				end
		  end
					
			// --------------------------------------------------- //
		  
		
		  
    end


	 
	 
	 
	 
	 


    // LCD -----------------------------------------------------------
    always @ (posedge clk) begin
	 
		  // OFF ----------------------------- //
        if (state == OFF) begin 

            case(stateLCD)

                WRITE: begin
                    if (counter == MS - 1) begin
                        counter <= 0;
                        stateLCD <= WAIT;
                    end
                    else counter <= counter + 1;
                end

                WAIT : begin
                    if(counter == MS - 1) begin
                        counter <= 0;
                        stateLCD <= WRITE;
                        if (instructions <=  1) instructions <= instructions + 1;
								else begin 
                            instructions <= 0;
									 
                        end
								

                    end
                    else counter <= counter + 1;

                end
                default: begin end
            endcase

        end
		    

		  // SHOW 
        else if (state == SHOW) begin

            case(stateLCD)

                WRITE: begin
                    if(counter == MS - 1) begin
                        counter <= 0;
                        stateLCD <= WAIT;
                    end
                    else counter <= counter + 1;
                end

                WAIT: begin
                    if(counter == MS - 1) begin
                        counter <= 0;
                        stateLCD <= WRITE;

                
                        if (instructions < 40) instructions <= instructions + 1;
                        else begin 
								    done <= 1;
                            instructions <= 0;
                        end
                       
                    end
                    else counter <= counter + 1;

                end
                default: begin end
            endcase
        end
		  
		   
		  else if (ligou && state == FETCH) begin

            case(stateLCD)

                WRITE: begin
                    if(counter == MS - 1) begin
                        counter <= 0;
                        stateLCD <= WAIT;
                    end
                    else counter <= counter + 1;
                end

                WAIT: begin
                    if(counter == MS - 1) begin
                        counter <= 0;
                        stateLCD <= WRITE;

                
                        if (instructions < 40) instructions <= instructions + 1;
                        else begin 
								    doneligou <= 1;
                            instructions <= 0;
                        end
                       
                    end
                    else counter <= counter + 1;

                end
                default: begin end
            endcase
        end
		  
		  
		  
		  else if (state == FETCH) begin
				done <= 0;
            instructions <= 0;
				stateLCD <= WRITE;
				counter <= 0;
		  end
		  
		  else if (state == DECODE) begin
				doneligou <= 0;
		  end
        
	 end

  // ---------------------------------------------------------------------- //


    always @ (posedge clk) begin



		if (state == OFF || state == STORE) begin 

			 case (stateLCD)
				  WRITE: EN <= 1;
				  WAIT: EN <= 0;
				  default: EN <= EN;
			 endcase

			 case (instructions) 

				  1: begin saidaLCD <= 8'h08; RS <= 0; end // apaga

			 endcase


		end
		
		
		else if (ligou && ~doneligou) begin
		
		
			case (stateLCD)
				  WRITE: EN <= 1;
				  WAIT: EN <= 0;
				  default: EN <= EN;
			endcase


			 

		   case (instructions)
						
				1: begin saidaLCD <= 8'h38; RS <= 0; end // seta duas linhas
				2: begin saidaLCD <= 8'h0E; RS <= 0; end // ativa o cursor
				3: begin saidaLCD <= 8'h01; RS <= 0; end // limpa o display
				4: begin saidaLCD <= 8'h02; RS <= 0; end // home
				5: begin saidaLCD <= 8'h06; RS <= 0; end // home de vdd

						
				6: begin saidaLCD <= 8'h2D; RS <= 1; end
				7: begin saidaLCD <= 8'h2D; RS <= 1; end
				8: begin saidaLCD <= 8'h2D; RS <= 1; end
				9: begin saidaLCD <= 8'h2D; RS <= 1; end
							
							 
						 
		
				10: begin saidaLCD <= 8'h20; RS <= 1; end // espaço


				11: begin saidaLCD <= 8'h20; RS <= 1; end // espaço
				12: begin saidaLCD <= 8'h20; RS <= 1; end // espaço
				13: begin saidaLCD <= 8'h20; RS <= 1; end // espaço
				14: begin saidaLCD <= 8'h20; RS <= 1; end // espaço
				15: begin saidaLCD <= 8'h20; RS <= 1; end // espaço
						

						
				16: begin saidaLCD <= 8'h5B; RS <= 1; end // [ 
				
				
				17: begin saidaLCD <= 8'h2D; RS <= 1; end
				18: begin saidaLCD <= 8'h2D; RS <= 1; end
				19: begin saidaLCD <= 8'h2D; RS <= 1; end
				20: begin saidaLCD <= 8'h2D; RS <= 1; end
				

				21: begin saidaLCD <= 8'h5D; RS <= 1; end // ]
	



				// pula linha
				22: begin saidaLCD <= 8'hC0; RS <= 0; end 



				// espaços linha 2 (10 deles)
				23: begin saidaLCD <= 8'h20; RS <= 1; end // espaço
				24: begin saidaLCD <= 8'h20; RS <= 1; end // espaço
				25: begin saidaLCD <= 8'h20; RS <= 1; end // espaço
				26: begin saidaLCD <= 8'h20; RS <= 1; end // espaço
				27: begin saidaLCD <= 8'h20; RS <= 1; end // espaço
				28: begin saidaLCD <= 8'h20; RS <= 1; end // espaço
				29: begin saidaLCD <= 8'h20; RS <= 1; end // espaço
				30: begin saidaLCD <= 8'h20; RS <= 1; end // espaço
				31: begin saidaLCD <= 8'h20; RS <= 1; end // espaço
				32: begin saidaLCD <= 8'h20; RS <= 1; end // espaço
				
				

				// sinal do resultado
				33: begin saidaLCD <= 8'h2B; RS <= 1; end       
								 
							

				// módulo do resultado
				34: begin saidaLCD <= 8'h30; RS <= 1; end
						
				35: begin saidaLCD <= 8'h30; RS <= 1; end
						
				36: begin saidaLCD <= 8'h30; RS <= 1; end
						
				37: begin saidaLCD <= 8'h30; RS <= 1; end
						
				38: begin saidaLCD <= 8'h30; RS <= 1; end
						
				39: begin saidaLCD <= 8'h0C; RS <= 0; end
			endcase
		
		end
		

		else if (state == SHOW) begin

			 case (stateLCD)
				  WRITE: EN <= 1;
				  WAIT: EN <= 0;
				  default: EN <= EN;
			 endcase


				  sinal <= resultReg < 0;

				  valorAbs = resultReg < 0 ? -resultReg : resultReg;

              unidade  <= valorAbs % 10;
              dezena   <= (valorAbs / 10) % 10;
              centena  <= (valorAbs / 100) % 10;
              milhar   <= (valorAbs / 1000) % 10;
              d_milhar <= (valorAbs / 10000) % 10;

			 

				  case (instructions)
						
						1: begin saidaLCD <= 8'h38; RS <= 0; end // seta duas linhas
						2: begin saidaLCD <= 8'h0E; RS <= 0; end // ativa o cursor
						3: begin saidaLCD <= 8'h01; RS <= 0; end // limpa o display
						4: begin saidaLCD <= 8'h02; RS <= 0; end // home
						5: begin saidaLCD <= 8'h06; RS <= 0; end // home de vdd

						// operação de addi ou subi escrita (4 letras)
						6: begin 
							 if (opcodeReg == ADDI || opcodeReg == ADD) begin saidaLCD <= 8'h41; RS <= 1; end // A
							 else if (opcodeReg == SUBI || opcodeReg == SUB) begin saidaLCD <= 8'h53; RS <= 1; end // S
							 else if (opcodeReg == MUL) begin saidaLCD <= 8'h4D; RS <= 1; end // M
							 else if (opcodeReg == DISPLAY) begin saidaLCD <= 8'h44; RS <= 1; end // D
							 else if (opcodeReg == CLEAR) begin saidaLCD <= 8'h43; RS <= 1; end   // C
							 else if (opcodeReg == LOAD) begin saidaLCD <= 8'h4C; RS <= 1; end   // L
							
							 
						end 
							 

						7: begin 
							 if (opcodeReg == ADDI || opcodeReg == ADD) begin saidaLCD <= 8'h44; RS <= 1; end // D 
							 else if (opcodeReg == SUBI || opcodeReg == SUB || opcodeReg == MUL) begin saidaLCD <= 8'h55; RS <= 1; end // U 
							 else if (opcodeReg == DISPLAY) begin saidaLCD <= 8'h50; RS <= 1; end // P
							 else if (opcodeReg == CLEAR) begin saidaLCD <= 8'h4C; RS <= 1; end // L  
										else if (opcodeReg == LOAD) begin saidaLCD <= 8'h4F; RS <= 1; end // O								
						end


						8:  begin 
							 if (opcodeReg == ADDI || opcodeReg == ADD) begin saidaLCD <= 8'h44; RS <= 1; end // D 
							 else if (opcodeReg == SUB || opcodeReg == SUBI) begin saidaLCD <= 8'h42; RS <= 1; end // B
							 else if (opcodeReg == MUL || opcodeReg == DISPLAY) begin saidaLCD <= 8'h4C; RS <= 1; end // L
							 else if (opcodeReg == CLEAR) begin saidaLCD <= 8'h45; RS <= 1; end // E
										else if (opcodeReg == LOAD) begin saidaLCD <= 8'h41; RS <= 1; end // A		
						end

						9: begin 
							 if (opcodeReg == ADDI || opcodeReg == SUBI) begin saidaLCD <= 8'h49; RS <= 1; end   // I
							 else if (opcodeReg == CLEAR) begin saidaLCD <= 8'h41; RS <= 1; end // A
										else if (opcodeReg == LOAD) begin saidaLCD <= 8'h44; RS <= 1; end // D	
							 else begin saidaLCD <= 8'h20; RS <= 1; end                                    // espaço para os casos que a operação tem três letras
												  
						end
		

						// espaços (6 deles)
						10: begin
							 if(opcodeReg == CLEAR) begin saidaLCD <= 8'h52; RS <= 1; end // 
										else if (opcodeReg == LOAD) begin saidaLCD <= 8'h20; RS <= 1; end   //load fica vazio										
							 else begin saidaLCD <= 8'h20; RS <= 1; end // espaço
						end

						11: begin saidaLCD <= 8'h20; RS <= 1; end // espaço
						12: begin saidaLCD <= 8'h20; RS <= 1; end // espaço
						13: begin saidaLCD <= 8'h20; RS <= 1; end // espaço
						14: begin saidaLCD <= 8'h20; RS <= 1; end // espaço
						15: begin saidaLCD <= 8'h20; RS <= 1; end // espaço
						

						// qual registrador print
						16: begin 
							 if (opcodeReg == CLEAR) begin saidaLCD <= 8'h20; RS <= 1; end // espaço
							 else begin saidaLCD <= 8'h5B; RS <= 1; end // [ 
						end

						17: begin 

							 if (opcodeReg == ADD || opcodeReg == SUB) begin
								  saidaLCD <= addr3OuImmReg[6]?8'h31 : 8'h30; RS <= 1;
							 end

							 else if (opcodeReg == ADDI || opcodeReg == SUBI || opcodeReg == MUL) begin 
								  saidaLCD <= addr2Reg[3]?8'h31 : 8'h30; RS <= 1;
							 end

							 else if (opcodeReg == DISPLAY || opcodeReg == LOAD) begin
								  saidaLCD <= addr1Reg[3]?8'h31 : 8'h30; RS <= 1;
							 end

							 else if (opcodeReg == CLEAR) begin 
								  saidaLCD <= 8'h20; RS <= 1;     // espaço
							 end 

						end

						18: begin

							 if (opcodeReg == ADD || opcodeReg == SUB) begin
								  saidaLCD <= addr3OuImmReg[5]?8'h31 : 8'h30; RS <= 1;
							 end

							 else if (opcodeReg == ADDI || opcodeReg == SUBI || opcodeReg == MUL) begin 
								  saidaLCD <= addr2Reg[2]?8'h31 : 8'h30; RS <= 1;
							 end

							 else if (opcodeReg == DISPLAY || opcodeReg == LOAD) begin
								  saidaLCD <= addr1Reg[2]?8'h31 : 8'h30; RS <= 1;
							 end

							 else if (opcodeReg == CLEAR) begin 
								  saidaLCD <= 8'h20; RS <= 1;     // espaço
							 end 

						end

						19: begin 
							 if (opcodeReg == ADD || opcodeReg == SUB) begin
								  saidaLCD <= addr3OuImmReg[4]?8'h31 : 8'h30; RS <= 1;
							 end

							 else if (opcodeReg == ADDI || opcodeReg == SUBI || opcodeReg == MUL) begin 
								  saidaLCD <= addr2Reg[1]?8'h31 : 8'h30; RS <= 1;
							 end

							 else if (opcodeReg == DISPLAY || opcodeReg == LOAD) begin
								  saidaLCD <= addr1Reg[1]?8'h31 : 8'h30; RS <= 1;
							 end

							 else if (opcodeReg == CLEAR) begin 
								  saidaLCD <= 8'h20; RS <= 1;     // espaço
							 end 
						end

						20: begin 

							 if (opcodeReg == ADD || opcodeReg == SUB) begin
								  saidaLCD <= addr3OuImmReg[3]?8'h31 : 8'h30; RS <= 1;
							 end

							 else if (opcodeReg == ADDI || opcodeReg == SUBI || opcodeReg == MUL) begin 
								  saidaLCD <= addr2Reg[0]?8'h31 : 8'h30; RS <= 1;
							 end

							 else if (opcodeReg == DISPLAY || opcodeReg == LOAD) begin
								  saidaLCD <= addr1Reg[0]?8'h31 : 8'h30; RS <= 1;
							 end

							 else if (opcodeReg == CLEAR) begin 
								  saidaLCD <= 8'h20; RS <= 1;     // espaço
							 end 
						end

						21: begin 
							 if (opcodeReg == CLEAR) begin saidaLCD <= 8'h20; RS <= 1; end // espaço
							 else begin saidaLCD <= 8'h5D; RS <= 1; end // ]
						end



						// pula linha
						22: begin saidaLCD <= 8'hC0; RS <= 0; end 



						// espaços linha 2 (10 deles)
						23: begin saidaLCD <= 8'h20; RS <= 1; end // espaço
						24: begin saidaLCD <= 8'h20; RS <= 1; end // espaço
						25: begin saidaLCD <= 8'h20; RS <= 1; end // espaço
						26: begin saidaLCD <= 8'h20; RS <= 1; end // espaço
						27: begin saidaLCD <= 8'h20; RS <= 1; end // espaço
						28: begin saidaLCD <= 8'h20; RS <= 1; end // espaço
						29: begin saidaLCD <= 8'h20; RS <= 1; end // espaço
						30: begin saidaLCD <= 8'h20; RS <= 1; end // espaço
						31: begin saidaLCD <= 8'h20; RS <= 1; end // espaço
						32: begin saidaLCD <= 8'h20; RS <= 1; end // espaço

						// sinal do resultado
						33: begin 

							 if (opcodeReg == CLEAR) begin saidaLCD <= 8'h20; RS <= 1; end // espaço
							 else begin
								  if (sinal == 0) begin  saidaLCD <= 8'h2B; RS <= 1; end       // +
								  else begin saidaLCD <= 8'h2D; RS <= 1; end                   // -
							 end
						end

						// módulo do resultado
						34: begin 
							 if (opcodeReg == CLEAR) begin saidaLCD <= 8'h20; RS <= 1; end // espaço
							 else begin saidaLCD <= 8'h30 + d_milhar; RS <= 1; end
						end
						35: begin 
							 if (opcodeReg == CLEAR) begin saidaLCD <= 8'h20; RS <= 1; end // espaço
							 else begin saidaLCD <= 8'h30 + milhar; RS <= 1; end
						end
						36: begin 
							 if (opcodeReg == CLEAR) begin saidaLCD <= 8'h20; RS <= 1; end // espaço
							 else begin saidaLCD <= 8'h30 + centena; RS <= 1; end
						end
						37: begin 
							 if (opcodeReg == CLEAR) begin saidaLCD <= 8'h20; RS <= 1; end // espaço
							 else begin saidaLCD <= 8'h30 + dezena; RS <= 1; end
						end
						38: begin 
							 if (opcodeReg == CLEAR) begin saidaLCD <= 8'h20; RS <= 1; end // espaço
							 else begin saidaLCD <= 8'h30 + unidade; RS <= 1; end
						end
						39: begin
							 saidaLCD <= 8'h0C; RS <= 0; 
						
						end

				  
				  endcase  
				  

		end

               
   end
		  

	 
	 assign on = onReg;
	 assign result = resultReg;
	 assign estado = estadoReg;
	 
	 
endmodule
