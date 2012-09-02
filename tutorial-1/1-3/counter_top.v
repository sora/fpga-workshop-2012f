module top (
  input clock
, input reset_n
, output [7:0] led
);

reg[31:0] counter = 32'd0;
wire        reset = ~reset_n;
assign        led = ~counter[31:24];

always @(posedge clock) begin
  if (reset)
    counter <= 32'd0;
  else
    counter <= counter + 32'd1;
end
endmodule

