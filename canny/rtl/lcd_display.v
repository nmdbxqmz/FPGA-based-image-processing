module lcd_display
(
    input                lcd_pclk,    //ʱ��
    input                rst_n,       //��λ���͵�ƽ��Ч
    input        [10:0]  pixel_xpos,  //��ǰ���ص������
    input        [10:0]  pixel_ypos,  //��ǰ���ص�������  
    input        [10:0]  h_disp,      //LCD��ˮƽ�ֱ���
    input        [10:0]  v_disp,      //LCD����ֱ�ֱ���       
    output  reg  [23:0]  pixel_data   //��������
);

//parameter define
parameter  PIC_WIDTH    = 11'd250;    	 //ͼƬ���
parameter  PIC_HEIGHT   = 11'd250;    	 //ͼƬ�߶�
parameter  WIDTH 		= 8;		  	 //����λ��                   
localparam PIC_X_START  = 11'd10;      	 //ͼƬ��ʼ�������(>=2)
localparam PIC_X_DIVIDE = 11'd300;    	 //ͼƬ������������
localparam PIC_Y_START  = 11'd10;     	 //ͼƬ��ʼ��������(>=0)
localparam PRE_READ_NUM = 12'd3000;	 	 //Ԥ�����ص�����(=12��PIC_WIDTH)
localparam WHITE 		= 24'hFFFFFF; 

//reg define
reg   [15:0]  rom_addr_pic;  		//ROM��ַ(ͼƬ)
reg	  [11:0]  cnt_buffer;			//Ԥ�����ص������
reg			  buffer_valid_in;		//�л���1��������
reg			  buffer_valid_in2;		//�л���2��������
reg			  buffer_valid_in3;		//�л���3��������
reg			  buffer_valid_in4;		//�л���4��������
reg   [15:0]  rom_addr_buffer;  	//ROM��ַ(�л���)
reg			  matrix_valid_in;		//����1��������
reg			  matrix_valid_in2;		//����2��������
reg			  matrix_valid_in3;		//����3��������
reg			  matrix_valid_in4;		//����4��������
reg			  rd_en_all2;			//�л���2�������
reg			  rd_en_all3;			//�л���3�������

//wire define   
wire  [15:0]  		rom_addr;  			//ROM��ַ
wire          		rom_rd_en ;  		//ROM��ʹ���ź�
wire  [WIDTH-1:0]  	rom_rd_data ;		//ROM����
wire  [WIDTH-1:0] 	buffer_dout1_1;		
wire  [WIDTH-1:0]  	buffer_dout1_2;
wire  [WIDTH-1:0]  	buffer_dout1_3;
wire  [WIDTH-1:0] 	buffer_dout2_1;
wire  [WIDTH-1:0]  	buffer_dout2_2;
wire  [WIDTH-1:0]  	buffer_dout2_3;
wire  [WIDTH+1:0] 	buffer_dout3_1;
wire  [WIDTH+1:0]  	buffer_dout3_2;
wire  [WIDTH+1:0]  	buffer_dout3_3;
wire  [WIDTH-1:0] 	buffer_dout4_1;
wire  [WIDTH-1:0]  	buffer_dout4_2;
wire  [WIDTH-1:0]  	buffer_dout4_3;
wire		 		rst_fifo;			//fifo�л���1��2��3��4��λ�ź�
wire				rd_en_all;			//�л���1�������
wire				rd_en_all4;			//�л���4�������
wire		  		fifo_rst_busy;		//fifo�л���1��2��3��4��λ��æ�ź�
wire				m1_valid_out;		//����1�������
wire				m2_valid_out;		//����2�������
wire				m3_valid_out;		//����3�������
wire  [WIDTH-1:0]  	matrix_dout;		//����1���
wire  [WIDTH+1:0]  	matrix_dout2;		//����2���
wire  [WIDTH-1:0]  	matrix_dout3;		//����3���
wire  [WIDTH-1:0]  	matrix_dout4;		//����4���

//*****************************************************
//**                    main code
//*****************************************************
assign  rom_rd_en = 1'd1;                  //��ʹ�����ߣ���һֱ��ROM����
assign 	rom_addr = ((pixel_xpos >= PIC_X_START) && (pixel_xpos < PIC_X_START + PIC_WIDTH) 
					&& (pixel_ypos >= PIC_Y_START) && (pixel_ypos < PIC_Y_START + PIC_HEIGHT)) ? rom_addr_pic:rom_addr_buffer;									
