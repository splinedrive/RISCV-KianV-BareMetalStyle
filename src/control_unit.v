/*
 *  kianv harris multicycle RISC-V rv32im
 *
 *  copyright (c) 2022 hirosh dabui <hirosh@dabui.de>
 *
 *  permission to use, copy, modify, and/or distribute this software for any
 *  purpose with or without fee is hereby granted, provided that the above
 *  copyright notice and this permission notice appear in all copies.
 *
 *  the software is provided "as is" and the author disclaims all warranties
 *  with regard to this software including all implied warranties of
 *  merchantability and fitness. in no event shall the author be liable for
 *  any special, direct, indirect, or consequential damages or any damages
 *  whatsoever resulting from loss of use, data or profits, whether in an
 *  action of contract, negligence or other tortious action, arising out of
 *  or in connection with the use or performance of this software.
 *
 */
`default_nettype none

`include "riscv_defines.vh"
/*verilator lint_off UNDRIVEN */
/*verilator lint_off UNUSEDSIGNAL*/
module control_unit (
    input  wire                        clk,
    input  wire                        resetn,
    input  wire [                 6:0] op,
    input  wire [                 2:0] funct3,
    input  wire [                 0:0] funct7b5,
    input  wire [                 0:0] funct7b1,
    input  wire [                 0:0] immb10,
    input  wire                        Zero,
    output wire [`RESULT_WIDTH   -1:0] ResultSrc,
    output wire [`ALU_CTRL_WIDTH -1:0] ALUControl,
    output wire [`SRCA_WIDTH     -1:0] ALUSrcA,
    output wire [`SRCB_WIDTH     -1:0] ALUSrcB,
    output wire [                 2:0] ImmSrc,
    output wire [`STORE_OP_WIDTH -1:0] STOREop,
    output wire [`LOAD_OP_WIDTH  -1:0] LOADop,
    output wire                        RegWrite,
    output wire                        PCWrite,
    output wire                        AdrSrc,
    output wire                        MemWrite,
    output wire                        IRWrite,
    output wire                        ALUOutWrite,

    output wire mem_valid,
    input  wire mem_ready,

    output wire alu_valid,
    input  wire alu_ready
);

  wire [`ALU_OP_WIDTH   -1:0] ALUOp;
  wire PCUpdate;
  wire Branch;

  wire taken_branch = !Zero;
  assign PCWrite = Branch & taken_branch | PCUpdate;

  main_fsm main_fsm_I (
      .clk        (clk),
      .resetn     (resetn),
      .op         (op),
      .funct7b1   (funct7b1),
      .Zero       (Zero),
      .AdrSrc     (AdrSrc),
      .IRWrite    (IRWrite),
      .ALUSrcA    (ALUSrcA),
      .ALUSrcB    (ALUSrcB),
      .ALUOp      (ALUOp),
      .ResultSrc  (ResultSrc),
      .ImmSrc     (ImmSrc),
      .PCUpdate   (PCUpdate),
      .Branch     (Branch),
      .RegWrite   (RegWrite),
      .ALUOutWrite(ALUOutWrite),
      .MemWrite   (MemWrite),
      .mem_valid  (mem_valid),
      .mem_ready  (mem_ready),

      .alu_valid(alu_valid),
      .alu_ready(alu_ready)
  );

  load_decoder load_decoder_I (
      funct3,
      LOADop
  );
  store_decoder store_decoder_I (
      funct3,
      STOREop
  );
  alu_decoder alu_decoder_I (
      immb10,
      op[5],
      funct3,
      funct7b5,
      ALUOp,
      ALUControl
  );

endmodule
/*verilator lint_on UNDRIVEN */
/*verilator lint_on UNUSEDSIGNAL*/
