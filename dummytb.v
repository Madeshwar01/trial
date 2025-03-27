`timescale 1ns / 1ps

module main_tb();

    reg aclk;
    reg aclken;
    reg aresetn;
    reg [7:0] s_axis_config_tdata;
    reg s_axis_config_tvalid;
    wire s_axis_config_tready;
    
    reg [31:0] s_axis_data_tdata;
    reg s_axis_data_tvalid;
    wire s_axis_data_tready;
    reg s_axis_data_tlast;

    wire [31:0] m_axis_data_tdata;
    wire [15:0] m_axis_data_tuser;
    wire m_axis_data_tvalid;
    reg m_axis_data_tready;
    wire m_axis_data_tlast;
    wire [7:0] m_axis_status_tdata;
    wire m_axis_status_tvalid;
    reg m_axis_status_tready;

    wire [15:0] real_part;
    wire [15:0] imag_part;

    assign real_part = m_axis_data_tdata[15:0];
    assign imag_part = m_axis_data_tdata[31:16];

    // File Handling
    integer file;
    integer status;

    main uut (
        .aclk(aclk), 
        .aclken(aclken), 
        .aresetn(aresetn),
        .s_axis_config_tdata(s_axis_config_tdata),
        .s_axis_config_tvalid(s_axis_config_tvalid),
        .s_axis_config_tready(s_axis_config_tready),
        .s_axis_data_tdata(s_axis_data_tdata),
        .s_axis_data_tvalid(s_axis_data_tvalid),
        .s_axis_data_tready(s_axis_data_tready),
        .s_axis_data_tlast(s_axis_data_tlast),
        .m_axis_data_tdata(m_axis_data_tdata),
        .m_axis_data_tuser(m_axis_data_tuser),
        .m_axis_data_tvalid(m_axis_data_tvalid),
        .m_axis_data_tready(m_axis_data_tready),
        .m_axis_data_tlast(m_axis_data_tlast),
        .m_axis_status_tdata(m_axis_status_tdata),
        .m_axis_status_tvalid(m_axis_status_tvalid),
        .m_axis_status_tready(m_axis_status_tready)
    );

    // Clock Generation
    always #6.85 aclk = ~aclk;

    initial begin
        aclk = 1'b0;
        aclken = 1'b0;
        aresetn = 1'b0;
        s_axis_config_tvalid = 1'b0;
        s_axis_data_tvalid = 1'b0;
        s_axis_data_tlast = 1'b0;
        m_axis_data_tready = 1'b0;
        
        #10
        aclken = 1'b1;
        aresetn = 1'b1;

        // Configuration Data
        s_axis_config_tvalid = 1'b1;
        s_axis_config_tdata = 8'b0000_0001;
        #10 s_axis_config_tvalid = 1'b0;
        
        #100

        // Open the input file
        file = $fopen("C:/Users/mades/Downloads/fft_ip/signal.txt", "r");
        if (file == 0) begin
            $display("Error: Unable to open file.");
            $finish;
        end
        
        // Read data from file and send to FFT
        s_axis_data_tvalid = 1'b1;
        while (!$feof(file)) begin
            @(negedge aclk);
            status = $fscanf(file, "%d\n", s_axis_data_tdata);
            
            if (status != 1) begin
                $display("Error: File read issue.");
                $finish;
            end
        end

        // End of transmission
        s_axis_data_tlast = 1'b1;
        #10;
        s_axis_data_tvalid = 1'b0;
        m_axis_data_tready = 1'b1;

        // Close the file
        $fclose(file);
    end
    
endmodule
