// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vtop.h for the primary calling header

#ifndef VERILATED_VTOP___024ROOT_H_
#define VERILATED_VTOP___024ROOT_H_  // guard

#include "verilated.h"


class Vtop__Syms;

class alignas(VL_CACHE_LINE_BYTES) Vtop___024root final {
  public:

    // DESIGN SPECIFIC STATE
    VL_IN8(clk_i,0,0);
    VL_IN8(rstn_i,0,0);
    VL_IN8(write_enable_i,0,0);
    CData/*0:0*/ memory__DOT__clk_i;
    CData/*0:0*/ memory__DOT__rstn_i;
    CData/*0:0*/ memory__DOT__write_enable_i;
    CData/*0:0*/ __VstlFirstIteration;
    CData/*0:0*/ __VstlPhaseResult;
    CData/*0:0*/ __VicoFirstIteration;
    CData/*0:0*/ __VicoPhaseResult;
    CData/*0:0*/ __Vtrigprevexpr___TOP__memory__DOT__clk_i__0;
    CData/*0:0*/ __VactPhaseResult;
    CData/*0:0*/ __VnbaPhaseResult;
    VL_IN(address_i,31,0);
    VL_IN(write_data_i,31,0);
    VL_OUT(read_data_o,31,0);
    IData/*31:0*/ memory__DOT__address_i;
    IData/*31:0*/ memory__DOT__write_data_i;
    IData/*31:0*/ memory__DOT__read_data_o;
    IData/*31:0*/ memory__DOT__unnamedblk1__DOT__i;
    IData/*31:0*/ __VactIterCount;
    VlUnpacked<IData/*31:0*/, 64> memory__DOT__memory;
    VlUnpacked<QData/*63:0*/, 1> __VstlTriggered;
    VlUnpacked<QData/*63:0*/, 1> __VicoTriggered;
    VlUnpacked<QData/*63:0*/, 1> __VactTriggered;
    VlUnpacked<QData/*63:0*/, 1> __VnbaTriggered;
    VlNBACommitQueue<VlUnpacked<IData/*31:0*/, 64>, false, IData/*31:0*/, 1> __VdlyCommitQueuememory__DOT__memory;

    // INTERNAL VARIABLES
    Vtop__Syms* vlSymsp;
    const char* vlNamep;

    // PARAMETERS
    static constexpr IData/*31:0*/ memory__DOT__WORDS = 0x00000040U;

    // CONSTRUCTORS
    Vtop___024root(Vtop__Syms* symsp, const char* namep);
    ~Vtop___024root();
    VL_UNCOPYABLE(Vtop___024root);

    // INTERNAL METHODS
    void __Vconfigure(bool first);
};


#endif  // guard
