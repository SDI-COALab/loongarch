`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/24 14:44:19
// Design Name: 
// Module Name: uart_ctrl
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


`define RstEnable 1'b1
`define WAIT 2'b00
`define READ 2'b01
`define WRITE 2'b10

  module uart_ctrl(
    input wire clk,//ʱ���ź�
    input wire rst,//��λ�ź�
    //��bridge�ź�
    input wire ce_f_bridge,//ʹ��
    input wire we_f_bridge,//1��ʾд0��ʾ��
    input wire [31:0] vaddr_f_bridge,//�����ַ
    input wire [7:0] wdata_f_bridge, //д����
    output reg [7:0] rdata_t_bridge,//������
    output wire finish_t_bridge,//��д���
     output reg allowIn_t_bridge,
    //ֱ�������ź�
    input  wire rxd_f_pin,  //ֱ�����ڽ��ն�
   output wire txd_t_pin  //ֱ�����ڷ��Ͷ� 
  
    );
wire [7:0] ext_uart_rx;
wire [7:0] ext_uart_buffer;
wire ext_uart_ready, ext_uart_clear, ext_uart_busy;
reg ext_uart_start;
wire ext_uart_avai;


//ff��ʾ�洢�ڴ�������
reg [1:0] state_ff; //`WAIT,`READ,`WRITE
reg [1:0] next_state;  
reg [7:0] uart_data_ff;  //32'hBFD003F8�������
reg [7:0] uart_state_ff; //32'hBFD003FC�������
reg [7:0] next_uart_data; 
reg [7:0] next_uart_state; 

