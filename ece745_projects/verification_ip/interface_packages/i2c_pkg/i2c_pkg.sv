<<<<<<< HEAD
package i2c_pkg;

import ncsu_pkg::*;

 `include "ncsu_macros.svh"
 `include "src/i2c_typedef.svh"
 `include "src/i2c_configuration.svh"
 `include "src/i2c_transaction.svh"
 `include "src/i2c_driver.svh"
 `include "src/i2c_monitor.svh"
 `include "src/i2c_agent.svh" 
endpackage
=======
package mypack;

	typedef enum bit {READ = 1'b0 , WRITE = 1'b1} i2c_op_t;
	i2c_op_t op;

endpackage;
>>>>>>> 74aff847ab75d6d38daee8566fdc100df836cb16
