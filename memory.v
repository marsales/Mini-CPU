// Banco de memória virtual
module memory (
    input [2:0] opcode,
    input [3:0] addr1,
    input [3:0] addr2,
    input [3:0] dest,
    input sinalImm,
    input [5:0] Imm,

    input we, clk,
    output [15:0] q1, q2,
    output [15:0] qF
);

    // Estados
    parameter READ = 1'b0,
              WRITE = 1'b1;
    
    // 
    reg [3:0] ram [15:0];
    reg state;
    wire [15:0] qF_wire;
    
    // Instanciação da ULA
    module_alu ula (
        .opcode(opcode),
        .valor1(ram[addr1]),
        .valor2(ram[addr2]),
        .sinalImm(sinalImm),
        .Imm(Imm),
        .clk(clk),
        .saida(qF_wire)
    );

    // Primeiro always - Estado próximo
    always @ (posedge clk) begin
        case(state)
            READ: if (we) state <= WRITE;
            WRITE: if (~we) state <= READ;
        endcase
    end

    // Segundo always - Saída
    always @ (state) begin
        READ: begin
            q1 <= ram[addr1];
            q2 <= ram[addr2];
        end
        WRITE: begin
            ram[dest] <= qF;
        end
    end

    // Atribuir o valor de qF
    assign qF = qF_wire;

endmodule
