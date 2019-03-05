<<<<<<< HEAD
`timescale 1ns / 10ps
interface i2c_if       #(
      int ADDR_WIDTH = 8,                                
      int DATA_WIDTH = 8                                
      )
(
  // System signals
  input wire scl,
  inout wire sda
  );

import mypack::*;

  bit sda_o = 1'b1;
  bit prev_state;

  assign sda = sda_o?'bz:'b0;
  

// ****************************************************************************                           
  task wait_for_i2c_transfer(
                   output i2c_op_t op,
                   output bit [DATA_WIDTH-1:0]  write_data[]
                   );  
   	int j ;
  	j=0;
  	prev_state = 0;
  	
	while(1)
	begin

		if(prev_state==1)	j=0;
	    write_data = new[j+1](write_data);
		@(posedge scl);
		@(sda or negedge scl);
			
	    if(!scl)                                        /* data bits */
		begin : data_bits

		    for(int i=8; i>0; i--)
		    begin : for_i
		       		write_data[j][i-1] = sda;
		       		if(i>1)	@(posedge scl);
		    end : for_i
		            	
		    @(posedge scl);
		     	//sda_o = 1'b0; 	/* Send ACK */
		       
		    //@(negedge scl);
		     	//sda_o = 1'b1; 	/* Release SDA */
		            	
		    if(j==0)
		       	begin : j_op

					if(write_data[0][0] == 1) 
	       		begin : op_r
	      			op = READ;
	       			return;
		     	end : op_r	
	    
	    		else 
	       		begin : wr
	    			op = WRITE;
				end : wr
	    	end : j_op
	    	
	    	j++;
	    	prev_state = 0;	

		end : data_bits

		else if (!sda) 	                                  /* start */
		begin
			prev_state = 1;	
		end

		else if (sda) 	                                 /* stop */
		begin
		  	prev_state = 0;
		  	return;
		end
		 	
	end

  endtask        

// ****************************************************************************              
task provide_read_data(
                 input bit [DATA_WIDTH-1:0] read_data[]
                 );                                                  
   

    for (int i=0;i<read_data.size();i++)  // size 32
    begin
      
      for(int j=DATA_WIDTH+1; j>0; j--)
      begin
    
        @(negedge scl);
        #1500ns
        sda_o = read_data[i][j-2];    /* Transfer whole byte */

      end

      //@(negedge scl);   /* Open for ACK */
      //sda_o = 1'b0;

      @(posedge scl);   /* Open for ACK */
      sda_o = 1'b1;
    
    end

    // wait for event here
    @(posedge scl); 

    

endtask        

// ****************************************************************************              
task monitor(output bit[ADDR_WIDTH-1:0]addr, output i2c_op_t op, output bit[DATA_WIDTH-1:0]data[]);
    int j;
    prev_state = 0;
    j = 0;


    @(negedge sda && scl==1);
    
    for(int i=8; i>0; i--)
    begin : for_i
    	@(posedge scl)
    	addr[i-1]= sda;
    end
    
		if(addr[0] == 1) 
		     		begin : op_r
		      			op = READ;
			     	end : op_r	
		    
		    		else 
		       		begin : wr
		    			op = WRITE;
		       		end : wr
		  
    @(posedge scl);	

    while(1)
    begin

	    @(posedge scl);
	    
	   	@(sda or negedge scl);

	   	if(!scl)                                          /* data bits */
			begin : data_bits

		    for(int i=8; i>0; i--)
		    begin : for_i

		       		data = new[j+1](data);
		       		data[j][i-1] = sda;
		      		if(i>1)	@(posedge scl);

		    end : for_i
		            	
		    @(posedge scl);
		     	/* ACK */
		        
		    j++;
		  
		end : data_bits

		else if (!sda) 	  $display ("Start detected");                               /* start */
		// begin 
		// 	for(int i=8; i>0; i--)
  //   		begin : for_i
  //   			@(posedge scl)
  //   			addr[i-1]= sda;
  //   		end
		// 	break;
		// end

		else if (sda) 	                                 /* stop */
		begin
			return;
		end
    end

endtask 

endinterface

=======

//`include "i2c_pkg.sv"

import mypack::*;

interface i2c_if #(
      int I2C_ADDR_WIDTH = 7,                                
      int I2C_DATA_WIDTH = 8                                
      )
(
	input wire scl,
	inout wire sda
);

bit [7:0] test; 
logic pos_detector = 1'b0;
bit start_bit;
event event_stop;
//typedef enum bit {READ , WRITE} i2c_op_t;
//i2c_op_t op;

always@(posedge sda) begin
	if(scl==1 && start_bit==1)  ->> event_stop;						//pos_detector = 1'b1;	
end


task automatic wait_for_i2c_transfer (output i2c_op_t op, output bit [I2C_DATA_WIDTH-1:0] write_data []);
	
	bit [7:0] store [$];					    
	int k = 0;
	$display ("Entered task wait_for_i2c_transfer");
	@(negedge sda && scl == 1);
	$display ("Write Data");
	

	start_bit = 1'b1;

	fork 
		begin
			while(!event_stop.triggered()) begin

				for (int i = I2C_DATA_WIDTH-1; i > -1; i-- ) begin
					@(posedge scl);
					test [i] = sda;
				end

				
				@(posedge scl);
				//sda <= 0;

				$display("test = %h", test);

				store.push_back(test);

				if (k == 0 && test[7] == 1) begin 
					break;
					op = READ;
				end
				else op = WRITE;

				k++;

			end

		end

		begin
			$display ("Wait for stop event");

			wait(event_stop.triggered());
			$display("Stop bit detedted");

			write_data = new [store.size()];

			for(int j=0; j<33; j++) begin
				$display("Queue = %h", store[j]);
				write_data[j] = store[j];
			end

			$display ("After for loop");
			//disable fork;
		end
			
	join_any;

	//$display ("Came out of fork join");

	//wait fork;

	$display ("All threads completed");
	

endtask

endinterface 
>>>>>>> d6efc9665a6e2149c3823ff68fbefda3002e5b7d
