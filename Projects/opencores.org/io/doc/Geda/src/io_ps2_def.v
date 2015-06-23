////////////////////////////////////////////////////////////////////
//     --------------                                             //
//    /      SOC     \                                            //
//   /       GEN      \                                           //
//  /     COMPONENT    \                                          //
//  ====================                                          //
//  |digital done right|                                          //
//  |__________________|                                          //
//                                                                //
//                                                                //
//                                                                //
//    Copyright (C) <2009>  <Ouabache DesignWorks>                //
//                                                                //
//                                                                //  
//   This source file may be used and distributed without         //  
//   restriction provided that this copyright statement is not    //  
//   removed from the file and that any derivative work contains  //  
//   the original copyright notice and the associated disclaimer. //  
//                                                                //  
//   This source file is free software; you can redistribute it   //  
//   and/or modify it under the terms of the GNU Lesser General   //  
//   Public License as published by the Free Software Foundation; //  
//   either version 2.1 of the License, or (at your option) any   //  
//   later version.                                               //  
//                                                                //  
//   This source is distributed in the hope that it will be       //  
//   useful, but WITHOUT ANY WARRANTY; without even the implied   //  
//   warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      //  
//   PURPOSE.  See the GNU Lesser General Public License for more //  
//   details.                                                     //  
//                                                                //  
//   You should have received a copy of the GNU Lesser General    //  
//   Public License along with this source; if not, download it   //  
//   from http://www.opencores.org/lgpl.shtml                     //  
//                                                                //  
////////////////////////////////////////////////////////////////////
 module 
  io_ps2_def 
     (
 input   wire                 clk,
 input   wire                 cs,
 input   wire                 enable,
 input   wire                 ps2_clk_pad_in,
 input   wire                 ps2_data_pad_in,
 input   wire                 rd,
 input   wire                 reset,
 input   wire                 wr,
 input   wire    [ 3 :  0]        addr,
 input   wire    [ 7 :  0]        wdata,
 output   wire                 ps2_clk_pad_oe,
 output   wire                 ps2_data_pad_oe,
 output   wire                 rcv_data_avail,
 output   wire    [ 7 :  0]        rdata);
reg                        ps2_data_read_stb;
wire                        buffer_empty;
wire                        busy;
wire                        poll_enable;
wire                        ps2_data_rd;
wire                        ps2_rx_clear;
wire                        read;
wire                        rx_frame_error;
wire                        rx_parity_cal;
wire                        rx_parity_error;
wire                        rx_parity_rcv;
wire                        tx_ack_error;
wire     [ 7 :  0]              cntrl;
wire     [ 7 :  0]              rcv_data;
wire     [ 7 :  0]              status;
wire     [ 7 :  0]              wdata_buf;
ps2_interface_def
#( .CLK_HOLD_DELAY (1),
   .DATA_SETUP_DELAY (14))
ps2 
   (
   .ps2_clk_pad_in      ( ps2_clk_pad_in  ),
   .ps2_clk_pad_oe      ( ps2_clk_pad_oe  ),
   .ps2_data_pad_in      ( ps2_data_pad_in  ),
   .ps2_data_pad_oe      ( ps2_data_pad_oe  ),
    .busy      ( busy  ),
    .clk      ( clk  ),
    .reset      ( reset  ),
    .rx_clear      ( ps2_rx_clear  ),
    .rx_data      ( rcv_data  ),
    .rx_frame_error      ( rx_frame_error  ),
    .rx_full      ( rcv_data_avail  ),
    .rx_parity_cal      ( rx_parity_cal  ),
    .rx_parity_error      ( rx_parity_error  ),
    .rx_parity_rcv      ( rx_parity_rcv  ),
    .rx_read      ( read  ),
    .tx_ack_error      ( tx_ack_error  ),
    .tx_buffer_empty      ( buffer_empty  ),
    .tx_data      ( wdata_buf  ),
    .tx_write      ( cntrl[1:1] ));
