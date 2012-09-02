module top  (   
   input rstn,
   input FLIP_LANES,
   input refclkp,
   input refclkn,
   input hdinp,
   input hdinn,                   
   output hdoutp,
   output hdoutn, 
   input [7:0] dip_switch,
   output [13:0] led_out,
   output dp
);

reg  [19:0] rstn_cnt;
reg  core_rst_n;
wire [15:0] rx_data, tx_data,  tx_dout_wbm, tx_dout_ur;
wire [6:0] rx_bar_hit;
wire [7:0] pd_num, pd_num_ur, pd_num_wb;

wire [15:0] pcie_dat_i, pcie_dat_o;
wire [31:0] pcie_adr;
wire [1:0] pcie_sel;  
wire [2:0] pcie_cti;
wire pcie_cyc;
wire pcie_we;
wire pcie_stb;
wire pcie_ack;

wire [7:0] bus_num ; 
wire [4:0] dev_num ; 
wire [2:0] func_num ;

wire [8:0] tx_ca_ph ;
wire [12:0] tx_ca_pd  ;
wire [8:0] tx_ca_nph ;
wire [12:0] tx_ca_npd ;
wire [8:0] tx_ca_cplh;
wire [12:0] tx_ca_cpld ;
wire clk_125;
wire tx_eop_wbm;
// Reset management
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
   .tx_req_vc0                 ( tx_req ),    
   .tx_data_vc0                ( tx_data ),    
   .tx_st_vc0                  ( tx_st ), 
   .tx_end_vc0                 ( tx_end ), 
   .tx_nlfy_vc0                ( 1'b0 ), 
   .ph_buf_status_vc0       ( 1'b0 ),
   .pd_buf_status_vc0       ( 1'b0 ),
   .nph_buf_status_vc0      ( 1'b0 ),
   .npd_buf_status_vc0      ( 1'b0 ),
   .ph_processed_vc0        ( ph_cr ),
   .pd_processed_vc0        ( pd_cr ),
   .nph_processed_vc0       ( nph_cr ),
   .npd_processed_vc0       ( npd_cr ),
   .pd_num_vc0              ( pd_num ),
   .npd_num_vc0             ( 8'd1 ),   
   // From User logic
   .cmpln_tout                 ( 1'b0 ),       
   .cmpltr_abort_np            ( 1'b0 ),
   .cmpltr_abort_p             ( 1'b0 ),
   .unexp_cmpln                ( 1'b0 ),
   .ur_np_ext                  ( 1'b0 ),       
   .ur_p_ext                   ( 1'b0 ),
   .np_req_pend                ( 1'b0 ),     
   .pme_status                 ( 1'b0 ),      
   .tx_rdy_vc0                 ( tx_rdy),  
   .tx_ca_ph_vc0               ( tx_ca_ph),
   .tx_ca_pd_vc0               ( tx_ca_pd),
   .tx_ca_nph_vc0              ( tx_ca_nph),
   .tx_ca_npd_vc0              ( tx_ca_npd ), 
   .tx_ca_cplh_vc0             ( tx_ca_cplh ),
   .tx_ca_cpld_vc0             ( tx_ca_cpld ),
   .tx_ca_p_recheck_vc0        ( tx_ca_p_recheck ),
   .tx_ca_cpl_recheck_vc0      ( tx_ca_cpl_recheck ),
   .rx_data_vc0                ( rx_data),    
   .rx_st_vc0                  ( rx_st),     
   .rx_end_vc0                 ( rx_end),   
   .rx_us_req_vc0              ( rx_us_req ), 
   .rx_malf_tlp_vc0            ( rx_malf_tlp ), 
   .rx_bar_hit                 ( rx_bar_hit ), 
   // From Config Registers
   .bus_num                    ( bus_num  ),           
   .dev_num                    ( dev_num  ),           
   .func_num                   ( func_num  )
);

reg rx_st_d;
reg tx_st_d;
reg [15:0] tx_tlp_cnt;
reg [15:0] rx_tlp_cnt;
always @(posedge clk_125 or negedge core_rst_n)
   if (!core_rst_n) begin
      tx_st_d <= 0;
      rx_st_d <= 0;
      tx_tlp_cnt <= 0;
      rx_tlp_cnt <= 0;
   end else begin
      tx_st_d <= tx_st;
      rx_st_d <= rx_st;
      if (tx_st_d) tx_tlp_cnt <= tx_tlp_cnt + 1;
      if (rx_st_d) rx_tlp_cnt <= rx_tlp_cnt + 1;
   end

ip_rx_crpr cr (.clk(clk_125), .rstn(core_rst_n), .rx_bar_hit(rx_bar_hit),
               .rx_st(rx_st), .rx_end(rx_end), .rx_din(rx_data),
               .pd_cr(pd_cr_ur), .pd_num(pd_num_ur), .ph_cr(ph_cr_ur), .npd_cr(npd_cr_ur), .nph_cr(nph_cr_ur)               
);

ip_crpr_arb crarb(.clk(clk_125), .rstn(core_rst_n), 
            .pd_cr_0(pd_cr_ur), .pd_num_0(pd_num_ur), .ph_cr_0(ph_cr_ur), .npd_cr_0(npd_cr_ur), .nph_cr_0(nph_cr_ur),
            .pd_cr_1(pd_cr_wb), .pd_num_1(pd_num_wb), .ph_cr_1(ph_cr_wb), .npd_cr_1(1'b0), .nph_cr_1(nph_cr_wb),               
            .pd_cr(pd_cr), .pd_num(pd_num), .ph_cr(ph_cr), .npd_cr(npd_cr), .nph_cr(nph_cr)               
);

ip_tx_arbiter #(.c_DATA_WIDTH (16))
           tx_arb(.clk(clk_125), .rstn(core_rst_n), .tx_val(1'b1),
                  .tx_req_0(tx_req_wbm), .tx_din_0(tx_dout_wbm), .tx_sop_0(tx_sop_wbm), .tx_eop_0(tx_eop_wbm), .tx_dwen_0(1'b0),                 
                  .tx_req_1(1'b0), .tx_din_1(16'd0), .tx_sop_1(1'b0), .tx_eop_1(1'b0), .tx_dwen_1(1'b0),
                  .tx_req_2(1'b0), .tx_din_2(16'd0), .tx_sop_2(1'b0), .tx_eop_2(1'b0), .tx_dwen_2(1'b0),
                  .tx_req_3(tx_req_ur), .tx_din_3(tx_dout_ur), .tx_sop_3(tx_sop_ur), .tx_eop_3(tx_eop_ur), .tx_dwen_3(1'b0),
                  .tx_rdy_0(tx_rdy_wbm), .tx_rdy_1(), .tx_rdy_2( ), .tx_rdy_3(tx_rdy_ur),
                  .tx_req(tx_req), .tx_dout(tx_data), .tx_sop(tx_st), .tx_eop(tx_end), .tx_dwen(),
                  .tx_rdy(tx_rdy)
                  
);                           

wb_tlc wb_tlc(.clk_125(clk_125), .wb_clk(clk_125), .rstn(core_rst_n),
              .rx_data(rx_data), .rx_st(rx_st), .rx_end(rx_end), .rx_bar_hit(rx_bar_hit),
              .wb_adr_o(pcie_adr), .wb_dat_o(pcie_dat_o), .wb_cti_o(pcie_cti), .wb_we_o(pcie_we), .wb_sel_o(pcie_sel), .wb_stb_o(pcie_stb), .wb_cyc_o(pcie_cyc), .wb_lock_o(), 
              .wb_dat_i(pcie_dat_i), .wb_ack_i(pcie_ack),
              .pd_cr(pd_cr_wb), .pd_num(pd_num_wb), .ph_cr(ph_cr_wb), .npd_cr(npd_cr_wb), .nph_cr(nph_cr_wb),
              .tx_rdy(tx_rdy_wbm),
              .tx_req(tx_req_wbm), .tx_data(tx_dout_wbm), .tx_st(tx_sop_wbm), .tx_end(tx_eop_wbm), .tx_ca_cpl_recheck(1'b0), .tx_ca_cplh(tx_ca_cplh), .tx_ca_cpld(tx_ca_cpld),
              .comp_id({bus_num, dev_num, func_num}),
              .debug()
);


// ------------------ User Application -------------------
// Wishbone BUS
// clk_125, core_rst_n
// pcie_adr[31:0], pcie_we, pcie_dat_o[15:0], pcie_dat_i[15:0], pcie_sel[1:0]
// pcie_cyc, pcie_stb, pcie_ack, pcie_cti[2:0]
reg [15:0] wb_dat;
reg wb_ack;
always @(posedge clk_125 or negedge core_rst_n) begin
	if (!core_rst_n) begin
		wb_dat <= 16'h0;
	end else begin
		if (pcie_cyc & pcie_stb) begin
			wb_dat <= pcie_adr[15:0];
		end
	end
end

always @(posedge clk_125 or negedge core_rst_n)
	if (!core_rst_n) begin
		wb_ack <= 0;
	end else begin
		wb_ack <= pcie_cyc & pcie_stb & (~wb_ack);
	end

assign pcie_dat_i = wb_dat;
assign pcie_ack = wb_ack;
assign led_out = 14'h0;          
endmodule
