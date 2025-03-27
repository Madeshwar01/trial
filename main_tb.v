`timescale 1ns / 1ps


module main_tb();

reg aclk;
 reg aclken ; 
reg aresetn ;
reg [7:0] s_axis_config_tdata ;
 reg s_axis_config_tvalid;
 
  wire s_axis_config_tready;
  
 reg [31 : 0] s_axis_data_tdata;
 reg  s_axis_data_tvalid;
 
 wire s_axis_data_tready;
 
 reg   s_axis_data_tlast;
 
 wire  [31 : 0] m_axis_data_tdata;
  wire [15 : 0] m_axis_data_tuser;
  wire  m_axis_data_tvalid;
  
  reg  m_axis_data_tready;
  
  wire m_axis_data_tlast;
  wire [7 : 0] m_axis_status_tdata;
  wire  m_axis_status_tvalid;
  
  reg    m_axis_status_tready;
  
  wire [15:0]real_part;
  wire [15:0]imag_part;
  
  assign real_part = m_axis_data_tdata[15:0];
  assign imag_part = m_axis_data_tdata[31:16];

// File Handling  
  integer file;
  //integer status;
  //reg [31:0] line;
  


main uut (.aclk(aclk) , .aclken (aclken),. aresetn( aresetn),.s_axis_config_tdata(s_axis_config_tdata),.s_axis_config_tvalid(s_axis_config_tvalid),
.s_axis_config_tready(s_axis_config_tready),. s_axis_data_tdata( s_axis_data_tdata),. s_axis_data_tvalid( s_axis_data_tvalid),.s_axis_data_tready(s_axis_data_tready),
. s_axis_data_tlast( s_axis_data_tlast),. m_axis_data_tdata( m_axis_data_tdata),.m_axis_data_tuser(m_axis_data_tuser),. m_axis_data_tvalid( m_axis_data_tvalid),
. m_axis_data_tready( m_axis_data_tready),.m_axis_data_tlast(m_axis_data_tlast),.m_axis_status_tdata(m_axis_status_tdata),.m_axis_status_tvalid(m_axis_status_tvalid),
.   m_axis_status_tready(m_axis_status_tready));



  

initial begin 

aclk = 1'b0;
aclken = 1'b0;
aresetn = 1'b0;

#10

aclken = 1'b1;
aresetn = 1'b1;

end

always # 6.85 aclk = ~aclk;

initial begin
s_axis_config_tvalid = 1'b1;
s_axis_config_tdata = 8'b0000_0001;

#100

 s_axis_data_tvalid = 1'b1;
// @(negedge aclk);
// s_axis_data_tdata = 32'd256;
//  @(negedge aclk);
// s_axis_data_tdata = 32'd512;
//  @(negedge aclk);
// s_axis_data_tdata = 32'd768;
//  @(negedge aclk);
// s_axis_data_tdata = 32'd1024;
//  @(negedge aclk);
// s_axis_data_tdata = 32'd0;
//  @(negedge aclk);
// s_axis_data_tdata = 32'd0;
//  @(negedge aclk);
// s_axis_data_tdata = 32'd0;
//  @(negedge aclk);
// s_axis_data_tdata = 32'd0;
 
 repeat (1024)
 begin  
         
      file = $fopen("sine_wave_1024.txt", "r");
        while(!$feof(file))
        begin
        // Read one line from the file at each posedge clock
        @(negedge aclk)
        $fscanf(file,"%b\n",s_axis_data_tdata);
        end
 end
 
s_axis_data_tlast = 1'b1;
#10;
m_axis_data_tready = 1'b1;
 end
    
endmodule

