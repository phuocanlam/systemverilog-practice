// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Symbol table implementation internals

#include "Vtop__pch.h"

Vtop__Syms::Vtop__Syms(VerilatedContext* contextp, const char* namep, Vtop* modelp)
    : VerilatedSyms{contextp}
    // Setup internal state of the Syms class
    , __Vm_modelp{modelp}
    // Setup top module instance
    , TOP{this, namep}
{
    // Check resources
    Verilated::stackCheck(262);
    // Setup sub module instances
    // Configure time unit / time precision
    _vm_contextp__->timeunit(-9);
    _vm_contextp__->timeprecision(-12);
    // Setup each module's pointers to their submodules
    // Setup each module's pointer back to symbol table (for public functions)
    TOP.__Vconfigure(true);
    // Setup scopes
    __Vscopep_TOP = new VerilatedScope{this, "TOP", "TOP", "<null>", 0, VerilatedScope::SCOPE_OTHER};
    __Vscopep_memory = new VerilatedScope{this, "memory", "memory", "memory", -9, VerilatedScope::SCOPE_MODULE};
    __Vscopep_memory__unnamedblk1 = new VerilatedScope{this, "memory.unnamedblk1", "unnamedblk1", "<null>", -9, VerilatedScope::SCOPE_OTHER};
    // Set up scope hierarchy
    __Vhier.add(0, __Vscopep_memory);
    __Vhier.add(__Vscopep_memory, __Vscopep_memory__unnamedblk1);
    // Setup export functions - final: 0
    // Setup export functions - final: 1
    // Setup public variables
    __Vscopep_TOP->varInsert("address_i", &(TOP.address_i), false, VLVT_UINT32, VLVD_IN|VLVF_PUB_RW, 0, 1 ,31,0);
    __Vscopep_TOP->varInsert("clk_i", &(TOP.clk_i), false, VLVT_UINT8, VLVD_IN|VLVF_PUB_RW, 0, 0);
    __Vscopep_TOP->varInsert("read_data_o", &(TOP.read_data_o), false, VLVT_UINT32, VLVD_OUT|VLVF_PUB_RW, 0, 1 ,31,0);
    __Vscopep_TOP->varInsert("rstn_i", &(TOP.rstn_i), false, VLVT_UINT8, VLVD_IN|VLVF_PUB_RW, 0, 0);
    __Vscopep_TOP->varInsert("write_data_i", &(TOP.write_data_i), false, VLVT_UINT32, VLVD_IN|VLVF_PUB_RW, 0, 1 ,31,0);
    __Vscopep_TOP->varInsert("write_enable_i", &(TOP.write_enable_i), false, VLVT_UINT8, VLVD_IN|VLVF_PUB_RW, 0, 0);
    __Vscopep_memory->varInsert("WORDS", const_cast<void*>(static_cast<const void*>(&(TOP.memory__DOT__WORDS))), true, VLVT_UINT32, VLVD_NODIR|VLVF_PUB_RW|VLVF_SIGNED, 0, 1 ,31,0);
    __Vscopep_memory->varInsert("address_i", &(TOP.memory__DOT__address_i), false, VLVT_UINT32, VLVD_NODIR|VLVF_PUB_RW, 0, 1 ,31,0);
    __Vscopep_memory->varInsert("clk_i", &(TOP.memory__DOT__clk_i), false, VLVT_UINT8, VLVD_NODIR|VLVF_PUB_RW, 0, 0);
    __Vscopep_memory->varInsert("memory", &(TOP.memory__DOT__memory), false, VLVT_UINT32, VLVD_NODIR|VLVF_PUB_RW, 1, 1 ,0,63 ,31,0);
    __Vscopep_memory->varInsert("read_data_o", &(TOP.memory__DOT__read_data_o), false, VLVT_UINT32, VLVD_NODIR|VLVF_PUB_RW, 0, 1 ,31,0);
    __Vscopep_memory->varInsert("rstn_i", &(TOP.memory__DOT__rstn_i), false, VLVT_UINT8, VLVD_NODIR|VLVF_PUB_RW, 0, 0);
    __Vscopep_memory->varInsert("write_data_i", &(TOP.memory__DOT__write_data_i), false, VLVT_UINT32, VLVD_NODIR|VLVF_PUB_RW, 0, 1 ,31,0);
    __Vscopep_memory->varInsert("write_enable_i", &(TOP.memory__DOT__write_enable_i), false, VLVT_UINT8, VLVD_NODIR|VLVF_PUB_RW, 0, 0);
    __Vscopep_memory__unnamedblk1->varInsert("i", &(TOP.memory__DOT__unnamedblk1__DOT__i), false, VLVT_UINT32, VLVD_NODIR|VLVF_PUB_RW|VLVF_DPI_CLAY|VLVF_SIGNED, 0, 1 ,31,0);
}

Vtop__Syms::~Vtop__Syms() {
    // Tear down scope hierarchy
    __Vhier.remove(0, __Vscopep_memory);
    __Vhier.remove(__Vscopep_memory, __Vscopep_memory__unnamedblk1);
    // Clear keys from hierarchy map after values have been removed
    __Vhier.clear();
    // Tear down scopes
    VL_DO_CLEAR(delete __Vscopep_TOP, __Vscopep_TOP = nullptr);
    VL_DO_CLEAR(delete __Vscopep_memory, __Vscopep_memory = nullptr);
    VL_DO_CLEAR(delete __Vscopep_memory__unnamedblk1, __Vscopep_memory__unnamedblk1 = nullptr);
    // Tear down sub module instances
}
