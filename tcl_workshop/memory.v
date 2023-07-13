module memory(clk,addr,din,dout);

parameter wordSize=1;
parameter addressSize=1;

input addr,clk;
input [wordSize-1:0] din;
output reg [wordSize-1:0] dout;
reg [wordSize-1:0] mem[0:(1<<addressSize)-1];

always @(posedge clk) begin
	mem[addr] <= din;
	dout <= mem[addr];
end
endmodule
