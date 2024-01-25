// Copyright TU Wien
// Licensed under the Solderpad Hardware License v2.1, see LICENSE.txt for details
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1


module vproc_tb #(
        parameter              PROG_PATHS_LIST = "",
        parameter int unsigned MEM_W           = 32,
        parameter int unsigned MEM_SZ          = 262144,
        parameter int unsigned MEM_LATENCY     = 1,
        parameter int unsigned VMEM_W          = 32,
        parameter int unsigned ICACHE_SZ       = 0,   // instruction cache size in bytes
        parameter int unsigned ICACHE_LINE_W   = 128, // instruction cache line width in bits
        parameter int unsigned DCACHE_SZ       = 0,   // data cache size in bytes
        parameter int unsigned DCACHE_LINE_W   = 512  // data cache line width in bits
    );

    logic clk_i, rst;
    always begin
        clk_i = 1'b0;
        #3;
        clk_i = 1'b1;
        #3;
    end

    logic        mem_req;
    logic [31:0] mem_addr;
    logic        mem_we;
    logic [3:0]  mem_be;
    logic [31:0] mem_wdata;
    logic        mem_rvalid;
    logic        mem_err;
    logic [31:0] mem_rdata;

    vproc_top #(
        .MEM_W         ( MEM_W                       ),
        .VMEM_W        ( VMEM_W                      ),
        .VREG_TYPE     ( vproc_pkg::VREG_ASIC ),
        .MUL_TYPE      ( vproc_pkg::MUL_GENERIC ),
        .ICACHE_SZ     ( ICACHE_SZ                   ),
        .ICACHE_LINE_W ( ICACHE_LINE_W               ),
        .DCACHE_SZ     ( DCACHE_SZ                   ),
        .DCACHE_LINE_W ( DCACHE_LINE_W               )
    ) top (
        .clk_i         ( clk_i                         ),
        .rst_ni        ( ~rst                        ),
        .mem_req_o     ( mem_req                     ),
        .mem_addr_o    ( mem_addr                    ),
        .mem_we_o      ( mem_we                      ),
        .mem_be_o      ( mem_be                      ),
        .mem_wdata_o   ( mem_wdata                   ),
        .mem_rvalid_i  ( mem_rvalid                  ),
        .mem_err_i     ( mem_err                     ),
        .mem_rdata_i   ( mem_rdata                   ),
        .pend_vreg_wr_map_o (                        )
    );

    // memory
    logic [MEM_W-1:0]                    mem[MEM_SZ/(MEM_W/8)];
    logic [$clog2(MEM_SZ/(MEM_W/8))-1:0] mem_idx;
    assign mem_idx = mem_addr[$clog2(MEM_SZ)-1 : $clog2(MEM_W/8)];
    // latency pipeline
    logic        mem_rvalid_queue[MEM_LATENCY];
    logic [31:0] mem_rdata_queue [MEM_LATENCY];
    logic        mem_err_queue   [MEM_LATENCY];
    always_ff @(posedge clk_i) begin
        if (mem_req & mem_we) begin
            for (int i = 0; i < MEM_W/8; i++) begin
                if (mem_be[i]) begin
                    mem[mem_idx][i*8 +: 8] <= mem_wdata[i*8 +: 8];
                end
            end
        end
        for (int i = 1; i < MEM_LATENCY; i++) begin
            if (i == 1) begin
                mem_rvalid_queue[i] <= mem_req;
                mem_rdata_queue [i] <= mem[mem_idx];
                mem_err_queue   [i] <= mem_addr[31:$clog2(MEM_SZ)] != '0;
            end else begin
                mem_rvalid_queue[i] <= mem_rvalid_queue[i-1];
                mem_rdata_queue [i] <= mem_rdata_queue [i-1];
                mem_err_queue   [i] <= mem_err_queue   [i-1];
            end
        end
        if ((MEM_LATENCY) == 1)begin
            mem_rvalid <= mem_req;
            mem_rdata  <= mem[mem_idx];
            mem_err    <= mem_addr[31:$clog2(MEM_SZ)] != '0;
        end else begin
            mem_rvalid <= mem_rvalid_queue[MEM_LATENCY-1];
            mem_rdata  <= mem_rdata_queue [MEM_LATENCY-1];
            mem_err    <= mem_err_queue   [MEM_LATENCY-1];
        end
        for (int i = 0; i < MEM_SZ; i++) begin
            // set the don't care values in the memory to 0 during the first rising edge
            if ($isunknown(mem[i]) & ($time < 10)) begin
                mem[i] <= '0;
            end
        end
    end

    logic prog_end, done;
    assign prog_end = mem_req & (mem_addr == '0);

    integer fd1, fd2, cnt, ref_start, ref_end, dump_start, dump_end;
    string  line, prog_path, ref_path, dump_path;
    string vcd_file, scenario;
    initial begin
        done = 1'b0;

        fd1 = $fopen(PROG_PATHS_LIST, "r");
        for (int i = 0; !$feof(fd1); i++) begin
            rst = 1'b1;

            $fgets(line, fd1);

            ref_path   = "/dev/null";
            ref_start  = 0;
            ref_end    = 0;
            dump_path  = "/dev/null";
            dump_start = 0;
            dump_end   = 0;
            cnt = $sscanf(line, "%s %s %x %x %s %x %x", prog_path, ref_path, ref_start, ref_end, dump_path, dump_start, dump_end);

            // continue with next line in case of an empty line (cnt == 0) or an EOF (cnt == -1)
            if (cnt < 1) begin
                continue;
            end

            $readmemh(prog_path, mem);
            scenario = "gemm";
            vcd_file = {"/pri/abal/V_Unit/vicuna/sim/tmp/", scenario, ".vcd"};
            $dumpfile(vcd_file);
            $dumpvars(0, vproc_tb.top.v_core);  // substitute with your u_DUT name
            $display("%0t START VCD dumping",$time);

            // reset for 10 cycles
            #100
            rst = 1'b0;
            
            $dumpon;
            // wait for completion (i.e. request of instr mem addr 0x00000000)
            //@(posedge prog_end);
            while (1) begin
                @(posedge clk_i);
                if (prog_end) begin
                    break;
                end
            end
            $dumpoff;
            $display("%0t END VCD dumping",$time);
            
        end
        $fclose(fd1);
        done = 1'b1;
    end

endmodule
