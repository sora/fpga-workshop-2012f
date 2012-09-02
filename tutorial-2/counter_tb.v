`timescale 1ns / 1ns

module top_tb;

reg       clock;
reg       reset_n;
wire[7:0] led;

initial begin
  $dumpfile("counter.vcd");
  $dumpvars(0, top_tb);
end

initial begin
  $monitor($realtime,,"ps %h %h %h ",clock,reset_n,led);
end

top top_tb (
  .clock(clock)
, .reset_n(reset_n)
, .led(led)
);

initial reset_n = 1'b0;
initial clock   = 1'b0;
always #1
  clock = ~clock;

initial begin
  #10 reset_n = 1'b1;
  #300 $finish;
end
endmodule

