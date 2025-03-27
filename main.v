`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/27/2025 10:26:59 PM
// Design Name: 
// Module Name: top
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


`timescale 1ns / 1ps

module main(
    input wire aclk,
    input wire aclken,
    input wire aresetn,
    input wire [7:0] s_axis_config_tdata,
    input wire s_axis_config_tvalid,
    output wire s_axis_config_tready,
    input wire [31:0] s_axis_data_tdata,
    input wire s_axis_data_tvalid,
    output wire s_axis_data_tready,
    input wire s_axis_data_tlast,
    output wire [31:0] m_axis_data_tdata,
    output wire [15:0] m_axis_data_tuser,
    output wire m_axis_data_tvalid,
    input wire m_axis_data_tready,
    output wire m_axis_data_tlast,
    output wire [7:0] m_axis_status_tdata,
    output wire m_axis_status_tvalid,
    input wire m_axis_status_tready
);

    // Internal registers
    reg [31:0] data_reg;
    reg [15:0] user_reg;
    reg valid_reg;
    reg last_reg;
    reg [7:0] status_reg;
    reg status_valid_reg;

    // Assign outputs
    assign m_axis_data_tdata = data_reg;
    assign m_axis_data_tuser = user_reg;
    assign m_axis_data_tvalid = valid_reg;
    assign m_axis_data_tlast = last_reg;
    assign m_axis_status_tdata = status_reg;
    assign m_axis_status_tvalid = status_valid_reg;
    assign s_axis_config_tready = 1'b1; // Always ready
    assign s_axis_data_tready = 1'b1; // Always ready

    always @(posedge aclk) begin
        if (!aresetn) begin
            data_reg <= 32'b0;
            user_reg <= 16'b0;
            valid_reg <= 1'b0;
            last_reg <= 1'b0;
            status_reg <= 8'b0;
            status_valid_reg <= 1'b0;
        end else if (aclken) begin
            if (s_axis_data_tvalid) begin
                data_reg <= s_axis_data_tdata; // Store incoming data
                valid_reg <= 1'b1;
                last_reg <= s_axis_data_tlast;
                user_reg <= s_axis_data_tdata[15:0]; // Example processing
                status_reg <= 8'hFF; // Example status update
                status_valid_reg <= 1'b1;
            end
            
            if (m_axis_data_tready) begin
                valid_reg <= 1'b0; // Clear valid flag after data is read
            end
        end
    end
    
endmodule

