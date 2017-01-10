`timescale 1ns/1ps
`include "uvm_macros.svh"
import uvm_pkg::*;

// Component of type 1 - can be anything... driver, monitor, scoreboard, sequences, 
// sequence_item, etc
class comp_v1 extends uvm_component;
   `uvm_component_utils (comp_v1)

   function new (string name = "comp_v1", uvm_component parent=null);
      super.new (name, parent);
   endfunction

   virtual task run_phase (uvm_phase phase );
      `uvm_info ("", $sformatf ("This is %s ...", this.get_type_name()), UVM_MEDIUM)
   endtask
endclass

// Component derivative of comp_v1, it should be a derivative - we cannot substitute
// entirely different types with the factory. Say there exists a sequence, and we 
// wanted to have a similar sequence but with a minor change.. then you can inherit
// the original sequence and then override it this way
class comp_v2 extends comp_v1;
   `uvm_component_utils (comp_v2)

   function new (string name = "comp_v2", uvm_component parent=null);
      super.new (name, parent);
   endfunction

   virtual task run_phase (uvm_phase phase );
      `uvm_info ("", $sformatf ("This is %s ...", this.get_type_name()), UVM_MEDIUM)
   endtask
endclass


// Top level environment to hold the component
class my_env extends uvm_env;
   `uvm_component_utils (my_env)

   comp_v1 m_comp_a;
   comp_v1 m_comp_b;

   function new (string name = "my_env", uvm_component parent=null);
      super.new (name, parent);
   endfunction

   function void build_phase (uvm_phase phase);
      super.build_phase (phase);
      m_comp_a = comp_v1::type_id::create ("mycomp_a", this);
      m_comp_b = comp_v1::type_id::create ("mycomp_b", this);
      `uvm_info ("CHECK", $sformatf ("Component A Type = %s", m_comp_a.get_type_name()), UVM_MEDIUM)
      `uvm_info ("CHECK", $sformatf ("Component B Type = %s", m_comp_b.get_type_name()), UVM_MEDIUM)
   endfunction

endclass

class base_test extends uvm_test;
   `uvm_component_utils (base_test)

   my_env   m_top_env;
   
   function new (string name, uvm_component parent = null);
      super.new (name, parent);
   endfunction : new
   
   virtual function void build_phase (uvm_phase phase);
      super.build_phase (phase);
      m_top_env  = my_env::type_id::create ("m_top_env", this);
      
      // Override all instances of "comp_v1" type by "comp_v2"
      factory.set_type_override_by_type (comp_v1::get_type(), comp_v2::get_type());
      
//      factory.set_type_override_by_name ("comp_v1", "comp_v2");
//      factory.set_inst_override_by_type (comp_v1::get_type(), comp_v2::get_type(), "uvm_test_top.my_env.m_comp_a");
   endfunction : build_phase

   virtual function void end_of_elaboration_phase (uvm_phase phase);
      uvm_top.print_topology ();
      factory.print();
   endfunction
endclass

module tb_top;
   initial 
      run_test ("base_test");
endmodule
