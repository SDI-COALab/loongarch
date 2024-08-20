`timescale 1ns / 1ps

module ALU_Control_FSM_tb;

    // ����̨�ź�
    reg clk;
    reg reset;
    reg [9:0] exeCtrl_bus;
    reg [31:0] alu_src1;
    reg [31:0] alu_src2;
    wire [31:0] exe_result;
    wire stallReq_EXE;
    wire [2:0] counter;
     wire [31:0] mult_result;
    // ʵ��������ģ��
    EXE uut (
        .clk(clk),
        .rst(reset),
        .exeCtrl_bus(exeCtrl_bus),
        .alu_src1(alu_src1),
        .alu_src2(alu_src2),
        .exe_result(exe_result),
        .stallReq_EXE(stallReq_EXE)
    );
    wire [63:0] alu_mul_result;
   assign alu_mul_result=alu_src1 * alu_src2;
  wire[31:0] mr;
  assign mr=alu_mul_result[31:0];
   assign counter=uut.mult_count;
   assign mult_result=uut.mult_result;
    // ����ʱ��
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10nsʱ������
    end
    
    // ��ʼ���ͼ���
    initial begin
        // ��ʼ��
        reset = 1;
        exeCtrl_bus = 10'b0;
        alu_src1 = 32'b0;
        alu_src2 = 32'b0;
        
        #20;
        reset = 0;
        
        // ����ALU����
        #20;
        exeCtrl_bus = 10'b0000000010; // �趨һ���ǳ˷�����
        alu_src1 = 32'h00000003;
        alu_src2 = 32'h00000004;
        
        #20;
        exeCtrl_bus = 10'b1000000000; // �趨�˷�����
        alu_src1 = 32'h80000001;
        alu_src2 = 32'h00000004;
        
        // �ȴ��˷��������
        
        #100;
        exeCtrl_bus = 10'b1000000000; // �趨�˷�����
        alu_src1 = 32'h00000005;
        alu_src2 = 32'h00000003;
        
        #200;
        
        // ���Խ���
        $stop;
    end
    
endmodule
