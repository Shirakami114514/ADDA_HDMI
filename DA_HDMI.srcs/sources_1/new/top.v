module top(
    input clk,
    input rst_n,
    input key_type,
    input key_freq,
    input key_mode,
    //data IO
    input [7:0] ad_data,
    output [7:0] da_data,
    //clk output
    output ad_clk,
    output da_clk,
    output adda_gnd,
    //HDMI output
    output           HDMI_en,                 //HDMI output enable
    output           tmds_clk_p,              //HDMI differential clock positive
    output           tmds_clk_n,              //HDMI differential clock negative
    output [2:0]     tmds_data_n,             //HDMI differential data negative
    output [2:0]     tmds_data_p              //HDMI differential data positive  
    );
    
    wire video_clk;
    wire video_clk5x;
    
    wire dac_clk;
    assign da_clk = dac_clk;
    assign ad_clk = dac_clk;
    //background layer display
    wire             background_hs;                //horizontal synchronization
    wire             background_vs;                //vertical synchronization
    wire             background_de;                //video valid
    wire[7:0]        background_r;                 //video red data
    wire[7:0]        background_g;                 //video green data
    wire[7:0]        background_b;                 //video blue data
    
    //grid layer display
    wire             grid_hs;                 //grid horizontal synchronization
    wire             grid_vs;                 //grid vertical synchronization
    wire             grid_de;                 //grid data valid
    wire[7:0]        grid_r;                  //grid red data
    wire[7:0]        grid_g;                  //grid green data
    wire[7:0]        grid_b;                  //grid blue data
    
    //wave layer display
    wire             wave_hs;                //wave horizontal synchronization            
    wire             wave_vs;                //wave vertical synchronization
    wire             wave_de;                //wave data valid
    wire[7:0]        wave_r;                 //wave red data
    wire[7:0]        wave_g;                 //wave green data
    wire[7:0]        wave_b;                 //wave blue data
    
    //RGB to DVI interface
    wire              hdmi_hs;                 //hdmi horizontal synchronization
    wire              hdmi_vs;                 //hdmi vertical synchronization
    wire              hdmi_de;                 //hdmi data valid
    wire[7:0]         hdmi_r;                  //hdmi red data
    wire[7:0]         hdmi_g;                  //hdmi green data
    wire[7:0]         hdmi_b;                  //hdmi blue data
    
    assign hdmi_hs = wave_hs;
    assign hdmi_vs = wave_vs;
    assign hdmi_de = wave_de;
    assign hdmi_r  = wave_r;
    assign hdmi_g  = wave_g; 
    assign hdmi_b  = wave_b;
    
    assign HDMI_en = 1'b1;
    assign adda_gnd = 1'b0;
    
    //Generate pixel & 5x pixel & DAC clock
    clk_wiz_0 clk_ins
     (
        .clk_out1(video_clk),     
        .clk_out2(video_clk5x),     
        .clk_out3(dac_clk),     
        .reset(1'b0), 
        .locked(),       
        .clk_in1(clk)
     );   
     
    //Generate background layer 
    background back_ins
    (
     .clk(video_clk),
     .rst(~rst_n),
     .hs(background_hs),
     .vs(background_vs),
     .de(background_de),
     .rgb_r(background_r),
     .rgb_g(background_g),
     .rgb_b(background_b)
     );
     
     //Generate grid layer
     grid grid_ins
     (
       .rst_n (rst_n),
       .pclk(video_clk),
       .i_hs(background_hs),
       .i_vs(background_vs),
       .i_de(background_de),
       .i_data({background_r,background_g,background_b}),
       .o_hs(grid_hs),
       .o_vs(grid_vs),
       .o_de(grid_de),
       .o_data({grid_r,grid_g,grid_b})
     );
     
    //Generate wave layer
    wav wav_ins(
	.rst_n(rst_n),   
	.pclk(video_clk),
	.key_type(key_type),
	.key_freq(key_freq),
	.key_mode(key_mode),
	.ad_data(ad_data),
	.adc_clk(dac_clk),
	.i_hs(grid_hs),    
	.i_vs(grid_vs),    
	.i_de(grid_de),	
	.i_data({grid_r,grid_g,grid_b}),
	.o_hs(wave_hs),
    .o_vs(wave_vs),
    .o_de(wave_de),
    .o_data({wave_r,wave_g,wave_b}),
    .da_buf_data(da_data)
   );
   
   //RGB to DVI
rgb2dvi
#(
.kGenerateSerialClk             (1'b0                     ),
.kClkRange                      (1                        ),     
.kRstActiveHigh                 (1'b1                     )
)
rgb2dvi_m0 
(
// DVI 1.0 TMDS video interface
.TMDS_Clk_p                     (tmds_clk_p               ),
.TMDS_Clk_n                     (tmds_clk_n               ),
.TMDS_Data_p                    (tmds_data_p              ),
.TMDS_Data_n                    (tmds_data_n              ),
//Auxiliary signals 
.aRst                           (1'b0                     ), //asynchronous reset; must be reset when RefClk is not within spec
.aRst_n                         (1'b1                     ), //-asynchronous reset; must be reset when RefClk is not within spec
// Video in
.vid_pData                      ({hdmi_r,hdmi_b,hdmi_g}   ),
.vid_pVDE                       (hdmi_de                  ),
.vid_pHSync                     (hdmi_hs                  ),
.vid_pVSync                     (hdmi_vs                  ),
.PixelClk                       (video_clk                ),

.SerialClk                      (video_clk5x              ) // 5x PixelClk
);
endmodule