assign	rst_fifo = 	(pixel_ypos == PIC_Y_START + PIC_HEIGHT - 4'd8 && pixel_xpos == PIC_X_START + PIC_WIDTH + PIC_X_DIVIDE - 4'd8) ? 1'b0:1'b1;					

//���ݵ�ǰ���ص�����ָ����ǰ���ص���ɫ����
always @(posedge lcd_pclk or negedge rst_n) 
begin
    if(!rst_n)
        pixel_data <= WHITE;
    else 
		begin
			if((pixel_xpos >= PIC_X_START) && (pixel_xpos < PIC_X_START + PIC_WIDTH) 
				&& (pixel_ypos >= PIC_Y_START) && (pixel_ypos < PIC_Y_START + PIC_HEIGHT))
				pixel_data <= {3{rom_rd_data}};  //��ʾͼƬ
			else if((pixel_ypos >= PIC_Y_START) && (pixel_ypos < PIC_Y_START + (PIC_HEIGHT - 4'd8)) 
					&& (pixel_xpos >= PIC_X_START + PIC_X_DIVIDE) && (pixel_xpos < PIC_X_START + (PIC_WIDTH - 4'd8) + PIC_X_DIVIDE)) 
				pixel_data <= {3{matrix_dout4}};
			else
				pixel_data <= WHITE;    
		end  
end

//���ݵ�ǰɨ���ĺ�������ΪROM��ַ(ͼƬ)��ֵ
always @(posedge lcd_pclk or negedge rst_n)
begin
    if(!rst_n)
        rom_addr_pic <= 16'd0;
    //����������λ��ͼƬ��ʾ����ʱ,�ۼ�ROM��ַ    
    else if((pixel_ypos >= PIC_Y_START) && (pixel_ypos < PIC_Y_START + PIC_HEIGHT) 
        && (pixel_xpos >= PIC_X_START - 1'd1) && (pixel_xpos < PIC_X_START + PIC_WIDTH - 1'd1)) 
        rom_addr_pic <= rom_addr_pic + 1'd1;
    //����������λ��ͼƬ�������һ�����ص�ʱ,ROM��ַ����    
    else if((pixel_ypos >= PIC_Y_START + PIC_HEIGHT))
        rom_addr_pic <= 16'd0;
	else
		rom_addr_pic <= rom_addr_pic;
end

//cnt_buffer�ۼӶ�Ԥ�����ص����
always @(posedge lcd_pclk or negedge rst_n)
begin
    if(!rst_n)
		cnt_buffer <= 12'd0;
	else if(pixel_ypos <= PIC_Y_START && (cnt_buffer <= PRE_READ_NUM + 12'd9) && !fifo_rst_busy)	
		cnt_buffer <= cnt_buffer + 1'd1;
	else if(!rst_fifo)
		cnt_buffer <= 12'd0;
	else
		cnt_buffer <= cnt_buffer;
end

//���ݵ�ǰɨ���ĺ�������ΪROM��ַ(�л���)��ֵ
always @(posedge lcd_pclk or negedge rst_n)
begin
    if(!rst_n)
        rom_addr_buffer <= 16'd0;
	else if(pixel_ypos <= PIC_Y_START && cnt_buffer < PRE_READ_NUM && !fifo_rst_busy)
		rom_addr_buffer <= rom_addr_buffer + 1'd1;
	else if((pixel_ypos >= PIC_Y_START) && (pixel_ypos < PIC_Y_START + (PIC_HEIGHT - 4'd12)) 
			&& (pixel_xpos >= PIC_X_START - 5'd24 + PIC_X_DIVIDE) && (pixel_xpos < PIC_X_START + PIC_WIDTH - 5'd24 + PIC_X_DIVIDE)) 
        rom_addr_buffer <= rom_addr_buffer + 1'd1;
    else if(!rst_fifo)
        rom_addr_buffer <= 16'd0;
	else
		rom_addr_buffer <= rom_addr_buffer;
end

//fifo1���������߼��ж�
always @(posedge lcd_pclk or negedge rst_n)
begin
    if(!rst_n)
		buffer_valid_in <= 1'd0;
	else if(pixel_ypos <= PIC_Y_START && cnt_buffer < PRE_READ_NUM && !fifo_rst_busy)
		buffer_valid_in <= 1'd1;
	else if((pixel_ypos >= PIC_Y_START) && (pixel_ypos < PIC_Y_START + (PIC_HEIGHT - 4'd12)) 
			&& (pixel_xpos >= PIC_X_START - 5'd24 + PIC_X_DIVIDE) && (pixel_xpos < PIC_X_START + PIC_WIDTH - 5'd24 + PIC_X_DIVIDE)) 
		buffer_valid_in <= 1'd1;
	else
		buffer_valid_in <= 1'd0;
end

//fifo1��������߼��ж�
assign	rd_en_all = ( ((pixel_xpos >= PIC_X_START - 5'd23 + PIC_X_DIVIDE) && (pixel_xpos < PIC_X_START + PIC_WIDTH - 5'd23 + PIC_X_DIVIDE) 
						&& (pixel_ypos >= PIC_Y_START) && (pixel_ypos < PIC_Y_START + PIC_HEIGHT - 4'd11))
						|| ((cnt_buffer >= 12'd751) && (cnt_buffer <= PRE_READ_NUM)) ) ? 1'b1:1'b0;	

//����1���������ж�
always @(posedge lcd_pclk or negedge rst_n)
begin
    if(!rst_n)
		matrix_valid_in <= 1'd0;
	else if(cnt_buffer >= 12'd750 && (cnt_buffer < PRE_READ_NUM + 12'd3))
		matrix_valid_in <= 1'd1;
	else if((pixel_ypos >= PIC_Y_START) && (pixel_ypos < PIC_Y_START + (PIC_HEIGHT - 4'd11)) 
			&& (pixel_xpos >= PIC_X_START - 5'd24 + PIC_X_DIVIDE) && (pixel_xpos < PIC_X_START + PIC_WIDTH - 5'd22 + PIC_X_DIVIDE)) 
		matrix_valid_in <= 1'd1;
	else
		matrix_valid_in <= 1'd0;
end						

//fifo2���������߼��ж�
always @(posedge lcd_pclk or negedge rst_n)
begin
    if(!rst_n)
		buffer_valid_in2 <= 1'd0;
	else if(cnt_buffer >= 12'd755 && (cnt_buffer < PRE_READ_NUM + 12'd3) && m1_valid_out)
		buffer_valid_in2 <= 1'd1;
	else if((pixel_ypos >= PIC_Y_START) && (pixel_ypos < PIC_Y_START + (PIC_HEIGHT - 4'd11)) 
			&& (pixel_xpos >= PIC_X_START - 5'd18 + PIC_X_DIVIDE) && (pixel_xpos < PIC_X_START + PIC_WIDTH - 5'd20 + PIC_X_DIVIDE)) 
		buffer_valid_in2 <= 1'd1;
	else
		buffer_valid_in2 <= 1'd0;
end

//fifo2��������߼��ж�
always @(posedge lcd_pclk or negedge rst_n)
begin
    if(!rst_n)
		rd_en_all2 <= 1'd0;
	else if((cnt_buffer >= 12'd1505) && (cnt_buffer < PRE_READ_NUM + 12'd3) && m1_valid_out)
		rd_en_all2 <= 1'd1;
	else if(((pixel_xpos >= PIC_X_START - 5'd18 + PIC_X_DIVIDE) && (pixel_xpos < PIC_X_START + PIC_WIDTH - 5'd20 + PIC_X_DIVIDE) 
			&& (pixel_ypos >= PIC_Y_START) && (pixel_ypos < PIC_Y_START + PIC_HEIGHT - 4'd10)) )
		rd_en_all2 <= 1'd1;
	else
		rd_en_all2 <= 1'd0;
end

//����2���������ж�
always @(posedge lcd_pclk or negedge rst_n)
begin
    if(!rst_n)
		matrix_valid_in2 <= 1'd0;
	else if(cnt_buffer >= 12'd1505 && (cnt_buffer < PRE_READ_NUM + 12'd6))
		matrix_valid_in2 <= 1'd1;
	else if((pixel_ypos >= PIC_Y_START) && (pixel_ypos < PIC_Y_START + (PIC_HEIGHT - 4'd10)) 
			&& (pixel_xpos >= PIC_X_START - 5'd18 + PIC_X_DIVIDE) && (pixel_xpos < PIC_X_START + PIC_WIDTH - 5'd18 + PIC_X_DIVIDE)) 
		matrix_valid_in2 <= 1'd1;
	else
		matrix_valid_in2 <= 1'd0;
end

//fifo3���������߼��ж�
always @(posedge lcd_pclk or negedge rst_n)
begin
    if(!rst_n)
		buffer_valid_in3 <= 1'd0;
	else if(cnt_buffer >= 12'd1510 && (cnt_buffer < PRE_READ_NUM + 12'd6) && m2_valid_out)
		buffer_valid_in3 <= 1'd1;
	else if((pixel_ypos >= PIC_Y_START) && (pixel_ypos < PIC_Y_START + (PIC_HEIGHT - 4'd10)) 
			&& (pixel_xpos >= PIC_X_START - 5'd12 + PIC_X_DIVIDE) && (pixel_xpos < PIC_X_START + PIC_WIDTH - 5'd16 + PIC_X_DIVIDE)) 
		buffer_valid_in3 <= 1'd1;
	else
		buffer_valid_in3 <= 1'd0;
end 

//fifo3��������߼��ж�
always @(posedge lcd_pclk or negedge rst_n)
begin
    if(!rst_n)
		rd_en_all3 <= 1'd0;
	else if((cnt_buffer >= 12'd2260) && (cnt_buffer < PRE_READ_NUM + 12'd6) && m2_valid_out)
		rd_en_all3 <= 1'd1;
	else if(((pixel_xpos >= PIC_X_START - 5'd12 + PIC_X_DIVIDE) && (pixel_xpos < PIC_X_START + PIC_WIDTH - 5'd16 + PIC_X_DIVIDE) 
			&& (pixel_ypos >= PIC_Y_START) && (pixel_ypos < PIC_Y_START + PIC_HEIGHT - 4'd9)) )
		rd_en_all3 <= 1'd1;
	else
		rd_en_all3 <= 1'd0;
end	

//����3���������ж�
always @(posedge lcd_pclk or negedge rst_n)
begin
    if(!rst_n)
		matrix_valid_in3 <= 1'd0;
	else if(cnt_buffer >= 12'd2260 && (cnt_buffer < PRE_READ_NUM + 12'd9))
		matrix_valid_in3 <= 1'd1;
	else if((pixel_ypos >= PIC_Y_START) && (pixel_ypos < PIC_Y_START + (PIC_HEIGHT - 4'd9)) 
			&& (pixel_xpos >= PIC_X_START - 4'd12 + PIC_X_DIVIDE) && (pixel_xpos < PIC_X_START + PIC_WIDTH - 4'd14 + PIC_X_DIVIDE)) 
		matrix_valid_in3 <= 1'd1;
	else
		matrix_valid_in3 <= 1'd0;
end

//fifo4���������߼��ж�
always @(posedge lcd_pclk or negedge rst_n)
begin
    if(!rst_n)
		buffer_valid_in4 <= 1'd0;
	else if(cnt_buffer >= 12'd2265 && (cnt_buffer < PRE_READ_NUM + 12'd9) && m3_valid_out)
		buffer_valid_in4 <= 1'd1;
	else if((pixel_ypos >= PIC_Y_START) && (pixel_ypos < PIC_Y_START + (PIC_HEIGHT - 4'd9)) 
			&& (pixel_xpos >= PIC_X_START - 5'd6 + PIC_X_DIVIDE) && (pixel_xpos < PIC_X_START + PIC_WIDTH - 5'd12 + PIC_X_DIVIDE)) 
		buffer_valid_in4 <= 1'd1;
	else
		buffer_valid_in4 <= 1'd0;
end

//fifo4��������߼��ж�
assign	rd_en_all4 = ((pixel_xpos >= PIC_X_START - 4'd5 + PIC_X_DIVIDE) && (pixel_xpos < PIC_X_START + PIC_WIDTH - 4'd11 + PIC_X_DIVIDE) 
					&& (pixel_ypos >= PIC_Y_START) && (pixel_ypos < PIC_Y_START + PIC_HEIGHT - 4'd8)) ? 1'b1:1'b0;

//����4���������ж�
always @(posedge lcd_pclk or negedge rst_n)
begin
    if(!rst_n)
		matrix_valid_in4 <= 1'd0;
	else if((pixel_ypos >= PIC_Y_START) && (pixel_ypos < PIC_Y_START + (PIC_HEIGHT - 4'd8)) 
			&& (pixel_xpos >= PIC_X_START - 4'd6 + PIC_X_DIVIDE) && (pixel_xpos < PIC_X_START + PIC_WIDTH - 4'd10 + PIC_X_DIVIDE)) 
		matrix_valid_in4 <= 1'd1;
	else
		matrix_valid_in4 <= 1'd0;
end

//ROM���洢ͼƬ
blk_mem_gen_0  blk_mem_gen_0 
(
	.clka  (lcd_pclk),    // input wire clka
	.ena   (rom_rd_en),   // input wire ena
	.addra (rom_addr),    // input wire [15 : 0] addra
	.douta (rom_rd_data)  // output wire [8 : 0] douta
);

//fifo�л���1
line_buffer 
#(	.PIC_WIDTH		(11'd250			))
u_line_buffer
(
	.clk            (lcd_pclk			),
	.rst_n          (rst_n				),
	.rst_fifo		(rst_fifo			),
	.din            (rom_rd_data		),
	.dout1          (buffer_dout1_1		),
	.dout2          (buffer_dout1_2		),
	.dout3          (buffer_dout1_3		),
	.rd_en_all		(rd_en_all			),
	.fifo_rst_busy	(fifo_rst_busy		),
	.valid_in       (buffer_valid_in	)
);

//fifo�л���2
line_buffer
#(	.PIC_WIDTH		(11'd248			))
u_line_buffer2
(
	.clk            (lcd_pclk			),
	.rst_n          (rst_n				),
	.rst_fifo		(rst_fifo			),
	.din            (matrix_dout		),
	.dout1          (buffer_dout2_1		),
	.dout2          (buffer_dout2_2		),
	.dout3          (buffer_dout2_3		),
	.rd_en_all		(rd_en_all2			),
	.fifo_rst_busy	(					),
	.valid_in       (buffer_valid_in2	)
);

//fifo�л���3
line_buffer
#(	.PIC_WIDTH		(11'd246			),                      
	.WIDTH			(4'd10				))
u_line_buffer3
(
	.clk            (lcd_pclk			),
	.rst_n          (rst_n				),
	.rst_fifo		(rst_fifo			),
	.din            (matrix_dout2		),
	.dout1          (buffer_dout3_1		),
	.dout2          (buffer_dout3_2		),
	.dout3          (buffer_dout3_3		),
	.rd_en_all		(rd_en_all3			),
	.fifo_rst_busy	(					),
	.valid_in       (buffer_valid_in3	)
);

//fifo�л���4
line_buffer
#(	.PIC_WIDTH		(11'd244			))
u_line_buffer4
(
	.clk            (lcd_pclk			),
	.rst_n          (rst_n				),
	.rst_fifo		(rst_fifo			),
	.din            (matrix_dout3		),
	.dout1          (buffer_dout4_1		),
	.dout2          (buffer_dout4_2		),
	.dout3          (buffer_dout4_3		),
	.rd_en_all		(rd_en_all4			),
	.fifo_rst_busy	(					),
	.valid_in       (buffer_valid_in4	)
);

//��˹ģ����������
matrix_gaussian u_matrix_gaussian
(
	.clk  			(lcd_pclk		),
	.rst_n          (rst_n			),
	.valid_in       (matrix_valid_in),
	.din1           (buffer_dout1_1	),
	.din2           (buffer_dout1_2	),
	.din3           (buffer_dout1_3	),
	.valid_out		(m1_valid_out	),
	.dout           (matrix_dout	)
); 

//sobel��������
matrix_sobel u_matrix_sobel
(
	.clk  			(lcd_pclk			),
	.rst_n          (rst_n				),
	.valid_in       (matrix_valid_in2	),
	.din1           (buffer_dout2_1		),
	.din2           (buffer_dout2_2		),
	.din3           (buffer_dout2_3		),
	.valid_out		(m2_valid_out		),
	.dout           (matrix_dout2		)
); 

//�Ǽ���ֵ���Ʋ�������
matrix_suppression
#(  .WIDTH			(4'd10				))
u_matrix_suppression
(
	.clk  			(lcd_pclk			),
	.rst_n          (rst_n				),
	.valid_in       (matrix_valid_in3	),
	.din1           (buffer_dout3_1		),
	.din2           (buffer_dout3_2		),
	.din3           (buffer_dout3_3		),
	.valid_out		(m3_valid_out		),
	.dout           (matrix_dout3		)
); 

//˫��ֵ����������
matrix_threshold u_matrix_threshold
(
	.clk  			(lcd_pclk			),
	.rst_n          (rst_n				),
	.valid_in       (matrix_valid_in4	),
	.din1           (buffer_dout4_1		),
	.din2           (buffer_dout4_2		),
	.din3           (buffer_dout4_3		),
	.dout           (matrix_dout4		)
);
 
endmodule
