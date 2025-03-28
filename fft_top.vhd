library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fft_top is
    Port (  
        clk                 : in  std_logic;
        reset               : in  std_logic;
        config_data         : in  std_logic_vector(15 downto 0);
        config_valid        : in  std_logic;
        data_in             : in  std_logic_vector(31 downto 0);
        data_in_valid       : in  std_logic;
        data_last           : in  std_logic;
        data_out            : out std_logic_vector(31 downto 0);
        data_out_valid      : out std_logic
    );
end fft_top;

architecture Behavioral of fft_top is

    -- Component Declaration for FFT IP Core
    component fft_ip is  
        Port (  
            aclk                : in  std_logic;
            aresetn             : in  std_logic;
            s_axis_config_tdata : in  std_logic_vector(15 downto 0);
            s_axis_config_tvalid: in  std_logic;
            s_axis_config_tready: out std_logic;
            s_axis_data_tdata   : in  std_logic_vector(31 downto 0);
            s_axis_data_tvalid  : in  std_logic;
            s_axis_data_tready  : out std_logic;
            s_axis_data_tlast   : in  std_logic;
            m_axis_data_tdata   : out std_logic_vector(31 downto 0);
            m_axis_data_tvalid  : out std_logic;
            m_axis_data_tready  : in  std_logic;
            m_axis_data_tlast   : out std_logic
        );
    end component;

    -- Internal Signals
    signal fft_config_ready  : std_logic;
    signal fft_data_ready    : std_logic;
    signal fft_data_out_ready: std_logic := '1';  -- Always ready to receive output
    signal fft_data_out_last : std_logic;

begin

    -- Instantiate FFT IP Core
    fft_inst : fft_ip
        port map (
            aclk                => clk,
            aresetn             => reset,
            s_axis_config_tdata => config_data,
            s_axis_config_tvalid=> config_valid,
            s_axis_config_tready=> fft_config_ready,
            s_axis_data_tdata   => data_in,
            s_axis_data_tvalid  => data_in_valid,
            s_axis_data_tready  => fft_data_ready,
            s_axis_data_tlast   => data_last,
            m_axis_data_tdata   => data_out,
            m_axis_data_tvalid  => data_out_valid,
            m_axis_data_tready  => fft_data_out_ready,
            m_axis_data_tlast   => fft_data_out_last
        );

end Behavioral;
