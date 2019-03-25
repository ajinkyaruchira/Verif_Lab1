`timescale 1ns / 10ps

<<<<<<< HEAD
module top();

import i2c_pkg::*;
=======
<<<<<<< HEAD
=======
//`include "i2c_pkg.sv"

>>>>>>> d6efc9665a6e2149c3823ff68fbefda3002e5b7d
import mypack::*;

module top();
>>>>>>> 74aff847ab75d6d38daee8566fdc100df836cb16

parameter int WB_ADDR_WIDTH = 2;
parameter int WB_DATA_WIDTH = 8;
parameter int NUM_I2C_SLAVES = 1;
<<<<<<< HEAD
=======

>>>>>>> 74aff847ab75d6d38daee8566fdc100df836cb16
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

<<<<<<< HEAD
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














=======
<<<<<<< HEAD
logic [7:0] ack_DON_bit;
=======
bit [15:0] ack_DON_bit;
>>>>>>> d6efc9665a6e2149c3823ff68fbefda3002e5b7d
bit [15:0] data_moniter, addr_moniter;
bit we_moniter;
//bit [I2C_DATA_WIDTH-1:0] test;
bit [I2C_DATA_WIDTH-1:0] test [];
bit [7:0] send_data;
i2c_op_t test_op;
<<<<<<< HEAD
i2c_op_t rw_bit;
bit [I2C_DATA_WIDTH-1:0] read_data [];
bit [I2C_DATA_WIDTH-1:0] read_DPR;

bit [I2C_DATA_WIDTH-1:0] task_data[];

bit [I2C_DATA_WIDTH-1:0] rxd_data;

bit [I2C_DATA_WIDTH-1:0] i2c_addr_transfer;

bit [I2C_DATA_WIDTH-1:0] i2c_data_transfer[];


static int max_value = 63;
static int min_value = 64;
bit [7:0] w_value;
bit [I2C_DATA_WIDTH-1:0] read_single_read;
=======
>>>>>>> d6efc9665a6e2149c3823ff68fbefda3002e5b7d

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


<<<<<<< HEAD

=======
>>>>>>> d6efc9665a6e2149c3823ff68fbefda3002e5b7d
// ****************************************************************************
// Define the flow of the simulation

initial test_flow : begin
  
<<<<<<< HEAD
  //write_test_flow();
  
  populate_data(read_data);

  read_slave;

  //alter_read_write;

  $stop;

end

/************************ Task Write test flow  *********************************************/

task write_test_flow();

  wb_bus.master_write(2'b00, 8'b11xxxxxx);    // 0. Enable the IICMB core E = 1 CSR reg
  wb_bus.master_write(2'b01, 3'b101);         // 1. Write byte 0x00 to the DPR DPR = 0x05
  wb_bus.master_write(2'b10,8'bxxxxx110);     // 2. CDMR = 0x06  Set Bus Commd  
  
  wait_for_irq();
  
  wb_bus.master_write(2'b10,8'bxxxxx100);     // 4. Start command CDMR = 0x04

  wait_for_irq();
  
  wb_bus.master_write(2'b01,8'h44);           // 6. Write byte 0x44 to the DPR . DPR = 0x44
  wb_bus.master_write(2'b10,8'bxxxxx001);     // 7. Write command CDMR = 0x01

  wait_for_irq();

  //if(ack_DON_bit[6]) $display("NAK bit = 1 Slave does NOT respond");

  write_data ();

  wb_bus.master_write(2'b10,8'bxxxxx101);     // 12. Stop cmd CDMR = 101

  wait_for_irq();

endtask


/*******************************************************************************************/


/************************ Task wait for IRQ *************************************************/

