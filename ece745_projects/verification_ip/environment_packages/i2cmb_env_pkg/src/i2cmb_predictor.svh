class i2cmb_predictor extends ncsu_component#(.T(wb_transaction));

  ncsu_component#(.T(i2c_transaction)) scoreboard;
  i2c_transaction transport_trans;
  i2cmb_env_configuration configuration;

  //bit start=0;    
  //bit stop=0, i = 0;
  bit flag_address=0;
  int start_flag = 0;
  int stop_flag = 0;
  int write_count = 0;
  int read_count = 0;

  bit [7:0] write_arr[];
  bit [7:0] read_arr[];
  bit [7:0] store_address;

  i2c_transaction scrbrd_i2c_trans;


  function new(string name = "", ncsu_component_base parent = null);
    super.new(name,parent);
  endfunction

  function void set_configuration(i2cmb_env_configuration cfg);
    configuration = cfg;
  endfunction


  virtual function void set_scoreboard(ncsu_component #(i2c_transaction) scoreboard);
      this.scoreboard = scoreboard;
  endfunction


  virtual function void nb_put(wb_transaction trans);
      pred_to_scrbrd(transport_trans,trans);
  endfunction
   
   
  function void pred_to_scrbrd(output i2c_transaction scrbrd_trans, input wb_transaction wb_trans);
      $cast(transport_trans,ncsu_object_factory::create("i2c_transaction"));
  	  if(start_flag == 0) begin
          if(wb_trans.data == 8'b0000_0100 && wb_trans.address == 2'b10)
          begin
            start_flag = 1;
            stop_flag = 0;
          end
        end


        if(stop_flag == 0 && start_flag == 1) begin
          if(wb_trans.data == 8'b0000_0101 && wb_trans.address == 2'b10) begin
            stop_flag = 1;
            start_flag = 0;
            flag_address = 0;
            if(store_address[0] == 0) begin
              transport_trans.data = write_arr;
  	          transport_trans.op = write;
            end
            else  begin
              transport_trans.data = read_arr;
  		        transport_trans.op = read;
            end
            write_arr = null;
            read_arr = null;
            write_count = 0;
            read_count = 0;
  	        scoreboard.nb_transport(transport_trans, scrbrd_i2c_trans);
          end
        end


        if(stop_flag == 0 && start_flag && wb_trans.address == 2'b01) begin
          if(flag_address == 0) begin

            store_address = wb_trans.data;
            flag_address = 1;
            end
          else if(store_address[0] == 0)begin
         
            write_arr = new[write_count+ 1](write_arr);
            write_arr[write_count] = wb_trans.data;
  	   transport_trans.data = new[1];
  	  transport_trans.data[0] = wb_trans.data;
            write_count++;
          end
          else begin
      
            read_arr = new[read_count+ 1](read_arr);
            read_arr[read_count] = wb_trans.data;
  	transport_trans.data = new[1];
  	 transport_trans.data[0] = wb_trans.data;
            read_count++;
          end
        
        end




  endfunction


endclass
