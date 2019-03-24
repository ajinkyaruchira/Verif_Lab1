`timescale 1ns / 10ps

module top();

parameter int WB_ADDR_WIDTH = 2;
parameter int WB_DATA_WIDTH = 8;
parameter int NUM_I2C_SLAVES = 1;

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
tri  [NUM_I2C_SLAVES-1:0] sda;

logic [31:0] addr_transfer;
logic [15:0] data_transfer;
logic [15:0] read_don;
logic we_transfer;

// ****************************************************************************
// Clock generator

initial 
begin : clk_gen
	forever #5 clk = ~clk;
end

// ****************************************************************************
// Reset generator

initial
begin : rst_gen
	#113 rst = 1'b0;
end

// ****************************************************************************
// Monitor Wishbone bus and display transfers in the transcript

initial
begin : wb_monitoring
	forever
  begin
    #10 
    wb_bus.master_monitor(addr_transfer, data_transfer, we_transfer);
  	$display("@%0dns Address : %h, Data : %h", $time, addr_transfer, data_transfer);
  end

	//forever	#10ns $display("@%0d addr is %h", $time, wb_bus.master_monitor.data);
end

// ****************************************************************************
// Define the flow of the simulation

initial
begin : test_flow

#114 	//begins after reset
wb_bus.master_write(2'b00, 16'h0xC0);  /* transfer 1xxxxxxx to CSR */
//$display("transfer 1xxxxxxx to CSR");


wb_bus.master_write(2'b01, 3'b101);  /* transfer 0x05 to DPR */
//$display("transfer 0x05 to DPR");


wb_bus.master_write(2'b10, 3'b110);  /* Set Bus transfer xxxx x110 to CMDR */
//$display("transfer xxxx x110 to CMDR");


@(irq);

do
  wb_bus.master_read(2'b10, read_don);
while((irq == 1) || (read_don[7] == 1'b1));   /* wait for interrupt or DON */


wb_bus.master_write(2'b10, 3'b100);   /* START condition xxxx x100 to CMDR */
//$display("Start");


wb_bus.master_read(2'b10, read_don);
@((irq==1) or (read_don[7] == 1'b1));   /* wait for interrupt or DON */
wb_bus.master_read(2'b10, read_don);


wb_bus.master_write(2'b01, 8'b01000100);   /* 0x44 to DPR */
//$display("0x44 to DPR");

wb_bus.master_write(2'b10, 3'b001);   /* WRITE command xxxx x001 to CMDR */
//$display("WRITE");


wb_bus.master_read(2'b10, read_don);
@((irq==1) or (read_don[7] == 1'b1) or (read_don[6] == 1'b0));   /* wait for interrupt or DON or ~NAK */
wb_bus.master_read(2'b10, read_don);


wb_bus.master_write(2'b01, 8'b01111000);  /* transfer 0x78 to DPR */
//$display("0x78 to DPR");


wb_bus.master_write(2'b10, 3'b001);   /* WRITE command xxxx x001 to CMDR */
//$display("Write");


wb_bus.master_read(2'b10, read_don);
@((irq==1) or (read_don[7] == 1'b1));   /* wait for interrupt or DON */
wb_bus.master_read(2'b10, read_don);


wb_bus.master_write(2'b10, 3'b101);   /* Set Bus xxxx x101 to CMDR */
//$display("Set Bus xxxx x101 to CMDR");


wb_bus.master_read(2'b10, read_don);
@((irq==1) or (read_don[7] == 1'b1));   /* wait for interrupt or DON */
wb_bus.master_read(2'b10, read_don);
//$display("wait for interrupt");

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


endmodule
