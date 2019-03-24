`timescale 1ns / 10ps

module top();

import i2c_pkg::*;

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

logic [31:0] addr_transfer;
logic [15:0] data_transfer;
logic [15:0] read_don;
logic we_transfer;

bit [I2C_DATA_WIDTH-1:0] write_data[];  /* wait write return */
bit [I2C_DATA_WIDTH-1:0] read_addr;    /* monitor read */ 
bit [7:0] converted_data;             /* write data */
bit [I2C_DATA_WIDTH-1:0] task_data[];   /* task data array */
bit [I2C_DATA_WIDTH-1:0] read_data[];   /* read array */
bit [I2C_DATA_WIDTH-1:0] rx_byte;   /* read byte */

i2c_op_t rw;

bit [7:0] single_write_data;             /* write data */
static int max_i=63;
static int min_i = 64;
static bit[7:0] send_min = 8'b01100100;
bit [I2C_DATA_WIDTH-1:0] rx_read_byte;   /* read byte */
bit [I2C_DATA_WIDTH-1:0] single_read_data[];

bit [I2C_DATA_WIDTH-1:0] i2c_addr_transfer;
bit [I2C_DATA_WIDTH-1:0] i2c_data_transfer[];
bit rw_bit;




/********* Write call task **********/

task write_func;
  
  for(int i=0; i<32; i++)
  begin
    
    converted_data = i;

    wb_bus.master_write(2'b01,converted_data ); /* Transfer data to DPR */

    wb_bus.master_write(2'b10, 3'b001);   /* WRITE */

    wait_for_irq;

  end

endtask

/********* Write call task **********/





/********* Read values **********/
  
task read_func;

	wb_bus.master_write(2'b01, 3'b001);  /* ID = 1 */

	wb_bus.master_write(2'b10, 3'b110);   /* Set Bus */

 	wait_for_irq;   /* wait for interrupt or DON */
	 
	wb_bus.master_write(2'b10, 3'b100);   /* START */
	
  	wait_for_irq;   /* wait for interrupt or DON */

	wb_bus.master_write(2'b01, 8'b01000101);   /* 0x89 to DPR */  

	wb_bus.master_write(2'b10, 3'b001);   /* WRITE */
	
  	wait_for_irq;   /* wait for interrupt or DON */

	for(int i=0; i<32;i++)
	begin

    if(i==31)  wb_bus.master_write(2'b10, 3'b011);   /* Read with NAK */
    else    wb_bus.master_write(2'b10, 3'b010);   /* Read with ACK */

		wait_for_irq;   /* wait for interrupt or DON */

		wb_bus.master_read(2'b01, rx_byte);  /* get received byte of data */

	end

	wb_bus.master_write(2'b10, 3 'b101);   /* STOP */

  wait_for_irq;   /* wait for interrupt or DON */

endtask

/********* Read values **********/



/********* Allocate values **********/


task call_read_array(output bit [I2C_DATA_WIDTH-1:0] task_data[]);

  for(int i=0; i<32; i++)
  begin : for_i
    task_data = new[i+1](task_data);
    task_data[i] = send_min;
    send_min++;
  end : for_i

endtask

/********* Allocate values **********/


/********* ALternate Write Task **********/

task single_write_transfer(input bit [7:0] single_write_data);

	wb_bus.master_write(2'b10, 3'b100);   /* START */
 
 	wait_for_irq;   /* wait for interrupt or DON */
  
 	wb_bus.master_write(2'b01, 8'b01000100);   /* 0x44 to DPR */
  
 	wb_bus.master_write(2'b10, 3'b001);   /* WRITE */

  	wait_for_irq;   /* wait for interrupt or DON */

 	wb_bus.master_write(2'b01,single_write_data ); /* Transfer data to DPR */
  
 	wb_bus.master_write(2'b10, 3'b001);   /* WRITE */

  wait_for_irq;   /* wait for interrupt or DON */

endtask

/********* Alternate Write Task **********/

/********* Alternate Read Task **********/

task single_read_transfer;
	
	wb_bus.master_write(2'b10, 3'b100);   /* START */

  	wait_for_irq;   /* wait for interrupt or DON */
  
	wb_bus.master_write(2'b01, 8'b10001001);   /* 0x89 to DPR */  
  
 	wb_bus.master_write(2'b10, 3'b001);   /* WRITE */
	
  	wait_for_irq;   /* wait for interrupt or DON */
	
	wb_bus.master_write(2'b10, 3'b011);   /* Read with NAK */
	
  	wait_for_irq;   /* wait for interrupt or DON */

	wb_bus.master_read(2'b01, rx_read_byte);  /* get received byte of data */

endtask

/********* Alternate  Task **********/

task alternate_transfer;

	for(int i=0; i<64; i++)
	begin

			/* Writes from 64 to 127 */
  			
      single_write_data = min_i;
			single_write_transfer(single_write_data);
      min_i++;	
	
  		/* Writes from 63 to 0 */
      
      read_data = new[1];
			read_data[0] = max_i;
      
			single_read_transfer;
      max_i--;
	
  end

endtask

/********* Alternate Task **********/


/********* Wait for irq  **********/

task wait_for_irq;
  while(irq==0) @(posedge clk);
  wb_bus.master_read(2'b10,read_don);
endtask

/********* wait for irq **********/



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

// initial
// begin : wb_monitoring
//   // forever
//   // begin
//   //   #10 
//   //   wb_bus.master_monitor(addr_transfer, data_transfer, we_transfer);
//   //   $display("@%0dns Address : %h, Data : %h", $time, addr_transfer, data_transfer);
//   // end

//   // forever #10ns $display("@%0d add r is %h", $time, wb_bus.master_monitor.data);
// end




// ****************************************************************************
// Define the flow of the simulation

initial
begin : test_flow

  #114  //begins after reset
   wb_bus.master_write(2'b00, 8'b11xxxxxx);  /* transfer 1xxxxxxx to CSR */

  // wb_bus.master_write(2'b01, 3'b101);  /* transfer 0x05 to DPR */

  // wb_bus.master_write(2'b10, 3'b110);  /* Set Bus transfer xxxx x110 to CMDR */

  // wait_for_irq;   /* wait for interrupt or DON */

  // wb_bus.master_write(2'b10, 3'b100);    /*START condition xxxx x100 to CMDR*/ 

  // wait_for_irq;

  // wb_bus.master_write(2'b01, 8'b01000100);   /* 0x44 to DPR */
  
  // wb_bus.master_write(2'b10, 3'b001);   /* WRITE command xxxx x001 to CMDR */

  // wait_for_irq;

  // /*************************/
  
  // write_func;

  // /**********************/

  // wb_bus.master_write(2'b10, 3'b101);   /* STOP to CMDR */
  
  // wait_for_irq;
 
  call_read_array(read_data);
  //#10ns
  read_func;   

  //alternate_transfer;

  $stop;
end

// ****************************************************************************
// Define the flow of i2c transfer

initial
begin : i2c_transfer
  
	forever
	begin 
	   
	  i2c_bus.wait_for_i2c_transfer(rw, write_data);
	  
	  if(rw==READ)	
	  begin : if_read
	  	i2c_bus.provide_read_data(read_data);
	  end : if_read
	   
  end   
end : i2c_transfer


// ****************************************************************************
// Monitor i2c bus and display transfers in the transcript

initial
begin : i2c_monitor
  
  forever
  begin
    i2c_bus.monitor(i2c_addr_transfer, rw_bit, i2c_data_transfer);
    
    if(rw_bit==1)
    begin
      for(int i=0; i<i2c_data_transfer.size(); i++)
        $display("I2C_BUS READ Transfer : %h, %h ", i2c_addr_transfer, i2c_data_transfer[i]);
    end    
    else
    begin
      for(int i=0; i<i2c_data_transfer.size(); i++)
      $display("I2C_BUS WRITE Transfer : %h, %h", i2c_addr_transfer, i2c_data_transfer[i]);
    end  
  end
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
// Instantiate the I2C slave Bus Functional Model
i2c_if       #(
      .ADDR_WIDTH(I2C_ADDR_WIDTH),
      .DATA_WIDTH(I2C_DATA_WIDTH)
      )
i2c_bus (
  .sda(sda),
  .scl(scl)
  );


endmodule
