module top (
  input  rstn
, input  FLIP_LANES
, input  refclkp
, input  refclkn
, input  hdinp
, input  hdinn
, output hdoutp
, output hdoutn
);

reg[19:0] rstn_cnt;
reg       core_rst_n;
wire      clk_125;
always @(posedge clk_125 or negedge rstn) begin
  if (!rstn) begin
    rstn_cnt   <= 20'd0 ;
    core_rst_n <= 1'b0 ;
  end else begin
    if (rstn_cnt[19])            // 4ms in real hardware
      core_rst_n <= 1'b1 ;
    else 
      rstn_cnt <= rstn_cnt + 1'b1 ;
  end
end

pcie_top pcie(
   .refclkp                    ( refclkp ),
   .refclkn                    ( refclkn ),
   .sys_clk_125                ( clk_125 ),
   .ext_reset_n                ( rstn ),
   .rstn                       ( core_rst_n ),
   .flip_lanes                 ( FLIP_LANES ),
   .hdinp0                     ( hdinp ),
   .hdinn0                     ( hdinn ),
   .hdoutp0                    ( hdoutp ),
   .hdoutn0                    ( hdoutn ),
   .msi                        (  8'd0 ),
   .inta_n                     (  1'b1 ),
   // This PCIe interface uses dynamic IDs.
   .vendor_id                  (16'h1204),
   .device_id                  (16'hec30),
   .rev_id                     (8'h00),
   .class_code                 (24'h000000),
   .subsys_ven_id              (16'h1204),
   .subsys_id                  (16'h3010),
   .load_id                    (1'b1),
   // Inputs
   .force_lsm_active           ( 1'b0 ),
   .force_rec_ei               ( 1'b0 ),
   .force_phy_status           ( 1'b0 ),
   .force_disable_scr          ( 1'b0 ),
   .hl_snd_beacon              ( 1'b0 ),
   .hl_disable_scr             ( 1'b0 ),
   .hl_gto_dis                 ( 1'b0 ),
   .hl_gto_det                 ( 1'b0 ),
   .hl_gto_hrst                ( 1'b0 ),
   .hl_gto_l0stx               ( 1'b0 ),
   .hl_gto_l1                  ( 1'b0 ),
   .hl_gto_l2                  ( 1'b0 ),
   .hl_gto_l0stxfts            ( 1'b0 ),
   .hl_gto_lbk                 ( 1'd0 ),
   .hl_gto_rcvry               ( 1'b0 ),
   .hl_gto_cfg                 ( 1'b0 ),
   .no_pcie_train              ( 1'b0 ),
   // Power Management Interface
   .tx_dllp_val                ( 2'd0 ),
   .tx_pmtype                  ( 3'd0 ),
   .tx_vsd_data                ( 24'd0 ),
   .tx_nlfy_vc0                ( 1'b0 ), 
   .ph_buf_status_vc0       ( 1'b0 ),
   .pd_buf_status_vc0       ( 1'b0 ),
   .nph_buf_status_vc0      ( 1'b0 ),
   .npd_buf_status_vc0      ( 1'b0 ),
   .npd_num_vc0             ( 8'd1 ),
   // From User logic
   .cmpln_tout                 ( 1'b0 ),
   .cmpltr_abort_np            ( 1'b0 ),
   .cmpltr_abort_p             ( 1'b0 ),
   .unexp_cmpln                ( 1'b0 ),
   .ur_np_ext                  ( 1'b0 ),
   .ur_p_ext                   ( 1'b0 ),
   .np_req_pend                ( 1'b0 ),
   .pme_status                 ( 1'b0 )
);

endmodule

