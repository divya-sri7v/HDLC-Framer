module Linear_shift(clk,rst,load,input_data,output_data,sop,eop,ready,sop_crc,eop_crc);
input clk,rst,load,sop,eop;
input [7:0] input_data;
output reg ready,sop_crc,eop_crc;
output reg [7:0] output_data;
reg [15:0] CRC_reg;
reg [3:0] count, count_out;
reg eop_pre,sop_crc_pre;
reg [7:0] output_reg_pre;
always@(posedge clk)
begin
if(rst)
begin
CRC_reg<=0;
end
else if(load )
CRC_reg<=16'hffff;
else 
begin
CRC_reg[0]<=CRC_reg[12]^input_data[4]^CRC_reg[8]^input_data[0];
CRC_reg[1]<=CRC_reg[13]^input_data[5]^CRC_reg[9]^input_data[1];
CRC_reg[2]<=CRC_reg[14]^input_data[6]^CRC_reg[10]^input_data[2];
CRC_reg[3]<=CRC_reg[15]^input_data[7]^CRC_reg[11]^input_data[3];
CRC_reg[4]<=CRC_reg[12]^input_data[4];
CRC_reg[5]<=CRC_reg[12]^input_data[4]^CRC_reg[8]^input_data[0]^CRC_reg[13]^input_data[5];
CRC_reg[6] <=CRC_reg[13]^input_data[5]^CRC_reg[9]^input_data[1]^CRC_reg[14]^input_data[6];
CRC_reg[7]<=CRC_reg[14]^input_data[6]^CRC_reg[10]^input_data[2]^CRC_reg[15]^input_data[7];
CRC_reg[8]<=CRC_reg[15]^input_data[7]^CRC_reg[11]^input_data[3]^CRC_reg[0];
CRC_reg[9]<=CRC_reg[12]^input_data[4]^CRC_reg[1];
CRC_reg[10]<=CRC_reg[13]^input_data[5]^CRC_reg[2];
CRC_reg[11]<=CRC_reg[14]^input_data[6]^CRC_reg[3];
CRC_reg[12]<=CRC_reg[12]^input_data[4]^CRC_reg[8]^input_data[0]^CRC_reg[15]^input_data[7]^CRC_reg[4];
CRC_reg[13]<=CRC_reg[13]^input_data[5]^CRC_reg[9]^input_data[1]^CRC_reg[5];
CRC_reg[14]<=CRC_reg[14]^input_data[6]^CRC_reg[10]^input_data[2]^CRC_reg[6];
CRC_reg[15]<=CRC_reg[15]^input_data[7]^CRC_reg[11]^input_data[3]^CRC_reg[7];
end
end
always@(posedge clk)
begin
if(rst)
begin
count<=0;
output_data<=0;
ready<=1'b1;
sop_crc<=0;
eop_crc<=0;
end
else if( count<=4'h8)//{sop,eop}==2'b10 && {sop,eop}==2'b11 ||
begin
output_data<=input_data;
sop_crc<=1'b1;
ready<=1'b0;
count<=count+1;
end
else if ({sop,eop}==2'b01 || count==4'h9)
begin
output_data<=CRC_reg[15:8];
eop_pre<=1'b1;
output_reg_pre<=CRC_reg[7:0];
count<=count+1;
end
else if({eop,eop_pre}==2'b01 && count==4'ha)
begin
output_data<=output_reg_pre;
eop_pre<=1'b0;
sop_crc<=1'b0;
eop_crc<=1'b1;
count<=count;
end
end

endmodule