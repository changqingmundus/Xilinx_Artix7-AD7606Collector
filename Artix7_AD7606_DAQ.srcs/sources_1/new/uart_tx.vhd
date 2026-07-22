----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 22.07.2026 22:40:49
-- Design Name: 
-- Module Name: uart_tx - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity uart_tx is
--  Port ( );
port(

    clk : in std_logic;

    data_in : in std_logic_vector(15 downto 0);

    data_valid : in std_logic;

    rx:in std_logic;
    tx : out std_logic

);
end uart_tx;

architecture Behavioral of uart_tx is

-- 50MHz / 2Mbps = 25
constant BAUD_CNT_MAX : integer := 24;


type state_type is
(
    IDLE,
    SEND
);


signal state : state_type := IDLE;


signal baud_cnt : integer range 0 to 24 := 0;


signal bit_cnt : integer range 0 to 9 := 0;


signal tx_reg : std_logic := '1';


signal data_buf : std_logic_vector(15 downto 0);


signal byte_sel : std_logic := '0';



begin


tx <= tx_reg;



process(clk)

begin

if rising_edge(clk) then


case state is


------------------------------------------------
-- 空閒
------------------------------------------------
when IDLE =>


    tx_reg <= '1';

    baud_cnt <= 0;

    bit_cnt <= 0;


    if data_valid='1' then

        data_buf <= data_in;

        byte_sel <= '0';

        state <= SEND;

    end if;



------------------------------------------------
-- 發送
------------------------------------------------
when SEND =>


    if baud_cnt = BAUD_CNT_MAX then


        baud_cnt <= 0;


        case bit_cnt is


        -- start bit
        when 0 =>

            tx_reg <= '0';



        -- data bit 0~7
        when 1 =>

            if byte_sel='0' then

                tx_reg <= data_buf(0);

            else

                tx_reg <= data_buf(8);

            end if;



        when 2 =>

            if byte_sel='0' then

                tx_reg <= data_buf(1);

            else

                tx_reg <= data_buf(9);

            end if;



        when 3 =>

            if byte_sel='0' then

                tx_reg <= data_buf(2);

            else

                tx_reg <= data_buf(10);

            end if;



        when 4 =>

            if byte_sel='0' then

                tx_reg <= data_buf(3);

            else

                tx_reg <= data_buf(11);

            end if;



        when 5 =>

            if byte_sel='0' then

                tx_reg <= data_buf(4);

            else

                tx_reg <= data_buf(12);

            end if;



        when 6 =>

            if byte_sel='0' then

                tx_reg <= data_buf(5);

            else

                tx_reg <= data_buf(13);

            end if;



        when 7 =>

            if byte_sel='0' then

                tx_reg <= data_buf(6);

            else

                tx_reg <= data_buf(14);

            end if;



        when 8 =>

            if byte_sel='0' then

                tx_reg <= data_buf(7);

            else

                tx_reg <= data_buf(15);

            end if;



        -- stop bit
        when 9 =>

            tx_reg <= '1';


        end case;



        if bit_cnt = 9 then


            bit_cnt <= 0;


            if byte_sel='0' then

                byte_sel <= '1';

            else

                state <= IDLE;

            end if;


        else

            bit_cnt <= bit_cnt + 1;

        end if;



    else

        baud_cnt <= baud_cnt + 1;

    end if;


end case;


end if;


end process;

end Behavioral;
