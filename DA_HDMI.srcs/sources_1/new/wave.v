module wav(
	input                       rst_n,   
	input                       pclk,
	input                       key_type,
	input                       key_freq,
	input                       key_mode,
	input[7:0]                  ad_data,
	input                       adc_clk,
	input                       i_hs,    
	input                       i_vs,    
	input                       i_de,	
	input[23:0]                 i_data,  
	output                      o_hs,    
	output                      o_vs,    
	output                      o_de,    
	output[23:0]                o_data,
	output reg[7:0]            da_buf_data 
);
wire[11:0] pos_x;
wire[11:0] pos_y;
wire       pos_hs;
wire       pos_vs;
wire       pos_de;
wire[23:0] pos_data;
wire[7:0]  da_buf_data_sin;
wire[7:0]  da_buf_data_square;
wire[7:0]  da_buf_data_triangle;
wire[7:0]  da_buf_data_sawtooth;

reg[23:0]  v_data;
reg[8:0]   rdaddress;
wire[7:0]  q;
reg[11:0] da_addr;
reg        region_active;

reg [23:0]   wave_color;
wire key_freq_down;
wire key_type_down;
wire key_mode_down;
reg [9:0] freq_clk_cnt;
reg [2:0] freq_ctol;
reg [1:0] key_freq_cnt;
reg [1:0] key_type_cnt;
reg key_mode_cnt;

assign o_data = v_data;
assign o_hs = pos_hs;
assign o_vs = pos_vs;
assign o_de = pos_de;
always@(posedge pclk)
begin
	if(pos_y >= 12'd9 && pos_y <= 12'd308 && pos_x >= 12'd9 && pos_x  <= 12'd1018)
		region_active <= 1'b1;
	else
		region_active <= 1'b0;
end

always@(posedge pclk)
begin
	if(region_active == 1'b1 && pos_de == 1'b1)
		rdaddress <= rdaddress + freq_ctol;
	else
		rdaddress <= 9'd0;
end

key_debounce key_freq_dow
(
.clk             (pclk       ),     // input [0:0] clk
.rst             (~rst_n        ),      // input [0:0] rst_n
.button_in       (key_freq      ),
.button_posedge  (              ),
.button_negedge  (key_freq_down),
.button_out      (              )
);

key_debounce key_type_dow
(
.clk             (pclk      ),     // input [0:0] clk
.rst             (~rst_n        ),      // input [0:0] rst_n
.button_in       (key_type      ),
.button_posedge  (              ),
.button_negedge  (key_type_down),
.button_out      (              )
);

key_debounce key_mode_dow
(
.clk             (pclk      ),     // input [0:0] clk
.rst             (~rst_n        ),      // input [0:0] rst_n
.button_in       (key_mode      ),
.button_posedge  (              ),
.button_negedge  (key_mode_down),
.button_out      (              )
);


//控制频率的计数器
always@(posedge pclk or negedge rst_n)
begin
    if(!rst_n)
        key_freq_cnt <= 1'b0;
    else if(key_freq_down)
        key_freq_cnt <= key_freq_cnt + 1'b1;
    else
        key_freq_cnt <= key_freq_cnt;
end

always@(posedge pclk or negedge rst_n)
begin
    if(!rst_n)
        freq_ctol <= 1'b0;
     else begin
        case(key_freq_cnt)
            2'b00 : freq_ctol <= 3'b001;
            2'b01 : freq_ctol <= 3'b010;
            2'b10 : freq_ctol <= 3'b011;
            default : freq_ctol <= 3'b001;
         endcase
        end
end

//控制波形形状的计数器
always@(posedge pclk or negedge rst_n)
begin
    if(!rst_n)
        key_type_cnt <= 1'b0;
    else if(key_type_down)
        key_type_cnt <= key_type_cnt + 1'b1;
    else
        key_type_cnt <= key_type_cnt;
end

always@(posedge pclk or negedge rst_n)
begin
    if(!rst_n)
        da_buf_data <= 8'b0;
    else if(key_mode_cnt)begin
        da_buf_data <= ad_data;
        wave_color <= 24'h0000ff;
        end
    else begin
        wave_color <= 24'hffff00;
        case(key_type_cnt)
            2'b00 : da_buf_data <= da_buf_data_sin;
            2'b01 : da_buf_data <= da_buf_data_square;
            2'b10 : da_buf_data <= da_buf_data_triangle;
            2'b11 : da_buf_data <= da_buf_data_sawtooth;
        endcase
        end
end

//控制工作模式的计数器
always@(posedge pclk or negedge rst_n)
begin
    if(!rst_n)
        key_mode_cnt <= 1'b0;
    else if(key_mode_down)
        key_mode_cnt <= key_mode_cnt + 1'b1;
    else
        key_mode_cnt <= key_mode_cnt;
end

always@(posedge pclk)
begin
	if(region_active == 1'b1)
		if(12'd287 - pos_y == {4'd0,q})
			v_data <= wave_color;
		else
			v_data <= pos_data;
	else
		v_data <= pos_data;
end

always@(posedge adc_clk or negedge rst_n)
begin
    if(!rst_n)
        da_addr <= 0;
     else
        da_addr <= da_addr + 3'b100;
end



blk_mem_gen_sawtooth sawtooth_ins (
  .clka(adc_clk),    // input wire clka
  .addra(da_addr[11:3]),  // input wire [8 : 0] addra
  .douta(da_buf_data_sawtooth)  // output wire [7 : 0] douta
);

blk_mem_gen_sine sine_ins (
  .clka(adc_clk),    // input wire clka
  .addra(da_addr[11:3]),  // input wire [8 : 0] addra
  .douta(da_buf_data_sin)  // output wire [7 : 0] douta
);

blk_mem_gen_square square_ins (
  .clka(adc_clk),    // input wire clka
  .addra(da_addr[11:3]),  // input wire [8 : 0] addra
  .douta(da_buf_data_square)  // output wire [7 : 0] douta
);

blk_mem_gen_triangle triangle_ins (
  .clka(adc_clk),    // input wire clka
  .addra(da_addr[11:3]),  // input wire [8 : 0] addra
  .douta(da_buf_data_triangle)  // output wire [7 : 0] douta
);

blk_mem_gen_1 buffer_ins (
  .clka(adc_clk),    // input wire clka
  .wea(1'b1),       // input wire [0 : 0] wea
  .addra(da_addr[11:3]),  // input wire [8 : 0] addra
  .dina(da_buf_data),    // input wire [7 : 0] dina
  .clkb(pclk),    // input wire clkb
  .addrb(rdaddress),  // input wire [8 : 0] addrb
  .doutb(q)  // output wire [7 : 0] doutb
);



timing_gen timing_gen_ins(
	.rst_n    (rst_n    ),
	.clk      (pclk     ),
	.i_hs     (i_hs     ),
	.i_vs     (i_vs     ),
	.i_de     (i_de     ),
	.i_data   (i_data   ),
	.o_hs     (pos_hs   ),
	.o_vs     (pos_vs   ),
	.o_de     (pos_de   ),
	.o_data   (pos_data ),
	.x        (pos_x    ),
	.y        (pos_y    )
);
endmodule