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
localparam PIC_X_START  = 11'd2;      //ͼƬ��ʼ�������(>=2)
localparam PIC_X_DIVIDE = 11'd300;    //ͼƬ������������
localparam PIC_Y_START  = 11'd0;      //ͼƬ��ʼ��������(>=0)
localparam PIC_WIDTH    = 11'd250;    //ͼƬ���
localparam PIC_HEIGHT   = 11'd250;    //ͼƬ�߶�
localparam WHITE 		= 24'hFFFFFF; 

//reg define
reg   [15:0]  rom_addr_pic;  		//ROM��ַ(ԭͼ)
reg   [15:0]  rom_addr_gray;  		//ROM��ַ(�Ҷ�)
reg	  [7:0]   gray;					//�Ҷ�����ֵ

//wire define   
wire  [15:0]  rom_addr;  			//ROM��ַ
wire          rom_rd_en ;  			//ROM��ʹ���ź�
wire  [23:0]  rom_rd_data ;			//ROM����

//*****************************************************
//**                    main code
//*****************************************************
assign  rom_rd_en = 1'b1;                  //��ʹ�����ߣ���һֱ��ROM����
assign 	rom_addr = ((pixel_xpos >= PIC_X_START) && (pixel_xpos < PIC_X_START + PIC_WIDTH) 
					&& (pixel_ypos >= PIC_Y_START) && (pixel_ypos < PIC_Y_START + PIC_HEIGHT)) ? rom_addr_pic:rom_addr_gray;				

//���ݵ�ǰ���ص�����ָ����ǰ���ص���ɫ����
always @(posedge lcd_pclk or negedge rst_n) 
begin
    if(!rst_n)
        pixel_data <= WHITE;
    else 
		begin
			if( (pixel_xpos >= PIC_X_START) && (pixel_xpos < PIC_X_START + PIC_WIDTH) 
				&& (pixel_ypos >= PIC_Y_START) && (pixel_ypos < PIC_Y_START + PIC_HEIGHT) )
				pixel_data <= rom_rd_data;  //��ʾͼƬ
			else if((pixel_ypos >= PIC_Y_START) && (pixel_ypos < PIC_Y_START + PIC_HEIGHT) 
				&& (pixel_xpos >= PIC_X_START + PIC_X_DIVIDE) && (pixel_xpos < PIC_X_START + PIC_WIDTH + PIC_X_DIVIDE))
				begin
					if(gray < 9'd255)
						pixel_data <= {3{gray[7:0]}};
					else
						pixel_data <= 24'hFFFFFF;
				end
			else
				pixel_data <= WHITE;    
		end  
end

//���ݵ�ǰɨ���ĺ�������ΪROM��ַ(ԭͼ)��ֵ
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

//���ݵ�ǰɨ���ĺ�������ΪROM��ַ(�Ҷ�)��ֵ
always @(posedge lcd_pclk or negedge rst_n)
begin
    if(!rst_n)
        rom_addr_gray <= 16'd0;
	else if((pixel_ypos >= PIC_Y_START) && (pixel_ypos < PIC_Y_START + PIC_HEIGHT) 
			&& (pixel_xpos >= PIC_X_START - 1'd1 + PIC_X_DIVIDE) && (pixel_xpos < PIC_X_START + PIC_WIDTH - 1'd1 + PIC_X_DIVIDE)) 
        rom_addr_gray <= rom_addr_gray + 1'd1;
    else if(pixel_ypos >= PIC_Y_START + PIC_HEIGHT)
        rom_addr_gray <= 16'd0;
	else
		rom_addr_gray <= rom_addr_gray;
end

//����Ҷ�ֵ
always @(posedge lcd_pclk or negedge rst_n)
begin
    if(!rst_n)
		gray <= 9'd0;
	else if((pixel_ypos >= PIC_Y_START) && (pixel_ypos < PIC_Y_START + PIC_HEIGHT) 
			&& (pixel_xpos >= PIC_X_START - 1'd1 + PIC_X_DIVIDE) && (pixel_xpos < PIC_X_START + PIC_WIDTH - 1'd1 + PIC_X_DIVIDE)) 
		gray <=	((((29*rom_rd_data[7:0] + 150*rom_rd_data[15:8] + 76*rom_rd_data[23:16]) >> 8)*589) >> 9);
	else
		gray <= gray;
end

//ROM���洢ͼƬ
blk_mem_gen_0  blk_mem_gen_0 
(
	.clka  (lcd_pclk),    // input wire clka
	.ena   (rom_rd_en),   // input wire ena
	.addra (rom_addr),    // input wire [16 : 0] addra
	.douta (rom_rd_data)  // output wire [23 : 0] douta
);

endmodule
