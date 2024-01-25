module vicunas_datapath import synth_pkg::*; #(
        parameter int unsigned OPERAND_WIDTH    = vproc_config::PIPE_W[0],
        parameter bit          ENABLE_BUF       = 1'b1,
        parameter bit          DONT_CARE_ZERO   = 1'b0,
    )(
        input  logic                  clk_i,
        input  logic                  async_rst_ni,
        input  logic                  sync_rst_ni,

        input  logic                       pipe_in_valid_i,
        input  logic                       pipe_out_ready_i,
        input  ctrl_t                      pipe_in_ctrl_i,
        input  logic [OPERAND_WIDTH  -1:0] pipe_in_op1_i,
        input  logic [OPERAND_WIDTH  -1:0] pipe_in_op2_i,        
        input  logic [OPERAND_WIDTH  -1:0] pipe_in_op3_i,       // For VMUL
        input  logic [OPERAND_WIDTH/8-1:0] pipe_in_mask_i,
        input  logic [OPERAND_WIDTH  -1:0] pipe_in_op_gather_i, // For VELEM
        input  logic                       pipe_in_op2_mask_i,  // For VELEM

        // VALU Outputs
        output logic                       valu_pipe_in_ready_o,
        output logic                       valu_pipe_out_valid_o,
        output ctrl_t                      valu_pipe_out_ctrl_o,
        output logic [OPERAND_WIDTH  -1:0] valu_pipe_out_res_o,
        output logic [OPERAND_WIDTH/8-1:0] valu_pipe_out_res_cmp_o,
        output logic [OPERAND_WIDTH/8-1:0] valu_pipe_out_mask_o,

        // VMUL Outputs
        output logic                       vmul_pipe_in_ready_o,
        output logic                       vmul_pipe_out_valid_o,
        output ctrl_t                      vmul_pipe_out_ctrl_o,
        output logic [OPERAND_WIDTH  -1:0] vmul_pipe_out_res_o,
        output logic [OPERAND_WIDTH/8-1:0] vmul_pipe_out_res_cmp_o,
        output logic [OPERAND_WIDTH/8-1:0] vmul_pipe_out_mask_o,

        // VMUL Outputs
        output logic                       vsld_pipe_in_ready_o,
        output logic                       vsld_pipe_out_valid_o,
        output ctrl_t                      vsld_pipe_out_ctrl_o,
        output logic [OPERAND_WIDTH  -1:0] vsld_pipe_out_res_o,
        output logic [OPERAND_WIDTH/8-1:0] vsld_pipe_out_res_cmp_o,
        output logic [OPERAND_WIDTH/8-1:0] vsld_pipe_out_mask_o,

        // VELEM Outputs
        output logic                       velem_pipe_in_ready_o,
        output logic                       velem_pipe_out_valid_o,
        output ctrl_t                      velem_pipe_out_ctrl_o,
        output logic [OPERAND_WIDTH  -1:0] velem_pipe_out_res_o,
        output logic [OPERAND_WIDTH/8-1:0] velem_pipe_out_res_cmp_o,
        output logic [OPERAND_WIDTH/8-1:0] velem_pipe_out_mask_o,
        output logic                       pipe_out_xreg_valid_o,
        output logic [31 :0]               pipe_out_xreg_data_o,
        output logic [4 :0]                pipe_out_xreg_addr_o,
        output logic                       pipe_out_res_valid_o,

        // Ara DIV
        input  ara_op_e op_i,
        input  vew_e    vew_i,
        output logic                       vdiv_pipe_in_ready_o,
        output logic                       vdiv_pipe_out_valid_o,
        output logic [OPERAND_WIDTH  -1:0] vdiv_pipe_out_res_o,
        output logic [OPERAND_WIDTH/8-1:0] vdiv_pipe_out_mask_o
    );

    

    vproc_alu #(
                .ALU_OP_W           ( OPERAND_WIDTH                               ),
                .BUF_OPERANDS       ( ENABLE_BUF),
                .BUF_INTERMEDIATE   ( ENABLE_BUF),
                .BUF_RESULTS        ( ENABLE_BUF),
                .CTRL_T             ( ctrl_t                                      ),
                .DONT_CARE_ZERO     ( DONT_CARE_ZERO                              )
            ) alu (
                .clk_i              ( clk_i                                       ),
                .async_rst_ni       ( async_rst_ni                                ),
                .sync_rst_ni        ( sync_rst_ni                                 ),
                .pipe_in_valid_i    ( pipe_in_valid_i                             ),
                .pipe_in_ready_o    ( valu_pipe_in_ready_o                             ),
                .pipe_in_ctrl_i     ( pipe_in_ctrl_i                              ),
                .pipe_in_op1_i      ( pipe_in_op1_i                               ),
                .pipe_in_op2_i      ( pipe_in_op2_i                               ),
                .pipe_in_mask_i     ( pipe_in_mask_i                              ),
                .pipe_out_valid_o   ( valu_pipe_out_valid_o                            ),
                .pipe_out_ready_i   ( pipe_out_ready_i                            ),
                .pipe_out_ctrl_o    ( valu_pipe_out_ctrl_o                             ),
                .pipe_out_res_alu_o ( valu_pipe_out_res_o                          ),
                .pipe_out_res_cmp_o ( valu_pipe_out_res_cmp_o                          ),
                .pipe_out_mask_o    ( valu_pipe_out_mask_o                             )
            );

    vproc_mul #(
                .MUL_OP_W         ( OPERAND_WIDTH                               ),
                .MUL_TYPE         ( vproc_config::MUL_TYPE                                    ),
                .BUF_OPERANDS     ( ENABLE_BUF),
                .BUF_MUL_IN       ( ENABLE_BUF),
                .BUF_MUL_OUT      ( ENABLE_BUF),
                .BUF_RESULTS      ( ENABLE_BUF),
                .CTRL_T           ( ctrl_t                                      ),
                .DONT_CARE_ZERO   ( DONT_CARE_ZERO                              )
            ) mul (
                .clk_i            ( clk_i                                       ),
                .async_rst_ni     ( async_rst_ni                                ),
                .sync_rst_ni      ( sync_rst_ni                                 ),
                .pipe_in_valid_i  ( pipe_in_valid_i                             ),
                .pipe_in_ready_o  ( vmul_pipe_in_ready_o                             ),
                .pipe_in_ctrl_i   ( pipe_in_ctrl_i                              ),
                .pipe_in_op1_i    ( pipe_in_op2_i                               ),
                .pipe_in_op2_i    ( pipe_in_op1_i                               ),
                .pipe_in_op3_i    ( pipe_in_op3_i                               ),
                .pipe_in_mask_i   ( pipe_in_mask_i                              ),
                .pipe_out_valid_o ( vmul_pipe_out_valid_o                            ),
                .pipe_out_ready_i ( pipe_out_ready_i                            ),
                .pipe_out_ctrl_o  ( vmul_pipe_out_ctrl_o                              ),
                .pipe_out_res_o   ( vmul_pipe_out_res_o                                ),
                .pipe_out_mask_o  ( vmul_pipe_out_mask_o                               )
            );

    vproc_sld #(
                .SLD_OP_W         ( OPERAND_WIDTH                                    ),
                .BUF_OPERANDS     ( ENABLE_BUF),
                .BUF_RESULTS      ( ENABLE_BUF),
                .CTRL_T           ( ctrl_t                                      ),
                .DONT_CARE_ZERO   ( DONT_CARE_ZERO                              )
            ) sld (
                .clk_i            ( clk_i                                       ),
                .async_rst_ni     ( async_rst_ni                                ),
                .sync_rst_ni      ( sync_rst_ni                                 ),
                .pipe_in_valid_i  ( pipe_in_valid_i                             ),
                .pipe_in_ready_o  ( vsld_pipe_in_ready_o                             ),
                .pipe_in_ctrl_i   ( pipe_in_ctrl_i                              ),
                .pipe_in_op_i     ( pipe_in_op1_i                               ),
                .pipe_in_mask_i   ( pipe_in_mask_i                              ),
                .pipe_out_valid_o ( vsld_pipe_out_valid_o                            ),
                .pipe_out_ready_i ( pipe_out_ready_i                            ),
                .pipe_out_ctrl_o  ( vsld_pipe_out_ctrl_o                               ),
                .pipe_out_res_o   ( vsld_pipe_out_res_o                                ),
                .pipe_out_mask_o  ( vsld_pipe_out_mask_o                               )
            );

    vproc_elem #(
                .VREG_W                ( vproc_config::VREG_W                         ),
                .GATHER_OP_W           ( OPERAND_WIDTH                  ),
                .CTRL_T                ( ctrl_t                         ),
                .BUF_RESULTS           ( ENABLE_BUF                     ),
                .DONT_CARE_ZERO        ( DONT_CARE_ZERO                 )
            ) elem (
                .clk_i                 ( clk_i                          ),
                .async_rst_ni          ( async_rst_ni                   ),
                .sync_rst_ni           ( sync_rst_ni                    ),
                .pipe_in_valid_i       ( pipe_in_valid_i                ),
                .pipe_in_ready_o       ( velem_pipe_in_ready_o                ),
                .pipe_in_ctrl_i        ( pipe_in_ctrl_i                 ),
                .pipe_in_op1_i         ( pipe_in_op1_i     ),
                .pipe_in_op2_i         ( pipe_in_op2_i     ),
                .pipe_in_op2_mask_i    ( pipe_in_op2_mask_i             ),
                .pipe_in_op_gather_i   ( pipe_in_op_gather_i            ),
                .pipe_in_mask_i        ( pipe_in_mask_i[0]               ),
                .pipe_out_valid_o      ( velem_pipe_out_valid_o                 ),
                .pipe_out_ready_i      ( pipe_out_ready_i                 ),
                .pipe_out_ctrl_o       ( velem_pipe_out_ctrl_o                  ),
                .pipe_out_xreg_valid_o ( pipe_out_xreg_valid_o            ),
                .pipe_out_xreg_data_o  ( pipe_out_xreg_data_o                    ),
                .pipe_out_xreg_addr_o  ( pipe_out_xreg_addr_o                    ),
                .pipe_out_res_valid_o  ( pipe_out_res_valid_o             ),
                .pipe_out_res_o        ( velem_pipe_out_res_o                   ),
                .pipe_out_mask_o       ( velem_pipe_out_mask_o             )
            );

        simd_div div(
            .clk_i(clk_i) ,
            .rst_ni(async_rst_ni) ,
            .operand_a_i(pipe_in_op1_i) ,
            .operand_b_i(pipe_in_op2_i) ,
            .mask_i(pipe_in_mask_i) ,       
            .op_i(op_i) ,
            .be_i(pipe_in_mask_i) ,         // Not sure if mask_i and be_i should get the same input, but be_i is used to skip masked elements, which is necessary.
            .vew_i(vew_i) ,
            .result_o(vdiv_pipe_out_res_o) ,
            .mask_o(vdiv_pipe_out_mask_o) ,
            .valid_i(pipe_in_valid_i) ,
            .ready_o(vdiv_pipe_in_ready_o) ,
            .ready_i(pipe_out_ready_i) ,
            .valid_o(vdiv_pipe_out_valid_o)         
            );

endmodule