parameter PS2_DATA      = 4'h0;
parameter STATUS        = 4'h2;
parameter CNTRL         = 4'h4;
io_ps2_def_mb 
ps2_micro_reg
( 
   .clk                ( clk              ),
   .reset              ( reset            ),
   .enable             ( enable           ),		      
   .cs                 ( cs               ),		      
   .wr                 ( wr               ), 
   .rd                 ( rd               ),
   .addr               ( addr[3:0]        ),
   .byte_lanes         ( 1'b1             ),
   .wdata              ( wdata[7:0]       ),
   .rdata              ( rdata            ),
   .ps2_data_rdata     ( rcv_data         ),
   .ps2_data_dec       ( ps2_data_rd      ),
   .ps2_data_cs    (),
   .wdata_buf_cs (),
   .wdata_buf_dec (),
   .wdata_buf_wr_0 (),
   .status_cs (),
   .status_dec (),
   .cntrl_cs (),
   .cntrl_dec (),
   .cntrl_wr_0 (),
   .status_rdata       ({!buffer_empty   ,
                          rcv_data_avail ,
                          busy           ,
                          rx_parity_error,
                          rx_parity_rcv  ,
                          rx_parity_cal  ,
                          rx_frame_error ,
                          tx_ack_error }  ),
   .cntrl              ( cntrl            ),
   .cntrl_rdata        ( cntrl            ),
   .next_cntrl         ( cntrl            ),
   .wdata_buf          ( wdata_buf        ), 
   .next_wdata_buf     ( wdata_buf        )
);
always@(posedge clk)
if (reset) 
  begin
    ps2_data_read_stb <= 1'b0;
   end
else 
  begin
   ps2_data_read_stb  <= (  enable &&  ps2_data_rd  && rd );
  end
assign   ps2_rx_clear      = cntrl[0] ? read :rd && cs && enable && ps2_data_rd;
assign        poll_enable  =   cntrl[0];
  endmodule
 /*********************************************/  
 /* Vendor:                  opencores.org    */  
 /* Library:                            io    */  
 /* Component:                      io_ps2    */  
 /* Version:                           def    */  
 /* MemMap:                             mb    */  
 /* Base:                             0x00    */  
 /* Type:                                     */  
 /* Endian:                         Little    */  
 /*********************************************/  
 /* AddressBlock:              mb_microbus    */  
 /* NumBase:                             0    */  
 /* Range:                            0x10    */  
 /* NumRange:                           16    */  
 /* NumAddBits:                          4    */  
 /* Width:                               8    */  
 /* Byte_lanes:                          1    */  
 /* Byte_size:                           8    */  
 /*********************************************/  
 /* Reg Name:                     ps2_data    */  
 /* Reg Offset:                        0x0    */  
 /* Reg numOffset:                       0    */  
 /* Reg size:                            8    */  
 /* Reg Dim:                           0x1    */  
 /* Reg numDim:                          1    */  
 /* Reg DimBits:                         0    */  
 /* Reg Create:                          1    */  
 /* Reg access:                  read-only    */  
 /* Reg has_read:                        1    */  
 /* Reg has_write:                       0    */  
 /*********************************************/  
 /* Reg Name:                    wdata_buf    */  
 /* Reg Offset:                        0x0    */  
 /* Reg numOffset:                       0    */  
 /* Reg size:                            8    */  
 /* Reg Dim:                           0x1    */  
 /* Reg numDim:                          1    */  
 /* Reg DimBits:                         0    */  
 /* Reg Create:                          1    */  
 /* Reg access:                 write-only    */  
 /* Reg has_read:                        0    */  
 /* Reg has_write:                       1    */  
 /*********************************************/  
 /* Reg Name:                       status    */  
 /* Reg Offset:                        0x2    */  
 /* Reg numOffset:                       2    */  
 /* Reg size:                            8    */  
 /* Reg Dim:                           0x1    */  
 /* Reg numDim:                          1    */  
 /* Reg DimBits:                         0    */  
 /* Reg Create:                          1    */  
 /* Reg access:                  read-only    */  
 /* Reg has_read:                        1    */  
 /* Reg has_write:                       0    */  
 /*********************************************/  
 /* Reg Name:                        cntrl    */  
 /* Reg Offset:                        0x4    */  
 /* Reg numOffset:                       4    */  
 /* Reg size:                            8    */  
 /* Reg Dim:                           0x1    */  
 /* Reg numDim:                          1    */  
 /* Reg DimBits:                         0    */  
 /* Reg Create:                          1    */  
 /* Reg access:                 read-write    */  
 /* Reg has_read:                        1    */  
 /* Reg has_write:                       1    */  
 /*********************************************/  
 /*********************************************/  
 /* Max_dim:                             1    */  
 /* num_add:                             0    */  
 /* mas_has_read:                        1    */  
 /* mas_has_write:                       1    */  
 /* mas_has_create:                      1    */  
 /*********************************************/  
 /*********************************************/  
module io_ps2_def_mb
#(  parameter UNSELECTED = {8{1'b1}},
    parameter UNMAPPED   = {8{1'b0}},
    parameter WDATA_BUF_RST = 8'b0,
    parameter CNTRL_RST = 8'b0)
 (
 input  wire             clk,
 input  wire             reset,
 input  wire             enable,
 input  wire             cs,
 input  wire             wr,
 input  wire             rd,
 input  wire  [8-1:0]    wdata,
 output  reg  [8-1:0]    rdata,
 input  wire  [1-1:0]    byte_lanes,
 input  wire  [4-1:0]    addr,
 output  wire  ps2_data_cs  ,
 output   reg  ps2_data_dec  ,
 input  wire  [8-1:0]    ps2_data_rdata  ,
 output  wire  wdata_buf_cs  ,
 output   reg  wdata_buf_dec  ,
 output   reg  wdata_buf_wr_0  ,
 output  reg  [8-1:0]    wdata_buf  ,
 input  wire  [8-1:0]    next_wdata_buf  ,
 output  wire  status_cs  ,
 output   reg  status_dec  ,
 input  wire  [8-1:0]    status_rdata  ,
 output  wire  cntrl_cs  ,
 output   reg  cntrl_dec  ,
 input  wire  [8-1:0]    cntrl_rdata  ,
 output   reg  cntrl_wr_0  ,
 output  reg  [8-1:0]    cntrl  ,
 input  wire  [8-1:0]    next_cntrl  
);
parameter PS2_DATA = 4'd0;
parameter PS2_DATA_END = 4'd1;
parameter WDATA_BUF = 4'd0;
parameter WDATA_BUF_END = 4'd1;
parameter STATUS = 4'd2;
parameter STATUS_END = 4'd3;
parameter CNTRL = 4'd4;
parameter CNTRL_END = 4'd5;
 reg  [8-1:0]    rdata_i;
reg  [8-1:0]    wdata_buf_wdata;
reg  [8-1:0]    cntrl_wdata;
/*QQQ        Reg_Name     Reg_Access sys_byte_lanes  reg_byte_lanes reg_size  reg_add   ar_base log_byte_lane phy_byte_lane  reg_lane   pad_size        padding     bigend    */  
/*QQQ         ps2_data     read-only           1       1               8        0        0        0                 0           0           8            0          0       */  
/*QQQ        wdata_buf    write-only           1       1               8        0        0        0                 0           0           8            0          0       */  
/*QQQ           status     read-only           1       1               8        2        0        0                 0           0           8            0          0       */  
/*QQQ            cntrl    read-write           1       1               8        4        0        0                 0           0           8            0          0       */  
always@(*)
  if(rd && cs)
    begin
  if(byte_lanes[ 0 ])
   rdata[0*8+8-1:0*8] =  rdata_i[0*8+8-1:0*8];         
  else
                rdata[0*8+8-1:0*8] = UNMAPPED;
    end
  else          rdata[0*8+8-1:0*8] = UNSELECTED;
always@(*)
    case(addr[4-1:0])
PS2_DATA[4-1:0]:      rdata_i[0*8+8-1:0*8] =  ps2_data_rdata[0*8+8-1:0*8] ;//QQQQ
STATUS[4-1:0]:      rdata_i[0*8+8-1:0*8] =  status_rdata[0*8+8-1:0*8] ;//QQQQ
CNTRL[4-1:0]:      rdata_i[0*8+8-1:0*8] =  cntrl_rdata[0*8+8-1:0*8] ;//QQQQ
    default:    rdata_i[0*8+8-1:0*8] = UNMAPPED;
    endcase
always@(*)
    begin
wdata_buf_wdata      =  wdata[0*8+8-1:0];//    1
cntrl_wdata      =  wdata[0*8+8-1:0];//    1
    end
always@(*)
    begin
wdata_buf_wr_0 = cs && wr && enable && byte_lanes[ 0 ] && ( addr[4-1:0]== WDATA_BUF[4-1:0] ); //     
cntrl_wr_0 = cs && wr && enable && byte_lanes[ 0 ] && ( addr[4-1:0]== CNTRL[4-1:0] ); //     
    end
 always@(*)
     begin
        ps2_data_dec = cs && ( addr[4-1:0]== PS2_DATA[4-1:0] );//  1
        wdata_buf_dec = cs && ( addr[4-1:0]== WDATA_BUF[4-1:0] );//  1
        status_dec = cs && ( addr[4-1:0]== STATUS[4-1:0] );//  1
        cntrl_dec = cs && ( addr[4-1:0]== CNTRL[4-1:0] );//  1
     end
  /* verilator lint_off UNSIGNED */           
assign   ps2_data_cs = cs && ( addr >= PS2_DATA ) && ( addr < PS2_DATA_END );
assign   wdata_buf_cs = cs && ( addr >= WDATA_BUF ) && ( addr < WDATA_BUF_END );
assign   status_cs = cs && ( addr >= STATUS ) && ( addr < STATUS_END );
assign   cntrl_cs = cs && ( addr >= CNTRL ) && ( addr < CNTRL_END );
  /* verilator lint_on UNSIGNED */           
   always@(posedge clk)
     if(reset)  wdata_buf <=  WDATA_BUF_RST;
        else
       begin
    if(wdata_buf_wr_0)    wdata_buf[8-1:0]  <=  wdata_buf_wdata[8-1:0]  ;
    else    wdata_buf[8-1:0]   <=    next_wdata_buf[8-1:0];
     end
   always@(posedge clk)
     if(reset)  cntrl <=  CNTRL_RST;
        else
       begin
    if(cntrl_wr_0)    cntrl[8-1:0]  <=  cntrl_wdata[8-1:0]  ;
    else    cntrl[8-1:0]   <=    next_cntrl[8-1:0];
     end
endmodule 
