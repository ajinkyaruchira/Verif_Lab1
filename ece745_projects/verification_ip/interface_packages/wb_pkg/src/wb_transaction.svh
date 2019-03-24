class wb_transaction extends ncsu_transaction;
  `ncsu_register_object(wb_transaction)

       bit [1:0] address;
       bit [7:0] data;
       bit op_bit_wb;
       bit interrupt;
       bit we;

  function new(string name="");
    super.new(name);
  endfunction

  virtual function string convert2string();
     return {super.convert2string(),$sformatf("adress:0x%p data:0x%p", address, data)};
  endfunction


endclass

