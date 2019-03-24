class wb_monitor extends ncsu_component#(.T(wb_transaction));

  wb_configuration  configuration;
  T monitored_trans;
  ncsu_component #(T) agent;
  virtual wb_if bus;

  function new(string name = "", ncsu_component_base parent = null);
    super.new(name,parent);
  endfunction

  function void set_configuration(wb_configuration cfg);
    configuration = cfg;
  endfunction

  function void set_agent(ncsu_component#(T) agent);
    this.agent = agent;
  endfunction

  virtual task run ();
    
      forever begin
        monitored_trans = new("monitored_trans");
        bus.master_monitor(monitored_trans.address,
                    monitored_trans.data,
                    monitored_trans.we
                    );
        $display("%0s wb_monitor::run() address 0x%x data 0x%x we %0d",
                 get_full_name(),
                 monitored_trans.address,
                 monitored_trans.data,
                 monitored_trans.we
                 );
        agent.nb_put(monitored_trans);
    end
  endtask

endclass
