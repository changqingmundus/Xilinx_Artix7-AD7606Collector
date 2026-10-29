----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 28.10.2026 21:30:08
-- Design Name: 
-- Module Name: top_tb_usb - Behavioral
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

entity top_tb_usb is
--  Port ( );
end top_tb_usb;

architecture Behavioral of top_tb_usb is
 signal clk        : std_logic :='0';

 signal ad_busy    : std_logic := '0';
 signal ad_frst    : std_logic := '0';
 signal ad_data    : std_logic_vector(15 downto 0);
 signal ad_convstA : std_logic;
 signal ad_convstB : std_logic;
 signal ad_rst     : std_logic;
 signal ad_cs      : std_logic;
 signal ad_rd      : std_logic;
 signal os         : std_logic_vector(2 downto 0);
 signal ad_rage    : std_logic;
 
 signal uart_rx    : std_logic; 
 signal uart_tx    : std_logic; 

 constant CLK_PERIOD: time:=20 ns;

signal ft232out_clk : std_logic := '0';

signal rxf : std_logic := '1';
signal txe : std_logic := '1';

signal rd   : std_logic;
signal wr   : std_logic;
signal oe   : std_logic;
signal siwu : std_logic;

signal ft232h_data    : std_logic_vector(7 downto 0);
signal ft232h_data_tb : std_logic_vector(7 downto 0) := (others => 'Z');
signal ft232h_drive   : std_logic := '0';

type byte_array_t is array (0 to 3)
    of std_logic_vector(7 downto 0);

constant CMD_BYTES : byte_array_t :=
    (x"BB", x"01", x"00", x"08");
    
begin
clk<=not clk after CLK_PERIOD/2;

uut : entity work.top
port map (
    clk           => clk,

    ad_rst        => ad_rst,
    ad_busy       => ad_busy,
    ad_convstA    => ad_convstA,
    ad_convstB    => ad_convstB,
    ad_frst       => ad_frst,
    ad_data       => ad_data,
    ad_cs         => ad_cs,
    ad_rd         => ad_rd,
    os            => os,
    ad_rage       => ad_rage,

    uart_rx       => uart_rx,
    uart_tx       => uart_tx,

    ft232out_clk  => ft232out_clk,
    rxf           => rxf,
    txe           => txe,
    rd            => rd,
    wr            => wr,
    oe            => oe,
    siwu          => siwu,
    ft232h_data   => ft232h_data
);


-- 模拟 AD7606：转换 BUSY 时序 + 8 通道并行数据
process
    type data_array_t is array (0 to 7) of
        std_logic_vector(15 downto 0);

    constant ADC_TEST_DATA : data_array_t := (
        x"1001",
        x"2002",
        x"3003",
        x"4004",
        x"5005",
        x"6006",
        x"7007",
        x"8008"
    );

    variable ch_index : integer range 0 to 7 := 0;
begin
    ad_data  <= (others => '0');
    ad_busy  <= '0';
    ad_frst  <= '0';

    -- 等待 FPGA 复位释放
    wait until ad_rst = '1';
    wait for 1 us;

    loop
        ------------------------------------------------
        -- 1. 等待 FPGA 发起转换
        ------------------------------------------------
        wait until ad_convstA = '0';

        -- 2. 模拟 ADC 转换开始，BUSY 拉高
        ad_busy <= '1';
        wait for 4 us;

        -- 3. 转换结束，BUSY 拉低
        ad_busy <= '0';

        -- 每次转换完成后，从通道 0 开始
        ch_index := 0;
        ad_data <= ADC_TEST_DATA(ch_index);

        ------------------------------------------------
        -- 4. 等待 FPGA 读取 8 个通道
        ------------------------------------------------
        for i in 0 to 7 loop
            wait until ad_rd = '0';

            ad_data <= ADC_TEST_DATA(i);

            -- 等待 FPGA 结束本次读取
            wait until ad_rd = '1';
        end loop;

        -- 留出一点间隔，再进行下一次转换
        wait for 1 us;
    end loop;
end process;

-- 模拟 FT232H 驱动双向数据总线
ft232h_data <= ft232h_data_tb
               when ft232h_drive = '1'
               else (others => 'Z');

-- FT232H 同步 FIFO 时钟，60 MHz
process
begin
    ft232out_clk <= '0';
    wait for 8.333 ns;
    ft232out_clk <= '1';
    wait for 8.334 ns;
end process;

-- 模拟 FT232H 向 FPGA 发送命令，
-- 随后允许 FPGA 向 FT232H 写入数据
process
begin
    rxf            <= '1';
    txe            <= '1';
    ft232h_drive   <= '0';
    ft232h_data_tb <= (others => 'Z');

    wait for 20 us;

    ------------------------------------------------
    -- 第一阶段：模拟 FT232H 接收 FIFO 中有 4 字节
    ------------------------------------------------
    rxf <= '0';

    -- 等待 FPGA 拉低 OE#，再拉低 RD#
    wait until oe = '0';
    wait until rd = '0';

    ft232h_drive <= '1';

    -- 在下降沿更新数据，供 FPGA 下一上升沿采样
    for i in 0 to 3 loop
        wait until falling_edge(ft232out_clk);
        ft232h_data_tb <= CMD_BYTES(i);
    end loop;

    -- 等待 FPGA 结束读取
    wait until rd = '1';

    ft232h_drive   <= '0';
    ft232h_data_tb <= (others => 'Z');
    rxf            <= '1';

    ------------------------------------------------
    -- 第二阶段：模拟 FT232H 允许 FPGA 写入数据
    ------------------------------------------------
    wait for 100 ns;

    txe <= '0';  -- TXE# 拉低：允许 FPGA 写入

    -- 等待 FPGA 开始写入
    wait until wr = '0';

    -- 模拟 FT232H 在一段时间内持续允许写入
    wait for 5 us;

    -- 模拟 FT232H FIFO 暂时不可写
    txe <= '1';

    -- 等待 FPGA 结束写入
    wait until wr = '1';

    wait;
end process;

end Behavioral;
