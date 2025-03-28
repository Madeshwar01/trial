library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
USE std.textio.ALL;

ENTITY fft_tb IS
END ENTITY fft_tb;

ARCHITECTURE Behavioral OF fft_tb IS

  COMPONENT fft_ip
    PORT (
      aclk : IN STD_LOGIC;
      aresetn : IN STD_LOGIC;
      s_axis_config_tdata : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      s_axis_config_tvalid : IN STD_LOGIC;
      s_axis_config_tready : OUT STD_LOGIC;
      s_axis_data_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      s_axis_data_tvalid : IN STD_LOGIC;
      s_axis_data_tready : OUT STD_LOGIC;
      s_axis_data_tlast : IN STD_LOGIC;
      m_axis_data_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      m_axis_data_tvalid : OUT STD_LOGIC;
      m_axis_data_tready : IN STD_LOGIC;
      m_axis_data_tlast : OUT STD_LOGIC;
      event_frame_started : OUT STD_LOGIC;
      event_tlast_unexpected : OUT STD_LOGIC;
      event_tlast_missing : OUT STD_LOGIC;
      event_status_channel_halt : OUT STD_LOGIC;
      event_data_in_channel_halt : OUT STD_LOGIC;
      event_data_out_channel_halt : OUT STD_LOGIC 
    );
  END COMPONENT;

  SIGNAL clk      : STD_LOGIC := '0';
  SIGNAL reset     : STD_LOGIC := '0';
  SIGNAL config_data  : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
  SIGNAL config_valid : STD_LOGIC := '0';
  SIGNAL data_in    : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
  SIGNAL data_in_valid : STD_LOGIC := '0';
  SIGNAL data_last   : STD_LOGIC := '0';
  SIGNAL data_out   : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL data_out_valid: STD_LOGIC;

  CONSTANT clk_period : TIME := 20 ns; -- 100 MHz Clock

BEGIN

  fft_inst : fft_ip
  PORT MAP (
    aclk => clk,
    aresetn => not(reset),
    s_axis_config_tdata => config_data,
    s_axis_config_tvalid => config_valid,
    s_axis_config_tready => open,
    s_axis_data_tdata => data_in,
    s_axis_data_tvalid => data_in_valid,
    s_axis_data_tready => open,
    s_axis_data_tlast => data_last,
    m_axis_data_tdata => data_out,
    m_axis_data_tvalid => data_out_valid,
    m_axis_data_tready => '1',
    m_axis_data_tlast => open,
    event_frame_started => open,
    event_tlast_unexpected => open,
    event_tlast_missing => open,
    event_status_channel_halt => open,
    event_data_in_channel_halt => open,
    event_data_out_channel_halt => open
  );

  clk_process : PROCESS
  BEGIN
    WHILE NOW < 2 ms LOOP
      clk <= '0';
      WAIT FOR clk_period / 2;
      clk <= '1';
      WAIT FOR clk_period / 2;
    END LOOP;
    WAIT;
  END PROCESS;

  stimulus_process : PROCESS
    FILE input_file : TEXT OPEN READ_MODE IS "signal_input.txt";
    VARIABLE line_buf : LINE;
    VARIABLE re_val, im_val : INTEGER;
  BEGIN
    reset <= '1';
    WAIT FOR 100 ns;
    reset <= '0';

    WAIT UNTIL rising_edge(clk);
    config_valid <= '1';
    config_data <= "0000000000001010";
    WAIT UNTIL rising_edge(clk);
    config_valid <= '0';

    WHILE NOT endfile(input_file) LOOP
      READLINE(input_file, line_buf);
      READ(line_buf, re_val);
      READ(line_buf, im_val);
      WAIT UNTIL rising_edge(clk);
      data_in <= STD_LOGIC_VECTOR(TO_SIGNED(im_val, 16)) & STD_LOGIC_VECTOR(TO_SIGNED(re_val, 16));
      data_in_valid <= '1';
      data_last <= '0';
      WAIT UNTIL rising_edge(clk);
      data_in_valid <= '0';
    END LOOP;

    WAIT UNTIL rising_edge(clk);
    data_last <= '1';
    WAIT UNTIL rising_edge(clk);
    data_last <= '0';

    WAIT FOR 1 us;
    REPORT "Simulation finished";
    WAIT;
  END PROCESS;

  output_process: PROCESS
    FILE output_file : TEXT OPEN WRITE_MODE IS "fft_output.txt";
    VARIABLE output_line : LINE;
    VARIABLE re_out, im_out, magnitude : INTEGER;
  BEGIN
    WAIT UNTIL data_out_valid = '1';
    LOOP
      WAIT UNTIL rising_edge(clk);
      EXIT WHEN data_out_valid = '0';
      re_out := TO_INTEGER(SIGNED(data_out(15 DOWNTO 4))); -- Extract meaningful bits
      im_out := TO_INTEGER(SIGNED(data_out(31 DOWNTO 20)));
      magnitude := ABS(re_out) + ABS(im_out); -- Consider sqrt(re^2 + im^2) for precision
      WRITE(output_line, magnitude);
      WRITELINE(output_file, output_line);
      REPORT "FFT Magnitude: " & INTEGER'IMAGE(magnitude);
    END LOOP;
  END PROCESS;

END ARCHITECTURE Behavioral;
