module top (
  input  clk
, input  rst_n
// Ethernet PHY#1 TX
, input  phy1_125M_clk
, input  phy1_tx_clk
, output wire phy1_rst_n
, output wire phy1_gtx_clk = 1'b0
, output wire phy1_tx_en = 1'b0
, output wire[7:0] phy1_tx_data = 8'b0
// Ethernet PHY#1 RX
, input  phy1_rx_clk
, input  phy1_rx_dv
, input  phy1_rx_er
, input  [7:0] phy1_rx_data
, input  phy1_col
, input  phy1_crs //carrier sense
// Ethernet PHY#1 MII
, output wire phy1_mii_clk = 1'b0
, inout  wire phy1_mii_data = 1'b0
// Switch/LED
, input  [7:0] switch
, output [7:0] led
);

reg[10:0] counter;
reg[7:0]  rx_data[0:2047];

assign led[7:0] = ~rx_data[switch];

always @(posedge phy1_rx_clk) begin
  if (rst_n == 1'b0) begin
    counter <= 11'd0;
  end else begin
    if (phy1_rx_dv) begin
      rx_data[counter] <= phy1_rx_data;
      counter          <= counter + 11'd1;
    end else
      counter <= 11'd0;
  end
end

// cold reset (260 clock)
reg [8:0] cold_rst = 0;
wire cold_rst_end  = (cold_rst==9'd260);
assign phy1_rst_n  = cold_rst_end;
always @(posedge clock)
  cold_rst <= !cold_rst_end ? cold_rst + 9'd1 : 9'd260;

endmodule

