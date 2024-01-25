// import vproc_pkg::*;
// import vproc_config::*;

// typedef struct packed {
//         logic [2:0]                    count_mul;
//         logic                          first_cycle;
//         logic                          last_cycle;
//         logic                          init_addr;       // initialize address (used by LSU)
//         logic                          requires_flush;
//         logic                          alt_count_valid; // alternative counter value is valid
//         // logic [$clog2(VREG_W/PIPE_W[0])-1:0]      aux_count;
//         // logic [XIF_ID_W-1:0]           id;
//         op_unit                        unit;
//         op_mode                        mode;
//         cfg_vsew                       eew;             // effective element width
//         cfg_emul                       emul;            // effective MUL factor
//         cfg_vxrm                       vxrm;
//         // logic [$clog2(PIPE_W[0]/8)-1:0] vl_part;
//         logic [1:0] vl_part;
//         logic                          vl_part_0;
//         logic                          last_vl_part;    // last VL part that is not 0
//         logic                          vl_0;
//         logic [31:0]                   xval;
//         //logic [RES_CNT-1:0]            res_vreg;
//         // logic [RES_CNT-1:0]            res_narrow;
//         logic                          res_store;
//         logic                          res_shift;
//         logic [4:0]                    res_vaddr;
//         logic                          pend_load;
//         logic                          pend_store;
//     } ctrl_t;

module alu_wrapper import synth_pkg::*; (
        input  logic                  clk_i,
        input  logic                  async_rst_ni,
        input  logic                  sync_rst_ni,

        input  logic                  pipe_in_valid_i,
        output logic                  pipe_in_ready_o,
        input  ctrl_t                 pipe_in_ctrl_i,
        input  logic [PIPE_W[0]  -1:0] pipe_in_op1_i,
        input  logic [PIPE_W[0]  -1:0] pipe_in_op2_i,
        input  logic [PIPE_W[0]/8-1:0] pipe_in_mask_i,

        output logic                  pipe_out_valid_o,
        input  logic                  pipe_out_ready_i,
        output ctrl_t                 pipe_out_ctrl_o,
        output logic [PIPE_W[0]  -1:0] pipe_out_res_alu_o,
        output logic [PIPE_W[0]/8-1:0] pipe_out_res_cmp_o,
        output logic [PIPE_W[0]/8-1:0] pipe_out_mask_o
    );

    vproc_alu #(
                .ALU_OP_W           ( PIPE_W[0]                                   ),
                .BUF_OPERANDS       ( 1'b1),
                .BUF_INTERMEDIATE   ( 1'b1),
                .BUF_RESULTS        ( 1'b1),
                .CTRL_T             ( ctrl_t                                      ),
                .DONT_CARE_ZERO     ( 1'b0                                        )
            ) alu (
                .clk_i              ( clk_i                                       ),
                .async_rst_ni       ( async_rst_ni                                ),
                .sync_rst_ni        ( sync_rst_ni                                 ),
                .pipe_in_valid_i    ( pipe_in_valid_i                             ),
                .pipe_in_ready_o    ( pipe_in_ready_o                             ),
                .pipe_in_ctrl_i     ( pipe_in_ctrl_i                              ),
                .pipe_in_op1_i      ( pipe_in_op1_i                               ),
                .pipe_in_op2_i      ( pipe_in_op2_i                               ),
                .pipe_in_mask_i     ( pipe_in_mask_i                              ),
                .pipe_out_valid_o   ( pipe_out_valid_o                            ),
                .pipe_out_ready_i   ( pipe_out_ready_i                            ),
                .pipe_out_ctrl_o    ( pipe_out_ctrl_o                             ),
                .pipe_out_res_alu_o ( pipe_out_res_alu_o                          ),
                .pipe_out_res_cmp_o ( pipe_out_res_cmp_o                          ),
                .pipe_out_mask_o    ( pipe_out_mask_o                             )
            );

endmodule