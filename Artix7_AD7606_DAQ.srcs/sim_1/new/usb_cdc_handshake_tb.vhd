----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 29.10.2026 22:16:39
-- Design Name: 
-- Module Name: usb_cdc_handshake_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity usb_cdc_handshake_tb is
--  Port ( );
end usb_cdc_handshake_tb;

architecture Behavioral of usb_cdc_handshake_tb is
    constant SRC_PERIOD : time := 20 ns; -- 50 MHz
    constant DST_PERIOD : time := 16.667 ns; -- 约 60 MHz
    constant TEST_COUNT : integer := 16;

    signal src_clk   : std_logic := '0';
    signal dst_clk   : std_logic := '0';
    signal src_rst   : std_logic := '0';
    signal dst_rst   : std_logic := '0';

    signal src_valid : std_logic := '0';
    signal src_data  : std_logic_vector(7 downto 0) := (others => '0');
    signal src_ready : std_logic;

    signal dst_ready : std_logic := '1';
    signal dst_valid : std_logic;
    signal dst_data  : std_logic_vector(7 downto 0);

    signal received_count : integer := 0;
    signal test_done      : std_logic := '0';

    type byte_array is array (0 to TEST_COUNT-1)
        of std_logic_vector(7 downto 0);

    constant TEST_DATA : byte_array := (
        x"2C", x"10", x"2C", x"16",
        x"2B", x"BF", x"2C", x"1C",
        x"2C", x"50", x"2B", x"B1",
        x"2B", x"F6", x"00", x"FF"
    );
    
    function byte_to_hex(
    b : std_logic_vector(7 downto 0)
) return string is
    constant HEX_CHARS : string(1 to 16) :=
        "0123456789ABCDEF";
    variable result : string(1 to 2);
    variable hi : integer;
    variable lo : integer;
begin
    hi := to_integer(unsigned(b(7 downto 4)));
    lo := to_integer(unsigned(b(3 downto 0)));

    result(1) := HEX_CHARS(hi + 1);
    result(2) := HEX_CHARS(lo + 1);

    return result;
end function;

begin
 -- 50 MHz source clock
    src_clk <= not src_clk after SRC_PERIOD / 2;

    -- 60 MHz destination clock
    dst_clk <= not dst_clk after DST_PERIOD / 2;

    -- DUT
    uut : entity work.usb_cdc_handshake
        port map (
            src_clk   => src_clk,
            src_rst   => src_rst,
            src_valid => src_valid,
            src_data  => src_data,
            src_ready => src_ready,

            dst_clk   => dst_clk,
            dst_rst   => dst_rst,
            dst_ready => dst_ready,
            dst_valid => dst_valid,
            dst_data  => dst_data
        );

    -- Reset: active low
    reset_process : process
    begin
        src_rst <= '0';
        dst_rst <= '0';

        wait for 200 ns;

        wait until rising_edge(src_clk);
        src_rst <= '1';
        dst_rst <= '1';

        wait;
    end process;


    -- Source: send 16 bytes, one at a time
    
source_process : process
begin
    src_valid <= '0';
    src_data  <= (others => '0');

    wait until src_rst = '1';

    for i in 0 to TEST_COUNT-1 loop

        -- Wait until source is ready.
        -- Use a loop so an already-high src_ready
        -- does not cause the process to wait forever.
        while src_ready /= '1' loop
            wait until rising_edge(src_clk);
        end loop;

        -- Prepare the byte before the next rising edge.
        wait until falling_edge(src_clk);
        src_data  <= TEST_DATA(i);
        src_valid <= '1';

        -- DUT captures the byte on a rising edge.
        wait until rising_edge(src_clk);
        wait for 1 ns;
        src_valid <= '0';

        report "Submitted byte " &
               integer'image(i) &
               " = " & byte_to_hex(TEST_DATA(i))
               severity note;

    end loop;

    report "All source bytes submitted." severity note;
    wait;
end process;



    -- Destination: verify every accepted byte
    monitor_process : process(dst_clk)
        variable n : integer := 0;
    begin
        if rising_edge(dst_clk) then

            if dst_rst = '0' then
                n := 0;
                received_count <= 0;

            elsif dst_valid = '1' and dst_ready = '1' then
            
             report "DEBUG: n=" & integer'image(n) &
       ", dst_data=" & byte_to_hex(dst_data) &
       ", dst_valid=" & std_logic'image(dst_valid) &
       ", dst_ready=" & std_logic'image(dst_ready)
       severity note;
       
                assert n < TEST_COUNT
                    report "ERROR: Extra byte received!"
                    severity failure;

                assert dst_data = TEST_DATA(n)
                    report "ERROR: Data mismatch at index " &
                           integer'image(n) &
                           ", expected " & byte_to_hex(TEST_DATA(n)) &
                           ", got " & byte_to_hex(dst_data)
                    severity error;

                report "Received byte " &
                       integer'image(n) &
                       " = " & byte_to_hex(dst_data)
                       severity note;

                n := n + 1;
                received_count <= n;

                if n = TEST_COUNT then
                    test_done <= '1';
                    report "PASS: All 16 bytes received in order."
                        severity note;
                end if;

            end if;
        end if;
    end process;


    -- Test destination backpressure
    -- Temporarily stop accepting data, then resume.
    ready_process : process
    begin
        dst_ready <= '1';

        wait until dst_rst = '1';
        wait for 800 ns;

        dst_ready <= '0';
        report "Destination paused." severity note;

        wait for 500 ns;

        dst_ready <= '1';
        report "Destination resumed." severity note;

        wait;
    end process;


    -- Timeout guard
    timeout_process : process
    begin
        wait for 20 us;

        assert test_done = '1'
            report "FAIL: Timeout; not all bytes were received."
            severity failure;

        report "TEST COMPLETE." severity note;
        wait;
    end process;

end Behavioral;
