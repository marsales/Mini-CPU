// Banco de memória virtual
module memory (
    input [15:0] data, // Dados para escrever na RAM
    input [3:0] addr,  // Endereço da RAM no qual será escrito ou lido os dados
    input we, clk,     // Ativar a escrita na RAM // Clock
    output [15:0] q    // Leitura do que consta no endereço addr
);

    // Variável de RAM 16 x 16 bits
    reg [15:0] ram[15:0];

    // Variável para guardar o endereço de leitura
    reg [7:0] addr_reg;

    // Escrever na RAM
    always @ (posedge clk) begin
        if (we) ram[addr] <= data;

        addr_reg <= addr;
    end

    // Ler a RAM
    assign q = ram[addr_reg];

endmodule
