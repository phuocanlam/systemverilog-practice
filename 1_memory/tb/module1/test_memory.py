# test_memory.py

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer


@cocotb.test()
async def memory_data_test(dut):
    # Start a 10 ns clock
    cocotb.start_soon(Clock(dut.clk_i, 1, unit="ns").start())
    await RisingEdge(dut.clk_i)

    # Reset
    dut.rstn_i.value = 0
    dut.write_enable_i.value = 0
    dut.address_i.value = 0
    dut.write_data_i.value = 0  

    await RisingEdge(dut.clk_i)    
    dut.rstn_i.value = 1 
    await RisingEdge(dut.clk_i)  

    # All is 0 after reset
    for address in range(dut.WORDS.value):
        dut.address_i.value = address
        await Timer(1, unit="ns")
        assert dut.read_data_o.value == "00000000000000000000000000000000"
      
    # Test: Write and read back data
    test_data = [
        (0, 0xDEADBEEF),
        (4, 0xCAFEBABE),
        (8, 0x12345678),
        (12, 0xA5A5A5A5)
    ]

    for address, data in test_data:
        # Write data to memory
        dut.address_i.value = address
        dut.write_data_i.value = data
        dut.write_enable_i.value = 1
        await RisingEdge(dut.clk_i)

        # Disable write after one cycle
        dut.write_enable_i.value = 0
        await RisingEdge(dut.clk_i)

        # Verify the write by reading back
        dut.address_i.value = address
        await RisingEdge(dut.clk_i)
        assert dut.read_data_o.value == data

    # Test: Write to multiple addresses, then read back
    for i in range(40,4):
        dut.address_i.value = i
        dut.write_data_i.value = i + 100
        dut.write_enable_i.value = 1
        await RisingEdge(dut.clk_i)

    # Disable write, then read back values to check
    dut.write_enable_i.value = 0
    for i in range(40,4):
        dut.address_i.value = i
        await RisingEdge(dut.clk_i)
        expected_value = i + 100
        assert dut.read_data_o.value == expected_value