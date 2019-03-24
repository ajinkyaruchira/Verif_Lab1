class i2c_transaction extends ncsu_transaction;
	`ncsu_register_object(i2c_transaction)

	bit [6:0] addr;
	bit [7:0] data [];
	i2c_op_t op;
	bit select;
	//bit [7:0] dataToRead[];
	function new(string name = "");
		super.new(name);
	endfunction : new

	virtual function string convert2string();
		if(op == write)
			return {super.convert2string(), $sformatf("write data: %p", data)};
		else
			return {super.convert2string(), $sformatf("read data: %p", data)};
	endfunction

	function bit compare (i2c_transaction rhs);
		return ((this.op == rhs.op) && (this.data == rhs.data));

		endfunction
endclass
