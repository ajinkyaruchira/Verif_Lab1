class i2cmb_generator extends ncsu_component#(.T(wb_transaction));

	//wb_transaction transaction_wb[32];
  	ncsu_component #(wb_transaction) w_agent;
  	ncsu_component #(i2c_transaction) I2C_agent;


  	string trans_name;
  	bit [7:0] i2c_read_data []; 		// i2c transaction read data to be sent
  	int initial_value = 100;     		// Initial value for consecutive read data
  	bit read_flow_flag = 0;       		// Flag for continuous reads and alternate reads
  	int i;                				// for loop variable
  	

  	wb_transaction send_wb_transaction;
  	i2c_transaction send_i2c_transaction;

  	// From make file get variable trans_name
  	function new(string name = "", ncsu_component_base parent = null);
    		super.new(name,parent);
    		if ( !$value$plusargs("GEN_TRANS_TYPE=%s", trans_name)) 
    			begin
      				$display("FATAL: +GEN_TRANS_TYPE plusarg not found on command line");
      				$fatal;
    			end
    		$display("%m found +GEN_TRANS_TYPE=%s", trans_name);
  	endfunction

  	// Run wishbone flow and i2c flow simultaneously
  	virtual task run();
		fork
			begin
				wishbone_flow();
			end
			begin
				i2c_flow();
			end
		join_any
		$finish;
  	endtask

    // Wishbone testflow
  	virtual task wishbone_flow();
		$cast(send_wb_transaction,ncsu_object_factory::create(trans_name));
		send_wb_transaction.interrupt = 0;
		chip_enable();
		send_wb_transaction_transactions();
		write_b2b();
		read_b2b();
		alternate_wr_rd();
 	 endtask


 	// i2c test flow
  	virtual task i2c_flow();
		automatic int i =0,count = 0;
  		$cast(send_i2c_transaction,ncsu_object_factory::create("i2c_transaction"));
		forever
			begin
				send_i2c_transaction.select = 0;
				I2C_agent.bl_put(send_i2c_transaction);
				if(read_flow_flag == 0 && send_i2c_transaction.op == 1)
					begin
						i2c_read_data = new[32];
						repeat(32)
							begin
								i2c_read_data[i] = initial_value;
								initial_value++;
								i++;
							end
						send_i2c_transaction.data = i2c_read_data;
						send_i2c_transaction.select = 1;
						I2C_agent.bl_put(send_i2c_transaction);
					end
				else if(read_flow_flag == 1 && send_i2c_transaction.op == 1)
					begin
						i2c_read_data = new[1];
						foreach(i2c_read_data[j]) begin
							i2c_read_data[j] = 63 - count;
						end
						count++;
						send_i2c_transaction.data = i2c_read_data;
						send_i2c_transaction.select = 1;
						I2C_agent.bl_put(send_i2c_transaction);

					end
			end
 	 endtask


  	function void set_agent(ncsu_component #(wb_transaction) agent);
			w_agent = agent;
  	endfunction
  
 	function void set_Agent(ncsu_component #(i2c_transaction) agent);
			I2C_agent = agent;
  	endfunction

  	// Chip enable I2CMB
  	task chip_enable();
  		//bus.master_write(2'b00, 8'b11xxxxxx);  /* transfer 1xxxxxxx to CSR */
		send_wb_transaction.address = 2'b00;
		send_wb_transaction.data = 8'b11xxxxxx;
		send_wb_transaction.op_bit_wb = 0;          
		w_agent.bl_put(send_wb_transaction);
  	endtask

	
	// Task for start_cmd command
  	task start_cmd();
  		//bus.master_write(2'b10, 3'b100);    /*START condition xxxx x100 to CMDR*/ 
		// start_cmd, wait for interrupt and clearing the interrupt
		send_wb_transaction.address = 2'b10;
		send_wb_transaction.data = 8'bxxxxx100;
		send_wb_transaction.op_bit_wb = 0;         
		send_wb_transaction.interrupt = 1;
		w_agent.bl_put(send_wb_transaction);
		send_wb_transaction.address  = 2'b10;
		send_wb_transaction.op_bit_wb = 1;
		send_wb_transaction.interrupt = 0;
		w_agent.bl_put(send_wb_transaction);
  	endtask

  	// send_wb_transaction transactions
  	task send_wb_transaction_transactions();

		// Set id of selected bus
		// bus.master_write(2'b01, 3'b101);  /* transfer 0x05 to DPR */
		send_wb_transaction.address = 2'b01;
		send_wb_transaction.data = 8'h05;
		send_wb_transaction.op_bit_wb = 0;         
		w_agent.bl_put(send_wb_transaction);

        // Set bus command
        // bus.master_write(2'b10, 3'b110);  /* Set Bus transfer xxxx x110 to CMDR */
		send_wb_transaction.address = 2'b10;
		send_wb_transaction.data = 8'bxxxxx110;
		send_wb_transaction.op_bit_wb = 0;         
		send_wb_transaction.interrupt = 1;
		w_agent.bl_put(send_wb_transaction);

        // Clear interrupt
		send_wb_transaction.address  = 2'b10;
		send_wb_transaction.op_bit_wb = 1;
		send_wb_transaction.interrupt = 0;
		w_agent.bl_put(send_wb_transaction);
  	endtask

	//utility task to send address
  	task send_addressess(input bit [7:0] address);
  		//bus.master_write(2'b01, trans.address);   /* 0x44 to DPR */  
		send_wb_transaction.address = 2'b01;
		send_wb_transaction.data = address;
		send_wb_transaction.op_bit_wb = 0;          
		send_wb_transaction.interrupt = 0;
		w_agent.bl_put(send_wb_transaction);
  	endtask


	//Task to give write command
  	task write_command();
  		//bus.master_write(2'b10, 3'b001);   /* WRITE command xxxx x001 to CMDR */
		send_wb_transaction.address = 2'b10;
		send_wb_transaction.data = 8'bxxxxx001;
		send_wb_transaction.op_bit_wb = 0;          
		send_wb_transaction.interrupt = 1;
		w_agent.bl_put(send_wb_transaction);
		send_wb_transaction.address  = 2'b10;
		send_wb_transaction.op_bit_wb = 1;
		send_wb_transaction.interrupt = 0;
		w_agent.bl_put(send_wb_transaction);
  	endtask
	
	// Task to give stop_cmd command
  	task stop_cmd();
  		//bus.master_write(2'b10, 3'b101);   /* stop_cmd to CMDR */  
		send_wb_transaction.address = 2'b10;
		send_wb_transaction.data = 8'bxxxxx101;
		send_wb_transaction.op_bit_wb = 0;          // Write
		send_wb_transaction.interrupt = 1;
		w_agent.bl_put(send_wb_transaction);
		send_wb_transaction.address  = 2'b10;
		send_wb_transaction.op_bit_wb = 1;
		send_wb_transaction.interrupt = 0;
		w_agent.bl_put(send_wb_transaction);

  	endtask

	// Task to give consecutive writes
  	task write_b2b();
		
		start_cmd();
		send_addressess(8'h44);
		write_command();
		for(i = 0; i< 32; i++)
			begin
	
			// send the byte
			send_wb_transaction.address = 2'b01;
			send_wb_transaction.data = i;
			send_wb_transaction.op_bit_wb = 0;          // Write
			w_agent.bl_put(send_wb_transaction);
			write_command();
		
		end
		stop_cmd();
  	endtask

  	task read_b2b;
		start_cmd();
		send_addressess(8'h89);
		write_command();
		
		// Reading 31 bytes with ACK signal
		for(i= 0; i < 31; i++)
			begin
				send_wb_transaction.address = 2'b10;
				send_wb_transaction.data = 8'bxxxxx010;
				send_wb_transaction.op_bit_wb = 0;          
				send_wb_transaction.interrupt = 1;
				w_agent.bl_put(send_wb_transaction);
				send_wb_transaction.address  = 2'b10;
				send_wb_transaction.op_bit_wb = 1;
				send_wb_transaction.interrupt = 0;
				w_agent.bl_put(send_wb_transaction);
				send_wb_transaction.address  = 2'b01;
				send_wb_transaction.op_bit_wb = 1;
				send_wb_transaction.interrupt = 0;
				w_agent.bl_put(send_wb_transaction);
			end
		// Reading last byte with NACK signal

		send_wb_transaction.address = 2'b10;
		send_wb_transaction.data = 8'bxxxxx011;
		send_wb_transaction.op_bit_wb = 0;         
		send_wb_transaction.interrupt = 1;
		w_agent.bl_put(send_wb_transaction);
		send_wb_transaction.address  = 2'b10;
		send_wb_transaction.op_bit_wb = 1;
		send_wb_transaction.interrupt = 0;
		w_agent.bl_put(send_wb_transaction);
		send_wb_transaction.address  = 2'b01;
		send_wb_transaction.op_bit_wb = 1;
		send_wb_transaction.interrupt = 0;
		w_agent.bl_put(send_wb_transaction);

		stop_cmd();
  	endtask



 	task alternate_wr_rd();
		automatic int i = 0;
		read_flow_flag = 1;

		// Alternate read and writes loop
		for(i =0 ; i< 64; i++)
			begin

				// Writing byte
				start_cmd();
				send_addressess(8'h44);
				write_command();

				// Writing byte
				send_wb_transaction.address = 2'b01;
				send_wb_transaction.data = 64+i;
				send_wb_transaction.op_bit_wb = 0;          // Write
				w_agent.bl_put(send_wb_transaction);
		
				write_command();
				stop_cmd();



				// Reading byte
				start_cmd();
				send_addressess(8'h89);
				write_command();
		
				// Reading byte with NACK
				send_wb_transaction.address = 2'b10;
				send_wb_transaction.data = 8'bxxxxx011;
				send_wb_transaction.op_bit_wb = 0;          
				send_wb_transaction.interrupt = 1;
				w_agent.bl_put(send_wb_transaction);
				send_wb_transaction.address  = 2'b10;
				send_wb_transaction.op_bit_wb = 1;
				send_wb_transaction.interrupt = 0;
				w_agent.bl_put(send_wb_transaction);
				send_wb_transaction.address  = 2'b01;
				send_wb_transaction.op_bit_wb = 1;
				send_wb_transaction.interrupt = 0;
				w_agent.bl_put(send_wb_transaction);

				stop_cmd();
		end
	
 	endtask
endclass
