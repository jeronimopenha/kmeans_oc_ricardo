

module kmeans_pipeline_k3_d5 #
(
  parameter input_data_width = 16,
  parameter centroid_id_width = 2
)
(
  input clk,
  input [input_data_width-1:0] centroid0_d0,
  input [input_data_width-1:0] centroid0_d1,
  input [input_data_width-1:0] centroid0_d2,
  input [input_data_width-1:0] centroid0_d3,
  input [input_data_width-1:0] centroid0_d4,
  input [input_data_width-1:0] centroid1_d0,
  input [input_data_width-1:0] centroid1_d1,
  input [input_data_width-1:0] centroid1_d2,
  input [input_data_width-1:0] centroid1_d3,
  input [input_data_width-1:0] centroid1_d4,
  input [input_data_width-1:0] centroid2_d0,
  input [input_data_width-1:0] centroid2_d1,
  input [input_data_width-1:0] centroid2_d2,
  input [input_data_width-1:0] centroid2_d3,
  input [input_data_width-1:0] centroid2_d4,
  input [input_data_width-1:0] input_data0,
  input [input_data_width-1:0] input_data1,
  input [input_data_width-1:0] input_data2,
  input [input_data_width-1:0] input_data3,
  input [input_data_width-1:0] input_data4,
  output reg [input_data_width-1:0] output_data0,
  output reg [input_data_width-1:0] output_data1,
  output reg [input_data_width-1:0] output_data2,
  output reg [input_data_width-1:0] output_data3,
  output reg [input_data_width-1:0] output_data4,
  output reg [centroid_id_width-1:0] selected_centroid
);

  //Latency delay
  //1(sub) + 1(sqr) + ceil(log2(dimensions_qty)) (add) + ceil(log2(centroids_qty)) (comp)
  //for this one it is 7

  //pipeline stage 0 - Sub
  reg [16-1:0] sub_k0_d0_st0;
  reg [16-1:0] sub_k0_d1_st0;
  reg [16-1:0] sub_k0_d2_st0;
  reg [16-1:0] sub_k0_d3_st0;
  reg [16-1:0] sub_k0_d4_st0;
  reg [16-1:0] sub_k1_d0_st0;
  reg [16-1:0] sub_k1_d1_st0;
  reg [16-1:0] sub_k1_d2_st0;
  reg [16-1:0] sub_k1_d3_st0;
  reg [16-1:0] sub_k1_d4_st0;
  reg [16-1:0] sub_k2_d0_st0;
  reg [16-1:0] sub_k2_d1_st0;
  reg [16-1:0] sub_k2_d2_st0;
  reg [16-1:0] sub_k2_d3_st0;
  reg [16-1:0] sub_k2_d4_st0;

  //pipeline stage 1 - Sqr
  reg [32-1:0] sqr_k0_d0_st1;
  reg [32-1:0] sqr_k0_d1_st1;
  reg [32-1:0] sqr_k0_d2_st1;
  reg [32-1:0] sqr_k0_d3_st1;
  reg [32-1:0] sqr_k0_d4_st1;
  reg [32-1:0] sqr_k1_d0_st1;
  reg [32-1:0] sqr_k1_d1_st1;
  reg [32-1:0] sqr_k1_d2_st1;
  reg [32-1:0] sqr_k1_d3_st1;
  reg [32-1:0] sqr_k1_d4_st1;
  reg [32-1:0] sqr_k2_d0_st1;
  reg [32-1:0] sqr_k2_d1_st1;
  reg [32-1:0] sqr_k2_d2_st1;
  reg [32-1:0] sqr_k2_d3_st1;
  reg [32-1:0] sqr_k2_d4_st1;

  //pipeline Add reduction - 3 stages
  //we needed to add 2b to the add witdh because we need ceil(log2(reduction_stages)) to don´t have overflow
  reg [input_data_width+2-1:0] add0_k0_st2;
  reg [input_data_width+2-1:0] add1_k0_st2;
  reg [input_data_width+2-1:0] add2_k0_st2;
  reg [input_data_width+2-1:0] add3_k0_st3;
  reg [input_data_width+2-1:0] add4_k0_st3;
  reg [input_data_width+2-1:0] add5_k0_st4;
  reg [input_data_width+2-1:0] add0_k1_st2;
  reg [input_data_width+2-1:0] add1_k1_st2;
  reg [input_data_width+2-1:0] add2_k1_st2;
  reg [input_data_width+2-1:0] add3_k1_st3;
  reg [input_data_width+2-1:0] add4_k1_st3;
  reg [input_data_width+2-1:0] add5_k1_st4;
  reg [input_data_width+2-1:0] add0_k2_st2;
  reg [input_data_width+2-1:0] add1_k2_st2;
  reg [input_data_width+2-1:0] add2_k2_st2;
  reg [input_data_width+2-1:0] add3_k2_st3;
  reg [input_data_width+2-1:0] add4_k2_st3;
  reg [input_data_width+2-1:0] add5_k2_st4;

  always @(posedge clk) begin
    sub_k0_d0_st0 <= centroid0_d0 - input_data0;
    sub_k0_d1_st0 <= centroid0_d1 - input_data1;
    sub_k0_d2_st0 <= centroid0_d2 - input_data2;
    sub_k0_d3_st0 <= centroid0_d3 - input_data3;
    sub_k0_d4_st0 <= centroid0_d4 - input_data4;
    sub_k1_d0_st0 <= centroid1_d0 - input_data0;
    sub_k1_d1_st0 <= centroid1_d1 - input_data1;
    sub_k1_d2_st0 <= centroid1_d2 - input_data2;
    sub_k1_d3_st0 <= centroid1_d3 - input_data3;
    sub_k1_d4_st0 <= centroid1_d4 - input_data4;
    sub_k2_d0_st0 <= centroid2_d0 - input_data0;
    sub_k2_d1_st0 <= centroid2_d1 - input_data1;
    sub_k2_d2_st0 <= centroid2_d2 - input_data2;
    sub_k2_d3_st0 <= centroid2_d3 - input_data3;
    sub_k2_d4_st0 <= centroid2_d4 - input_data4;
    sqr_k0_d0_st1 <= sub_k0_d0_st0 * sub_k0_d0_st0;
    sqr_k0_d1_st1 <= sub_k0_d1_st0 * sub_k0_d1_st0;
    sqr_k0_d2_st1 <= sub_k0_d2_st0 * sub_k0_d2_st0;
    sqr_k0_d3_st1 <= sub_k0_d3_st0 * sub_k0_d3_st0;
    sqr_k0_d4_st1 <= sub_k0_d4_st0 * sub_k0_d4_st0;
    sqr_k1_d0_st1 <= sub_k1_d0_st0 * sub_k1_d0_st0;
    sqr_k1_d1_st1 <= sub_k1_d1_st0 * sub_k1_d1_st0;
    sqr_k1_d2_st1 <= sub_k1_d2_st0 * sub_k1_d2_st0;
    sqr_k1_d3_st1 <= sub_k1_d3_st0 * sub_k1_d3_st0;
    sqr_k1_d4_st1 <= sub_k1_d4_st0 * sub_k1_d4_st0;
    sqr_k2_d0_st1 <= sub_k2_d0_st0 * sub_k2_d0_st0;
    sqr_k2_d1_st1 <= sub_k2_d1_st0 * sub_k2_d1_st0;
    sqr_k2_d2_st1 <= sub_k2_d2_st0 * sub_k2_d2_st0;
    sqr_k2_d3_st1 <= sub_k2_d3_st0 * sub_k2_d3_st0;
    sqr_k2_d4_st1 <= sub_k2_d4_st0 * sub_k2_d4_st0;
    add0_k0_st2 <= sqr_k0_d0_st1 + sqr_k0_d1_st1;
    add1_k0_st2 <= sqr_k0_d2_st1 + sqr_k0_d3_st1;
    add2_k0_st2 <= sqr_k0_d4_st1;
    add3_k0_st3 <= add0_k0_st2 + add1_k0_st2;
    add4_k0_st3 <= add2_k0_st2;
    add5_k0_st4 <= add3_k0_st3 + add4_k0_st3;
    add0_k1_st2 <= sqr_k1_d0_st1 + sqr_k1_d1_st1;
    add1_k1_st2 <= sqr_k1_d2_st1 + sqr_k1_d3_st1;
    add2_k1_st2 <= sqr_k1_d4_st1;
    add3_k1_st3 <= add0_k1_st2 + add1_k1_st2;
    add4_k1_st3 <= add2_k1_st2;
    add5_k1_st4 <= add3_k1_st3 + add4_k1_st3;
    add0_k2_st2 <= sqr_k2_d0_st1 + sqr_k2_d1_st1;
    add1_k2_st2 <= sqr_k2_d2_st1 + sqr_k2_d3_st1;
    add2_k2_st2 <= sqr_k2_d4_st1;
    add3_k2_st3 <= add0_k2_st2 + add1_k2_st2;
    add4_k2_st3 <= add2_k2_st2;
    add5_k2_st4 <= add3_k2_st3 + add4_k2_st3;
  end


  initial begin
    output_data0 = 0;
    output_data1 = 0;
    output_data2 = 0;
    output_data3 = 0;
    output_data4 = 0;
    selected_centroid = 0;
    sub_k0_d0_st0 = 0;
    sub_k0_d1_st0 = 0;
    sub_k0_d2_st0 = 0;
    sub_k0_d3_st0 = 0;
    sub_k0_d4_st0 = 0;
    sub_k1_d0_st0 = 0;
    sub_k1_d1_st0 = 0;
    sub_k1_d2_st0 = 0;
    sub_k1_d3_st0 = 0;
    sub_k1_d4_st0 = 0;
    sub_k2_d0_st0 = 0;
    sub_k2_d1_st0 = 0;
    sub_k2_d2_st0 = 0;
    sub_k2_d3_st0 = 0;
    sub_k2_d4_st0 = 0;
    sqr_k0_d0_st1 = 0;
    sqr_k0_d1_st1 = 0;
    sqr_k0_d2_st1 = 0;
    sqr_k0_d3_st1 = 0;
    sqr_k0_d4_st1 = 0;
    sqr_k1_d0_st1 = 0;
    sqr_k1_d1_st1 = 0;
    sqr_k1_d2_st1 = 0;
    sqr_k1_d3_st1 = 0;
    sqr_k1_d4_st1 = 0;
    sqr_k2_d0_st1 = 0;
    sqr_k2_d1_st1 = 0;
    sqr_k2_d2_st1 = 0;
    sqr_k2_d3_st1 = 0;
    sqr_k2_d4_st1 = 0;
    add0_k0_st2 = 0;
    add1_k0_st2 = 0;
    add2_k0_st2 = 0;
    add3_k0_st3 = 0;
    add4_k0_st3 = 0;
    add5_k0_st4 = 0;
    add0_k1_st2 = 0;
    add1_k1_st2 = 0;
    add2_k1_st2 = 0;
    add3_k1_st3 = 0;
    add4_k1_st3 = 0;
    add5_k1_st4 = 0;
    add0_k2_st2 = 0;
    add1_k2_st2 = 0;
    add2_k2_st2 = 0;
    add3_k2_st3 = 0;
    add4_k2_st3 = 0;
    add5_k2_st4 = 0;
  end


endmodule