reg [7:0] ext_uart_tx_r;
reg pre_ext_uart_busy_ff;
reg [7:0] rdata_t_bridge_ff;
reg [7:0] next_rdata_t_bridge_r;
reg [7:0] ext_uart_tx_last_ff;
reg read_ch_ff;
reg next_read_ch_r;
always @(posedge clk or posedge rst) begin 
    if(rst==`RstEnable) begin 
        state_ff<=`WAIT; //�ȴ�״̬
        
        uart_data_ff<=8'b0;
        uart_state_ff<=8'b00000001;
        pre_ext_uart_busy_ff<=1'b0;
        rdata_t_bridge_ff<=8'b0;
        read_ch_ff<=1'b0;
        ext_uart_tx_last_ff<=8'b0;
    end
    else begin 
        state_ff<=next_state;
        read_ch_ff<=next_read_ch_r;
       
        uart_data_ff<=next_uart_data;
        uart_state_ff<=next_uart_state;
        pre_ext_uart_busy_ff<=ext_uart_busy;
        rdata_t_bridge_ff<=next_rdata_t_bridge_r;
        ext_uart_tx_last_ff<=wdata_f_bridge;
        
    end
end

//state��̬�߼�

reg finish_t_bridge_r;


reg ext_uart_clear_r;
always @(*) begin 
    next_state=`WAIT;
    next_read_ch_r=1'b0;
    next_uart_state=uart_state_ff;
    next_uart_data=uart_data_ff;
    ext_uart_clear_r=1'b0;
    ext_uart_start=1'b0;
    ext_uart_tx_r=8'b0;
    finish_t_bridge_r=1'b0;
    rdata_t_bridge=32'b0;
    next_rdata_t_bridge_r=uart_state_ff;
    allowIn_t_bridge=1'b1;
    case (state_ff)
    `WAIT:begin
            finish_t_bridge_r=1'b0;
            case ({ce_f_bridge,we_f_bridge})
                2'b00,2'b01: begin
                            next_state=`WAIT;
                            next_uart_data=ext_uart_ready==1'b1 ? ext_uart_rx : uart_data_ff;
                            ext_uart_clear_r=ext_uart_ready==1'b1 ? 1'b1 : 1'b0; 
                            next_uart_state[1]=ext_uart_ready==1'b1 ? 1'b1: uart_state_ff[1];  
                            next_uart_state[0]=  ({pre_ext_uart_busy_ff,ext_uart_busy}==2'b10) ? 1'b1 : uart_state_ff[0] ;     
                            ext_uart_start=1'b0;
                       end
                2'b10:begin
                            if(vaddr_f_bridge==32'hBFD003FC) begin
                                allowIn_t_bridge=1'b0;
                                next_state=`READ;
                                next_uart_state[1]=ext_uart_ready==1'b1 ? 1'b1: uart_state_ff[1];
                                 next_uart_state[0]=  ({pre_ext_uart_busy_ff,ext_uart_busy}==2'b10) ? 1'b1 : uart_state_ff[0];
                                next_uart_data=ext_uart_ready==1'b1 ? ext_uart_rx : uart_data_ff;
                                ext_uart_clear_r=ext_uart_ready==1'b1 ? 1'b1 : 1'b0; 
                                ext_uart_start=1'b0;
                                next_rdata_t_bridge_r=ext_uart_ready==1'b1 ? uart_state_ff|8'b00000010  : uart_state_ff;  
                                next_read_ch_r=1'b0;   
                                rdata_t_bridge=ext_uart_ready==1'b1 ? uart_state_ff|8'b00000010  : uart_state_ff;                             
                            end
                            else if(vaddr_f_bridge==32'hBFD003F8) begin
                                allowIn_t_bridge=1'b0;
                                next_state=`READ;
                                next_uart_state[1]=1'b0;
                                next_uart_state[0]=  ({pre_ext_uart_busy_ff,ext_uart_busy}==2'b10) ? 1'b1 : uart_state_ff[0];
                                next_uart_data=ext_uart_ready==1'b1 ? ext_uart_rx : uart_data_ff;
                                ext_uart_clear_r=ext_uart_ready==1'b1 ? 1'b1 : 1'b0; 
                                ext_uart_start=1'b0; 
                                next_read_ch_r=1'b1;
                                next_rdata_t_bridge_r=uart_data_ff;  
                                rdata_t_bridge=uart_data_ff;                                 
                            end 
                        end
                2'b11:begin
                            allowIn_t_bridge=1'b0;
                            next_state=`WRITE;
                            next_uart_state[0]=  1'b0;//({pre_ext_uart_busy_ff,ext_uart_busy}==2'b10) ? 1'b1 : 
                            next_uart_state[1]=ext_uart_ready==1'b1 ? 1'b1: uart_state_ff[1];
                            next_uart_data=ext_uart_ready==1'b1 ? ext_uart_rx : uart_data_ff;
                            ext_uart_clear_r=ext_uart_ready==1'b1 ? 1'b1 : 1'b0; 
                            ext_uart_start=1'b1;
                            ext_uart_tx_r=wdata_f_bridge;                 
                         end    
                   
            endcase

          end
     `READ:begin
                allowIn_t_bridge=1'b1;
                finish_t_bridge_r=1'b1;    
                next_state=`WAIT;
                next_uart_state[0]=  ({pre_ext_uart_busy_ff,ext_uart_busy}==2'b10) ? 1'b1 : uart_state_ff[0];
                next_uart_state[1]=ext_uart_ready==1'b1 ? 1'b1: uart_state_ff[1];
                next_uart_state[7:2]=uart_state_ff[7:2];
                next_uart_data=ext_uart_ready==1'b1 ? ext_uart_rx :
                                read_ch_ff==1'b1 ? 8'b0: uart_data_ff;
                ext_uart_clear_r=ext_uart_ready==1'b1 ? 1'b1 : 1'b0;
                ext_uart_start=1'b0;                 
                rdata_t_bridge=rdata_t_bridge_ff;
                
           end
     `WRITE:begin
                allowIn_t_bridge=1'b1; 
                finish_t_bridge_r=1'b1;     
                next_state=`WAIT;
                next_uart_state[0]=1'b0; 
                next_uart_state[1]=ext_uart_ready==1'b1 ? 1'b1: uart_state_ff[1];
                ext_uart_clear_r=ext_uart_ready==1'b1 ? 1'b1 : 1'b0; 
                next_uart_state[7:2]=uart_state_ff[7:2];
                ext_uart_start=1'b1;  
                ext_uart_tx_r=ext_uart_tx_last_ff;
                
                next_uart_data=ext_uart_ready==1'b1 ? ext_uart_rx : uart_data_ff;     
          end      
      default:begin
            allowIn_t_bridge=1'b1;
            next_state=`WAIT;
            next_uart_state=uart_state_ff;
            next_uart_data=uart_data_ff;
            ext_uart_clear_r=ext_uart_ready; 
            ext_uart_start=1'b0; 
            finish_t_bridge_r=1'b0;    
      end
  endcase
end
                    

                         


async_receiver #(.ClkFrequency(82000000),.Baud(9600)) //����ģ�飬9600�޼���λ
    ext_uart_r(
        .clk(clk),                       //�ⲿʱ���ź�
        .RxD(rxd_f_pin),                       //�ⲿ�����ź�����
        .RxD_data_ready(ext_uart_ready), //���ݽ��յ���־
        .RxD_clear(ext_uart_clear_r),      //������ձ�־
        .RxD_data(ext_uart_rx)           //���յ���һ�ֽ�����
    );
async_transmitter #(.ClkFrequency(82000000),.Baud(9600)) //����ģ�飬9600�޼���λ
    ext_uart_t(
        .clk(clk),                      //�ⲿʱ���ź�
        .TxD(txd_t_pin),                      //�����ź����
        .TxD_busy(ext_uart_busy),       //������æ״ָ̬ʾ
        .TxD_start(ext_uart_start),     //��ʼ�����ź�
        .TxD_data(ext_uart_tx_r)          //�����͵�����
    );

assign finish_t_bridge=finish_t_bridge_r;
endmodule