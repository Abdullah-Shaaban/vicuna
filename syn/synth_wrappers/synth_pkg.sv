package synth_pkg;
    import vproc_pkg::*;
    import vproc_config::*;
    
    // parameter bit [VLSU_FLAGS_W-1:0] VLSU_FLAGS = (VLSU_FLAGS_W'(1) << 0);//VLSU_ALIGNED_UNITSTRID);
    // parameter bit [BUF_FLAGS_W -1:0] BUF_FLAGS  = (BUF_FLAGS_W'(1) << BUF_DEQUEUE  ) |
    //                                                (BUF_FLAGS_W'(1) << BUF_VREG_PEND);
    // typedef struct packed {
    //         logic [2:0]                    count_mul;
    //         logic                          first_cycle;
    //         logic                          last_cycle;
    //         logic                          init_addr;       // initialize address (used by LSU)
    //         logic                          requires_flush;
    //         logic                          alt_count_valid; // alternative counter value is valid
    //         logic [$clog2(VREG_W/ PIPE_W[0])-1:0]      aux_count;
    //         // logic [XIF_ID_W-1:0]           id;
    //         op_unit                        unit;
    //         op_mode                        mode;
    //         cfg_vsew                       eew;             // effective element width
    //         cfg_emul                       emul;            // effective MUL factor
    //         cfg_vxrm                       vxrm;
    //         logic [$clog2( PIPE_W[0]/8)-1:0] vl_part;
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

        // For Ara's Divider - Copied from Ara & CVA6 packages
        typedef logic [PIPE_W[0]-1:0] elen_t;   // ELEN=32bit
        typedef enum logic [7:0] {
            // Arithmetic and logic instructions
            VADD, VSUB, VADC, VSBC, VRSUB, VMINU, VMIN, VMAXU, VMAX, VAND, VOR, VXOR,
            // Fixed point
            VSADDU, VSADD, VSSUBU, VSSUB, VAADDU, VAADD, VASUBU, VASUB, VSSRL, VSSRA, VNCLIP, VNCLIPU,
            // Shifts,
            VSLL, VSRL, VSRA, VNSRL, VNSRA,
            // Merge
            VMERGE,
            // Scalar moves to VRF
            VMVSX, VFMVSF,
            // Integer Reductions
            VREDSUM, VREDAND, VREDOR, VREDXOR, VREDMINU, VREDMIN, VREDMAXU, VREDMAX, VWREDSUMU, VWREDSUM,
            // Mul/Mul-Add
            VMUL, VMULH, VMULHU, VMULHSU, VMACC, VNMSAC, VMADD, VNMSUB,
            // Fixed point multiplication
            VSMUL,
            // Div
            VDIVU, VDIV, VREMU, VREM,
            // FPU
            VFADD, VFSUB, VFRSUB, VFMUL, VFDIV, VFRDIV, VFMACC, VFNMACC, VFMSAC, VFNMSAC, VFMADD, VFNMADD, VFMSUB,
            VFNMSUB, VFSQRT, VFMIN, VFMAX, VFREC7, VFRSQRT7, VFCLASS, VFSGNJ, VFSGNJN, VFSGNJX, VFCVTXUF, VFCVTXF, VFCVTFXU, VFCVTFX,
            VFCVTRTZXUF, VFCVTRTZXF, VFNCVTRODFF, VFCVTFF,
            // Floating-point reductions
            VFREDUSUM, VFREDOSUM, VFREDMIN, VFREDMAX, VFWREDUSUM, VFWREDOSUM,
            // Floating-point comparison instructions
            VMFEQ, VMFLE, VMFLT, VMFNE, VMFGT, VMFGE,
            // Integer comparison instructions
            VMSEQ, VMSNE, VMSLTU, VMSLT, VMSLEU, VMSLE, VMSGTU, VMSBF, VMSOF, VMSIF, VIOTA, VID, VCPOP, VFIRST, VMSGT,
            // Integer add-with-carry and subtract-with-borrow carry-out instructions
            VMADC, VMSBC,
            // Mask operations
            VMANDNOT, VMAND, VMOR, VMXOR, VMORNOT, VMNAND, VMNOR, VMXNOR,
            // Scalar moves from VRF
            VMVXS, VFMVFS,
            // Slide instructions
            VSLIDEUP, VSLIDEDOWN,
            // Load instructions
            VLE, VLSE, VLXE,
            // Store instructions
            VSE, VSSE, VSXE
        } ara_op_e;
        typedef enum logic [2:0] {
            EW8    = 3'b000,
            EW16   = 3'b001,
            EW32   = 3'b010
            // EW64   = 3'b011,
            // EW128  = 3'b100,
            // EW256  = 3'b101,
            // EW512  = 3'b110,
            // EW1024 = 3'b111
        } vew_e;


endpackage