task wait_for_irq();

  while(irq == 1'b0) @ (posedge clk);      // 3. Wait for the Interrupt to go L-H
  wb_bus.master_read(2'b10, ack_DON_bit);  // Clear Interrupt by reading the CMDR Reg

endtask


/*******************************************************************************************/


/************************ Task write data *************************************************/

task write_data ();

 for (int i=0; i<32; i++) begin

	  
	  send_data = i;                             // 9. Write byte 0x78 to the DPR. DPR = 0x00
	  wb_bus.master_write(2'b01, send_data); 
 
	  wb_bus.master_write(2'b10,8'bxxxxx001);    // 10. Write cmd CDMR = 0x01 

	  while(irq == 1'b0) @ (posedge clk);        // 3. Wait for the Interrupt to go L-H
    wb_bus.master_read(2'b10, ack_DON_bit);    // Clear Interrupt by reading the CMDR Reg

  end

endtask

/*******************************************************************************************/


/************************ Task read slave *************************************************/

task read_slave;
  
  wb_bus.master_write(2'b00, 8'b11xxxxxx);
 	wb_bus.master_write(2'b01, 3'b001);     /* ID = 1 */
	wb_bus.master_write(2'b10, 3'b110);     /* Set Bus */

	wait_for_irq();

	wb_bus.master_write(2'b10,8'bxxxxx100);   // 4. Start command CDMR = 0x04

 	wait_for_irq();

	wb_bus.master_write(2'b01, 8'h45);        /* 0x45 to DPR */  
	wb_bus.master_write(2'b10,8'bxxxxx001);   /* WRITE */	
	
	wait_for_irq();
	
	for(int i=0; i<32;i++)
	begin
  if(i==31)   wb_bus.master_write(2'b10,8'bxxxxx011);  /* Read with NAK */

  else   wb_bus.master_write(2'b10,8'bxxxxx010);  /* Read with ACK */
	
		wait_for_irq();

		wb_bus.master_read(2'b01, read_DPR);    /* get received byte of data */

	end

	wb_bus.master_write(2'b10,8'bxxxxx101);   /* STOP */

	wait_for_irq();


endtask


/*******************************************************************************************/

task populate_data (output bit [I2C_DATA_WIDTH-1:0] task_data []);

	for(int l=0;l<32;l++)
	begin
		task_data = new[l+1](task_data);
		task_data[l] = l+8'b01100100;
	end

endtask


task alter_read_write;

  for(int i=0; i<64; i++)
  begin

      /* Writes from 64 to 127 */
        
      w_value = min_value;
      write_alter(w_value);
      min_value++;  
  
      /* Writes from 63 to 0 */
      
      read_data = new[1];
      read_data[0] = max_value;
      
      read_alter;
      max_value--;
  
  end
endtask



task write_alter(input bit [7:0] w_value);

  wb_bus.master_write(2'b10, 3'b100);   /* START */
 
  wb_bus.master_read(2'b10, ack_DON_bit);
    @((irq==1) or (ack_DON_bit[7] == 1'b1));   /* wait for interrupt or DON */
    wb_bus.master_read(2'b10, ack_DON_bit);
  
    wb_bus.master_write(2'b01, 8'b01000100);   /* 0x44 to DPR */
  
    wb_bus.master_write(2'b10, 3'b001);   /* WRITE */

    wb_bus.master_read(2'b10, ack_DON_bit);
    @((irq==1) or (ack_DON_bit[7] == 1'b1) or (ack_DON_bit[6] == 1'b0));   /* wait for interrupt or DON or ~NAK */
    wb_bus.master_read(2'b10, ack_DON_bit);

    wb_bus.master_write(2'b01, w_value ); /* Transfer data to DPR */
  
    wb_bus.master_write(2'b10, 3'b001);   /* WRITE */

    wb_bus.master_read(2'b10, ack_DON_bit);
    @((irq==1) or (ack_DON_bit[7] == 1'b1));   /* wait for interrupt or DON */
    
    wb_bus.master_read(2'b10, ack_DON_bit);
endtask


task read_alter;
  wb_bus.master_write(2'b10, 3'b100);   /* START */

    wb_bus.master_read(2'b10, ack_DON_bit);
    @((irq==1) or (ack_DON_bit[7] == 1'b1));   /* wait for interrupt or DON */
    wb_bus.master_read(2'b10, ack_DON_bit);
   
  wb_bus.master_write(2'b01, 8'b10001001);   /* 0x89 to DPR */  
  
    wb_bus.master_write(2'b10, 3'b001);   /* WRITE */
  
  wb_bus.master_read(2'b10, ack_DON_bit);
  @((irq==1) or (ack_DON_bit[7] == 1'b1));   /* wait for interrupt or DON */
  
    wb_bus.master_read(2'b10, ack_DON_bit);
  
  wb_bus.master_write(2'b10, 3'b011);   /* Read with NAK */
  
  wb_bus.master_read(2'b10, ack_DON_bit);
  @((irq==1) or (ack_DON_bit[7] == 1'b1));   /* wait for interrupt or DON */

  wb_bus.master_read(2'b01, read_single_read);  /* get received byte of data */

endtask;


=======
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
>>>>>>> d6efc9665a6e2149c3823ff68fbefda3002e5b7d

// ****************************************************************************
// Define the flow of i2c


initial test_i2c : begin
<<<<<<< HEAD
  
  // Wait for i2c transfer
  
  	for(int k =0; k<35; k++) 
  	begin
  		i2c_bus.wait_for_i2c_transfer(test_op, test);
  
  		if(test_op == WRITE) begin
		  /*do nothing*/
		  end

		  else begin
			 i2c_bus.provide_read_data(read_data);
		  end
  	end
end

initial begin

  forever 
  begin
  
    i2c_bus.monitor(i2c_addr_transfer, rw_bit, i2c_data_transfer);

    if (rw_bit == WRITE) begin
      for (int i=0; i< i2c_data_transfer.size(); i++) 
    
         $display(" I2C_BUS WRITE Transfer: %h,%h ",i2c_addr_transfer, i2c_data_transfer[i]);
      
    end

    else begin
     
      for (int i=0; i< i2c_data_transfer.size(); i++)
        $display (" I2C_BUS READ Transfer: %h %h ", i2c_addr_transfer, i2c_data_transfer[i]);

    end

  end
  
=======
  i2c_bus.wait_for_i2c_transfer(test_op, test);
  $display ("Top module operation type %s", test_op);
  for(int j=0; j<33; j++) begin
  	$display ("Top module write data %d", test[j]);
  end

  $stop;
>>>>>>> d6efc9665a6e2149c3823ff68fbefda3002e5b7d
end
>>>>>>> 74aff847ab75d6d38daee8566fdc100df836cb16


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

<<<<<<< HEAD
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
=======
  
// ****************************************************************************
// Instantiate the i2c interface

i2c_if       #(
<<<<<<< HEAD
      .ADDR_WIDTH(I2C_ADDR_WIDTH),
      .DATA_WIDTH(I2C_DATA_WIDTH)
=======
      .I2C_ADDR_WIDTH(I2C_ADDR_WIDTH),
      .I2C_DATA_WIDTH(I2C_DATA_WIDTH)
>>>>>>> d6efc9665a6e2149c3823ff68fbefda3002e5b7d
      )
i2c_bus (
    .scl(scl),
    .sda(sda)
  );


endmodule 

>>>>>>> 74aff847ab75d6d38daee8566fdc100df836cb16
