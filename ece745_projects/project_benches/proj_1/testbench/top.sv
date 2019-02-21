`timescale 1ns / 10ps

package mypack;
module top();

parameter int WB_ADDR_WIDTH = 2;
parameter int WB_DATA_WIDTH = 8;
parameter int NUM_I2C_SLAVES = 1;

parameter int I2C_ADDR_WIDTH = 7;
parameter int I2C_DATA_WIDTH = 8;

bit  clk;
bit  rst = 1'b1;
wire cyc;
wire stb;
wire we;
tri1 ack;
wire [WB_ADDR_WIDTH-1:0] adr;
wire [WB_DATA_WIDTH-1:0] dat_wr_o;
wire [WB_DATA_WIDTH-1:0] dat_rd_i;
wire irq;
tri  [NUM_I2C_SLAVES-1:0] scl;
triand  [NUM_I2C_SLAVES-1:0] sda;

bit [15:0] ack_DON_bit;
bit [15:0] data_moniter, addr_moniter;
bit we_moniter;
//bit [I2C_DATA_WIDTH-1:0] test;
bit [I2C_DATA_WIDTH-1:0] test [];
bit [7:0] send_data;
typedef enum bit {READ , WRITE} i2c_op_t;
i2c_op_t test_op;

// ****************************************************************************
// Clock generator

initial clock_gen : begin
  forever #5 clk = ~clk;
end

// ****************************************************************************
// Reset generator

initial rst_gen : begin
  #0 rst   = 1'b1;
  #113 rst = 1'b0;
end

// ****************************************************************************
// Monitor Wishbone bus and display transfers in the transcript
  
initial wb_monitoring : begin
  forever begin
    #10 wb_bus.master_monitor(addr_moniter,data_moniter,we_moniter);
    $display("@%0d data is %d", $time, data_moniter);
  end
end


// ****************************************************************************
// Define the flow of the simulation

initial test_flow : begin
  
  // 0. Enable the IICMB core E = 1 CSR reg
  #114 wb_bus.master_write(2'b0, 8'b11000000); 

  // 1. Write byte 0x00 to the DPR DPR = 0x00
  wb_bus.master_write(2'b01, 3'b000); 
  
  // 2. CDMR = 0x06  Set Bus Commd  
  wb_bus.master_write(2'b10, 3'b110); 
  
  // 3. Wait for the Interrupt to go L-H
  @(irq);

  // Clear Interrupt by reading the CMDR Reg
  do
  	wb_bus.master_read(2'b10, ack_DON_bit); 
  while(irq == 1);
  
  // 4. Start command CDMR = 0x04
  wb_bus.master_write(2'b10, 3'b100); 

  // 5. Wait for the Interrupt to go L-H
  @(irq);

  // Clear Interrupt by reading the CMDR Reg
  do
  	wb_bus.master_read(2'b10, ack_DON_bit); 
  while(irq == 1);

  // 6. Write byte 0x44 to the DPR . DPR = 0x44
  wb_bus.master_write(2'b01, 8'b1000100); 

  // 7. Write command CDMR = 0x01
  wb_bus.master_write(2'b10, 3'b001); 

  // 8. Wait for the Interrupt to go L-H
  @(irq);

  // Clear Interrupt by reading the CMDR Reg
  do 
  	wb_bus.master_read(2'b10, ack_DON_bit); 
  while(irq == 1 );

  if(ack_DON_bit[6]) $display("NAK bit = 1 Slave does NOT respond");



  for (int i=0; i<32; i++) begin

	  // 9. Write byte 0x78 to the DPR. DPR = 0x00
	  send_data = i;
	  wb_bus.master_write(2'b01, send_data); 

	  // 10. Write cmd CDMR = 0x01 
	  wb_bus.master_write(2'b10, 3'b001); 

	  // 11. Wait for the Interrupt to go L-H
	  @(irq);

	  // Clear Interrupt by reading the CMDR Reg
	  do 
	  	wb_bus.master_read(2'b10, ack_DON_bit); 
	  while(irq == 1); 

  end



  // 12. Stop cmd CDMR = 101 
  wb_bus.master_write(2'b10, 3'b101); 

  // 13. Wait for the Interrupt to go L-H
  @(irq);

  // Clear Interrupt by reading the CMDR Reg
  do
  	wb_bus.master_read(2'b10, ack_DON_bit); 
  while(irq == 1);  

  //$stop;

end

// ****************************************************************************
// Define the flow of i2c


initial test_i2c : begin
  i2c_bus.wait_for_i2c_transfer(test_op, test);
  $display ("Top module operation type %s", test_op);
  for(int j=0; j<33; j++) begin
  	$display ("Top module write data %d", test[j]);
  end

  $stop;
end


// ****************************************************************************
// Instantiate the Wishbone master Bus Functional Model
wb_if       #(
      .ADDR_WIDTH(WB_ADDR_WIDTH),
      .DATA_WIDTH(WB_DATA_WIDTH)
      )
wb_bus (
  // System sigals
  .clk_i(clk),
  .rst_i(rst),
  // Master signals
  .cyc_o(cyc),
  .stb_o(stb),
  .ack_i(ack),
  .adr_o(adr),
  .we_o(we),
  // Slave signals
  .cyc_i(),
  .stb_i(),
  .ack_o(),
  .adr_i(),
  .we_i(),
  // Shred signals
  .dat_o(dat_wr_o),
  .dat_i(dat_rd_i)
  );

// ****************************************************************************
// Instantiate the DUT - I2C Multi-Bus Controller
\work.iicmb_m_wb(str) #(.g_bus_num(NUM_I2C_SLAVES)) DUT
  (
    // ------------------------------------
    // -- Wishbone signals:
    .clk_i(clk),         // in    std_logic;                            -- Clock
    .rst_i(rst),         // in    std_logic;                            -- Synchronous reset (active high)
    // -------------
    .cyc_i(cyc),         // in    std_logic;                            -- Valid bus cycle indication
    .stb_i(stb),         // in    std_logic;                            -- Slave selection
    .ack_o(ack),         //   out std_logic;                            -- Acknowledge output
    .adr_i(adr),         // in    std_logic_vector(1 downto 0);         -- Low bits of Wishbone address
    .we_i(we),           // in    std_logic;                            -- Write enable
    .dat_i(dat_wr_o),    // in    std_logic_vector(7 downto 0);         -- Data input
    .dat_o(dat_rd_i),    //   out std_logic_vector(7 downto 0);         -- Data output
    // ------------------------------------
    // ------------------------------------
    // -- Interrupt request:
    .irq(irq),           //   out std_logic;                            -- Interrupt request
    // ------------------------------------
    // ------------------------------------
    // -- I2C interfaces:
    .scl_i(scl),         // in    std_logic_vector(0 to g_bus_num - 1); -- I2C Clock inputs
    .sda_i(sda),         // in    std_logic_vector(0 to g_bus_num - 1); -- I2C Data inputs
    .scl_o(scl),         //   out std_logic_vector(0 to g_bus_num - 1); -- I2C Clock outputs
    .sda_o(sda)          //   out std_logic_vector(0 to g_bus_num - 1)  -- I2C Data outputs
    // ------------------------------------
  );

  
// ****************************************************************************
// Instantiate the i2c interface

i2c_if       #(
      .I2C_ADDR_WIDTH(I2C_ADDR_WIDTH),
      .I2C_DATA_WIDTH(I2C_DATA_WIDTH)
      )
i2c_bus (
    .scl(scl),
    .sda(sda)
  );


endmodule 
endpackage;
