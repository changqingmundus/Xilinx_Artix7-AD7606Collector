library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity uart_tx is
port(
    clk : in std_logic;
    tx  : out std_logic
);
end uart_tx;


architecture Behavioral of uart_tx is


constant BAUD_CNT_MAX : integer := 5207; -- 9600bps


signal baud_cnt : integer range 0 to BAUD_CNT_MAX := 0;

signal bit_cnt : integer range 0 to 9 := 0;


signal tx_reg : std_logic := '1';


signal send_cnt : integer range 0 to 50000000 := 0;


signal busy : std_logic := '0';


signal data_buf : std_logic_vector(7 downto 0):=x"55";


begin


tx <= tx_reg;


process(clk)

begin

if rising_edge(clk) then


    if busy='0' then


        tx_reg <= '1';


        if send_cnt=50000000 then

            send_cnt<=0;

            busy<='1';

            bit_cnt<=0;

        else

            send_cnt<=send_cnt+1;

        end if;



    else


        if baud_cnt=BAUD_CNT_MAX then

            baud_cnt<=0;


            case bit_cnt is


            when 0 =>
                tx_reg<='0';


            when 1 =>
                tx_reg<=data_buf(0);


            when 2 =>
                tx_reg<=data_buf(1);


            when 3 =>
                tx_reg<=data_buf(2);


            when 4 =>
                tx_reg<=data_buf(3);


            when 5 =>
                tx_reg<=data_buf(4);


            when 6 =>
                tx_reg<=data_buf(5);


            when 7 =>
                tx_reg<=data_buf(6);


            when 8 =>
                tx_reg<=data_buf(7);


            when others =>
                tx_reg<='1';

            end case;



            if bit_cnt=9 then

                busy<='0';

            else

                bit_cnt<=bit_cnt+1;

            end if;



        else

            baud_cnt<=baud_cnt+1;

        end if;


    end if;


end if;


end process;


end Behavioral;