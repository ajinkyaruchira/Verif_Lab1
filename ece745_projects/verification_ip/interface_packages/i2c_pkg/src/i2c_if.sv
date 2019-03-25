<<<<<<< HEAD
`timescale 1ns / 10ps
import i2c_pkg::*;
interface i2c_if #(
	int ADDR_WIDTH = 7,
	int DATA_WIDTH = 8
	)
(
	input wire scl,
	inout wire sda
);

bit sda_o=1'b1;

assign sda = sda_o?1'bz:1'b0;




//#####################################WAIT_FOR_I2C TASK#########################################################

task wait_for_i2c_transfer(output i2c_op_t op, output bit [DATA_WIDTH-1:0] write_data []);       //wait for ic task(writing)
 
     
  //sda_o=1'b1; 

  	int j ;
   	bit [7:0] address;
 

	while(1)
	begin

	    //write_data = new[j+1](write_data);
=======
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
>>>>>>> 74aff847ab75d6d38daee8566fdc100df836cb16
		@(posedge scl);
		@(sda or negedge scl);
			
	    if(!scl)                                        /* data bits */
		begin : data_bits

		    for(int i=8; i>0; i--)
		    begin : for_i
<<<<<<< HEAD
		       		write_data[i-1] = sda;
=======
		       		write_data[j][i-1] = sda;
>>>>>>> 74aff847ab75d6d38daee8566fdc100df836cb16
		       		if(i>1)	@(posedge scl);
		    end : for_i
		            	
		    @(posedge scl);
<<<<<<< HEAD
		   	/* Send ACK */
		  	
			    if(write_data[0] == 1) 
				begin : op_r
					op = read;
					return;
			  	end : op_r	
					    		    	
				else 
					op = write;
				
 	    end
	    	//j++;

		//end : data_bits

		else if (!sda) begin  end                                  /* start */

		else if (sda) return;                                /* stop */
		 	
	

	end

         
endtask



//#############################READ TASK##################################################



task provide_read_data(input bit[DATA_WIDTH-1:0] read_data[]);                 //Read data task

	   for (int i=0;i<read_data.size();i++)  // size 32
   begin
      
   	for(int j=DATA_WIDTH+1; j>0; j--)
   	begin
        
       	@(negedge scl);
       	#1500ns
       	sda_o = read_data[i][j-2];    /* Transfer whole byte */

   	end
    
   	@(posedge scl);   /* Open for ACK */
   	sda_o = 1'b1;

   end

    //wait for event here
   @(posedge scl); 
         
endtask

//#############################MONITOR TASK################################################

  
task monitor (output bit [ADDR_WIDTH-1:0] addr,output i2c_op_t op,output bit[DATA_WIDTH-1:0] data[]);
    
	 int j;
    j = 0;

   @(negedge sda && scl==1);

	for(int i=8; i>0; i--)
    begin : for_i
    	@(posedge scl);
    	addr[i-1]= sda;
    end
    $display("address recorded : %h",addr);
	if(addr[0] == 1) 
	begin : op_rr
		op = read;
   	end : op_rr	
				    
	else 
	begin : wr_rr
	  	op = write;
   	end : wr_rr
				  
=======
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
		  
>>>>>>> 74aff847ab75d6d38daee8566fdc100df836cb16
    @(posedge scl);	

    while(1)
    begin

	    @(posedge scl);
	    
	   	@(sda or negedge scl);

<<<<<<< HEAD
	   	if(!scl)                                           //data bits 
=======
	   	if(!scl)                                          /* data bits */
>>>>>>> 74aff847ab75d6d38daee8566fdc100df836cb16
			begin : data_bits

		    for(int i=8; i>0; i--)
		    begin : for_i

<<<<<<< HEAD
		       	data = new[j+1](data);
		       	data[j][i-1] = sda;
		      	if(i>1)	@(posedge scl);
=======
		       		data = new[j+1](data);
		       		data[j][i-1] = sda;
		      		if(i>1)	@(posedge scl);
>>>>>>> 74aff847ab75d6d38daee8566fdc100df836cb16

		    end : for_i
		            	
		    @(posedge scl);
<<<<<<< HEAD
		     	// ACK 
=======
		     	/* ACK */
		        
>>>>>>> 74aff847ab75d6d38daee8566fdc100df836cb16
		    j++;
		  
		end : data_bits

<<<<<<< HEAD
		else if (!sda) 	                              //     start 
		begin
		$display("start detected");
		
			for(int i=8; i>0; i--)
		    begin : for_i
		    	@(posedge scl);
		    	addr[i-1]= sda;
		    end
		    $display("address recorded : %h",addr);
			if(addr[0] == 1) 
			begin : op_r
				op = read;
		   	end : op_r	
				    
			else 
			begin : wr
			  	op = write;
		   	end : wr
				  
		    @(posedge scl);	

			end

		else if (sda) 	                               //  stop
		begin
		$display("stop detected");
			return;
		end
    end   	

endtask


endinterface
				
=======
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
>>>>>>> 74aff847ab75d6d38daee8566fdc100df836cb16
