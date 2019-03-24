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
		@(posedge scl);
		@(sda or negedge scl);
			
	    if(!scl)                                        /* data bits */
		begin : data_bits

		    for(int i=8; i>0; i--)
		    begin : for_i
		       		write_data[i-1] = sda;
		       		if(i>1)	@(posedge scl);
		    end : for_i
		            	
		    @(posedge scl);
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
				  
    @(posedge scl);	

    while(1)
    begin

	    @(posedge scl);
	    
	   	@(sda or negedge scl);

	   	if(!scl)                                           //data bits 
			begin : data_bits

		    for(int i=8; i>0; i--)
		    begin : for_i

		       	data = new[j+1](data);
		       	data[j][i-1] = sda;
		      	if(i>1)	@(posedge scl);

		    end : for_i
		            	
		    @(posedge scl);
		     	// ACK 
		    j++;
		  
		end : data_bits

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
				
