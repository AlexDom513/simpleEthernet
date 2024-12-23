//====================================================================
// 02_simple_ethernet
// sync_reset_fifo.v
// 6/30/24
//====================================================================

// FIFO IP: https://github.com/fabriziotappero/ip-cores/tree/memory_core_synchronous_reset_fifo_with_testbench#vhdlverilog-ip-cores-repository
// Modified on 7/6/24

// FIFO Module
module sync_reset_fifo(
  Clk,
  Rst,
  Wr_En,
  Rd_En,
  Data,
  q,
  empty,
  full
  );

parameter WIDTH = 8;
parameter DEPTH = 512;
parameter POINTER_SIZE = 9;

// Inputs
input Clk;
input Rst;    
input Wr_En;
input Rd_En; 
input [WIDTH-1:0] Data;  
               
// Outputs
output [WIDTH-1:0] q; 
output empty;    
output full;     

// Wires and Internal Registers

// memory is (WIDTH-1)-bit vector with depth of (DEPTH-1)
// if (Wr_En == 1), we will write a register with input data and then 
// increment the write pointer to point to the next address

// if (Rd_En == 1), we will read a register at the current read pointer
// and then increment the read pointer to point to the next address

// fifo works by just incrementing the read/write pointer, eventually
// data in the fifo will be overwritten once the maximum amount in memory is covered

reg [WIDTH-1:0] memory [0:DEPTH-1];
reg [POINTER_SIZE-1:0] write_ptr; 
reg [POINTER_SIZE-1:0] read_ptr; 
reg [WIDTH-1:0] q;
wire empty;    
wire full;


// Asynchronous Logic
// FIFO full and empty logic

assign empty = ((write_ptr - read_ptr)== 9'b000000000) ? 1'b1 : 1'b0;
assign full  = ((write_ptr - read_ptr) == 9'b100000000) ? 1'b1 : 1'b0; 

// Synchronous Logic
// FIFO write and read logic 
always@(posedge Clk) 
begin 
	if (Rst) begin
    write_ptr <= 9'b000000000;
    read_ptr  <= 9'b000000000;
    q         <= 8'b00000000;
  end 
  
  else begin

    //Simultaneous Read and Write
    if ((Wr_En == 1) && (full == 0)) begin
      memory[write_ptr] <= Data;
      write_ptr         <= write_ptr + 1;
    end


    if ((Rd_En == 1) && (empty == 0)) begin
      q                 <= memory[read_ptr];
      read_ptr          <= read_ptr + 1;
    end
  end
end
endmodule
