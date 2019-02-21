//'include "/afs/eos.ncsu.edu/lockers/workspace/ece/ece745/001/amjadhav/ece745_projects/project_benches/proj_1/testbenches/top.sv"

import mypack::i2c_op_t;

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
