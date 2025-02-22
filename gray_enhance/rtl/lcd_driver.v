module lcd_driver
(
    input                lcd_pclk,    //时钟
    input                rst_n,       //复位，低电平有效
    input        [23:0]  pixel_data,  //像素数据
    output  reg  [10:0]  pixel_xpos,  //当前像素点横坐标
    output  reg  [10:0]  pixel_ypos,  //当前像素点纵坐标   
    output  reg  [10:0]  h_disp,      //LCD屏水平分辨率
    output  reg  [10:0]  v_disp,      //LCD屏垂直分辨率 
	output  reg          data_req,    //数据请求信号
    //RGB LCD接口
    output  reg          lcd_de,      //LCD 数据使能信号
    output               lcd_hs,      //LCD 行同步信号
    output               lcd_vs,      //LCD 场同步信号
    output               lcd_bl,      //LCD 背光控制信号
    output               lcd_clk,     //LCD 像素时钟
    output               lcd_rst,     //LCD复位
    output       [23:0]  lcd_rgb      //LCD RGB888颜色数据
);

//parameter define  
// 4.3' 800*480   
parameter  H_SYNC_4384   =  11'd128;    //行同步
parameter  H_BACK_4384   =  11'd88;     //行显示后沿
parameter  H_DISP_4384   =  11'd800;    //行有效数据
parameter  H_FRONT_4384  =  11'd40;     //行显示前沿
parameter  H_TOTAL_4384  =  11'd1056;   //行扫描周期
   
parameter  V_SYNC_4384   =  11'd2;      //场同步
parameter  V_BACK_4384   =  11'd33;     //场显示后沿
parameter  V_DISP_4384   =  11'd480;    //场有效数据
parameter  V_FRONT_4384  =  11'd10;     //场显示前沿
parameter  V_TOTAL_4384  =  11'd525;    //场扫描周期    

//reg define
reg  [10:0] h_sync ;
reg  [10:0] h_back ;
reg  [10:0] h_total;
reg  [10:0] v_sync ;
reg  [10:0] v_back ;
reg  [10:0] v_total;
reg  [10:0] h_cnt  ;
reg  [10:0] v_cnt  ;

initial
begin
	h_sync  = H_SYNC_4384; 
	h_back  = H_BACK_4384; 
	h_disp  = H_DISP_4384; 
	h_total = H_TOTAL_4384;
	v_sync  = V_SYNC_4384; 
	v_back  = V_BACK_4384; 
	v_disp  = V_DISP_4384; 
	v_total = V_TOTAL_4384;             
end

//*****************************************************
//**                    main code
//*****************************************************

//RGB LCD 采用DE模式时，行场同步信号需要拉高
assign  lcd_hs = 1'b1;        //LCD行同步信号
assign  lcd_vs = 1'b1;        //LCD场同步信号

assign  lcd_bl = 1'b1;        //LCD背光控制信号  
assign  lcd_clk = lcd_pclk;   //LCD像素时钟
assign  lcd_rst= 1'b1;        //LCD复位

//RGB888数据输出
assign lcd_rgb = lcd_de ? pixel_data : 24'd0;

//像素点x坐标
always@ (posedge lcd_pclk or negedge rst_n) 
begin
    if(!rst_n)
        pixel_xpos <= 11'd0;
    else if(data_req)
        pixel_xpos <= h_cnt + 2'd2 - h_sync - h_back ;
    else 
        pixel_xpos <= 11'd0;
end
   
//像素点y坐标   
always@ (posedge lcd_pclk or negedge rst_n) 
begin
    if(!rst_n)
        pixel_ypos <= 11'd0;
    else if(v_cnt >= (v_sync + v_back)&&v_cnt < (v_sync + v_back + v_disp))
        pixel_ypos <= v_cnt + 1'b1 - (v_sync + v_back) ;
    else 
        pixel_ypos <= 11'd0;
end
	
//数据使能信号		
always@ (posedge lcd_pclk or negedge rst_n) 
begin
    if(!rst_n)	
		lcd_de <= 1'b0;
	else
		lcd_de <= data_req;
end
				  
//请求像素点颜色数据输入  
always@ (posedge lcd_pclk or negedge rst_n) 
begin
    if(!rst_n)	
		data_req<=1'b0;
	else if((h_cnt >= h_sync + h_back - 2'd2) && (h_cnt < h_sync + h_back + h_disp - 2'd2)
             && (v_cnt >= v_sync + v_back) && (v_cnt < v_sync + v_back + v_disp))
		data_req <= 1'b1;
	else
		data_req <= 1'b0;
end
				  
//行计数器对像素时钟计数
always@ (posedge lcd_pclk or negedge rst_n)
begin
    if(!rst_n) 
        h_cnt <= 11'd0;
    else 
	begin
        if(h_cnt == h_total - 1'b1)
            h_cnt <= 11'd0;
        else
            h_cnt <= h_cnt + 1'b1;           
    end
end

//场计数器对行计数
always@ (posedge lcd_pclk or negedge rst_n) 
begin
    if(!rst_n) 
        v_cnt <= 11'd0;
    else 
	begin
        if(h_cnt == h_total - 1'b1) 
		begin
            if(v_cnt == v_total - 1'b1)
                v_cnt <= 11'd0;
            else
                v_cnt <= v_cnt + 1'b1;    
        end
    end    
end

endmodule