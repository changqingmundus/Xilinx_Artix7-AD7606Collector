----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 22.07.2026 22:39:51
-- Design Name: 
-- Module Name: top - Behavioral
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top is
--  Port ( );
 port(
   --FPGA clock
   clk            :in std_logic;
   led            :out std_logic;
   
   -- AD7606 interface
   ad_busy        :in std_logic;
   ad_frst        :in std_logic;
   ad_data        :in std_logic_vector(15 downto 0);
  
   ad_convstA     :out std_logic;
   ad_convstB     :out std_logic;
   ad_rst         :out std_logic;
   ad_cs          :out std_logic;
   ad_rd          :out std_logic;
   os             :out std_logic_vector(2 downto 0);
   ad_rage        :out std_logic;
   
   --UART interface
   uart_rx        :in std_logic;
   uart_tx        :out std_logic;
   
   --FT232H interface
   ft232out_clk   :in std_logic;
   rxf            :in std_logic;
   txe            :in std_logic;
       
   rd             :out std_logic;
   wr             :out std_logic;
   oe             :out std_logic;
   siwu           :out std_logic;
      
   ft232h_data    :inout std_logic_vector(7 downto 0));
end top;



architecture Behavioral of top is
 signal rst       :std_logic;

 --uart_rx define
 signal rx_data   :std_logic_vector(7 downto 0);
 signal rx_parity :std_logic;
 signal rx_done   :std_logic;
 
 --uart_rx_cmd
 signal cmd_valid :std_logic;
 signal cmd_start :std_logic_vector(7 downto 0);
 signal cmd_count :std_logic_vector(7 downto 0);
 
 --ad7606 define
 signal ad_ch1    :std_logic_vector(15 downto 0);
 signal ad_ch2    :std_logic_vector(15 downto 0);
 signal ad_ch3    :std_logic_vector(15 downto 0);
 signal ad_ch4    :std_logic_vector(15 downto 0);
 signal ad_ch5    :std_logic_vector(15 downto 0);
 signal ad_ch6    :std_logic_vector(15 downto 0);
 signal ad_ch7    :std_logic_vector(15 downto 0);
 signal ad_ch8    :std_logic_vector(15 downto 0);
 signal ad_valid  :std_logic;
 
 --fifo define
 signal fifo_srst :std_logic;
 signal ch_cnt    :integer range 0 to 7;
 signal fifo_rd_en:std_logic;
 signal fifo_din  :std_logic_vector(15 downto 0);
 signal fifo_wr_en:std_logic;
 signal fifo_empty:std_logic;
 signal fifo_dout :std_logic_vector(7 downto 0);
 signal fifo_full :std_logic;
 signal fifo_rd   :std_logic; 
 
 type fifo_tx_state_t is(FIFO_IDLE,
                         FIFO_READ_WAIT,
                         FIFO_WAIT_DOUT,
                         FIFO_LOAD_DATA,
                         
                         -- UART 状态
                         FIFO_WAIT_BUSY_HIGH,
                         FIFO_WAIT_BUSY_LOW,
                         FIFO_GAP,
                         
                         -- USB 状态
                         FIFO_USB_WAIT_ACCEPT,
                         FIFO_USB_WAIT_DONE);
 signal fifo_tx_state:fifo_tx_state_t:=FIFO_IDLE;
 
 type wr_state_t is (WR_IDLE,
                     WR_FLUSH, 
                     WR_WRITE);
 signal wr_state  : wr_state_t := WR_IDLE;
 signal flush_cnt : integer range 0 to 15 := 0;

 --signal processor define
 signal data_A      : std_logic_vector(15 downto 0);
 signal data_B      : std_logic_vector(15 downto 0);
 signal adc_valid   : std_logic;
 signal start       : std_logic;
 signal sample_cnt_set : std_logic_vector(15 downto 0);
 signal A_max_value : std_logic_vector(15 downto 0);
 signal A_min_value : std_logic_vector(15 downto 0);
 signal A_amplitude : std_logic_vector(15 downto 0);
 signal A_offset    : std_logic_vector(15 downto 0);
 signal B_max_value : std_logic_vector(15 downto 0);
 signal B_min_value : std_logic_vector(15 downto 0);
 signal B_amplitude : std_logic_vector(15 downto 0);
 signal B_offset    : std_logic_vector(15 downto 0);
 signal calcul_done : std_logic;
 
 --uart_tx define
 signal uart_data_en  : std_logic;
 
 signal tx_active     : std_logic;
 signal tx_count      : std_logic_vector(7 downto 0);
 signal read_wait     : integer range 0 to 2 := 0;
 signal byte_sel      : std_logic := '0';
 signal tx_data_reg   : std_logic_vector(7 downto 0);
 signal data_valid_seg: std_logic;
 signal tx_busy       : std_logic;
 
 constant GAP_CYCLES  : integer := 50;
 signal gap_cnt       : integer range 0 to GAP_CYCLES := 0;
 
 --FT232H define
 signal ft232h_data_en: std_logic;
 
 signal ft232h_rd_s_done: std_logic;
 signal ft232h_wr_s_done: std_logic;
 signal data_rd_en    : std_logic;
 signal data_wr_en    : std_logic;
 signal ft232h_data_in: std_logic_vector(7 downto 0);
 signal ft232h_data_out:std_logic_vector(7 downto 0);
 
 signal rd_length     : unsigned(15 downto 0);
 signal wr_length     : unsigned(15 downto 0);
 
 --FT232H_cmd
 signal ft232h_cmd_valid:std_logic;
 signal ft232h_cmd_start:std_logic_vector(7 downto 0);
 signal ft232h_cmd_count:std_logic_vector(7 downto 0);
 
 signal usb_stream_active:std_logic;
 
 --usb_cdc define
 signal usb_src_valid : std_logic := '0';
 signal usb_src_ready : std_logic;
 signal usb_src_data  : std_logic_vector(7 downto 0) := (others => '0');

 signal usb_dst_valid : std_logic;
 signal usb_dst_ready : std_logic := '0';
 signal usb_dst_data  : std_logic_vector(7 downto 0);
 
 
 
 type afifo_wr_state_type is (
    AFIFO_WR_IDLE,
    AFIFO_WR_WAIT_DOUT,
    AFIFO_WR_WRITE
);

signal afifo_wr_state : afifo_wr_state_type := AFIFO_WR_IDLE;

signal afifo_wr_en : std_logic := '0';
signal afifo_din   : std_logic_vector(7 downto 0) := (others => '0');
signal afifo_full  : std_logic;

 --============================================================
-- 异步FIFO读侧 -> FT232H USB 流发送状态机 (60 MHz 域)
--============================================================

type afifo_usb_fsm_t is (
    AFIFO_USB_IDLE,
    AFIFO_USB_READ_WAIT,
    AFIFO_USB_WAIT_DOUT,
    AFIFO_USB_WRITE,
    AFIFO_USB_WAIT_DONE
);
signal afifo_usb_fsm : afifo_usb_fsm_t;

-- 异步FIFO读侧接口 (60 MHz 域)
signal afifo_rd_en   : std_logic := '0';
signal afifo_empty   : std_logic;
signal afifo_dout    : std_logic_vector(7 downto 0);

-- 启动 / 状态
signal usb_stream_start : std_logic := '0';   -- 单拍脉冲，启动流
signal usb_stream_stop  : std_logic := '0';   -- 单拍脉冲，停止流
 
 --led test
 signal cnt         : integer range 0 to 50000000:=0;
 signal led_reg     : std_logic := '0';

 --tx mode
 signal tx_usb_mode : std_logic := '0';
 
component ila_0
 port(clk:in std_logic;
   probe0:in std_logic_vector(7 downto 0);
   probe1:in std_logic_vector(7 downto 0);
   probe2:in std_logic_vector(0 downto 0);
   probe3:in std_logic_vector(0 downto 0);
   probe4:in std_logic_vector(0 downto 0));
end component;

signal oe_reg    : std_logic := '1';
signal wr_reg    : std_logic := '1';
signal rd_reg    : std_logic := '1';
signal probe2_vec:std_logic_vector(0 downto 0);
signal probe3_vec:std_logic_vector(0 downto 0);
signal probe4_vec:std_logic_vector(0 downto 0);

begin
 --fifo_srst <= not rst;
 fifo_srst <= '1' when (rst = '0' or wr_state = WR_FLUSH) else '0';
 
 os<="000";
 ad_rage<='0';
 
 siwu<='1';
 oe<=oe_reg;
 wr<=wr_reg;
 rd<=rd_reg;
 data_rd_en<='1';
 
 rd_length<=x"0005";
 wr_length<=x"0010";
 
 --poweron reset
 process(clk)
  begin 
   if rising_edge(clk) then
    --if(cnt<100)then
    if(cnt<50000000)then
     rst<='0';
     cnt<=cnt+1;
    else
     rst<='1';
    end if;
   end if;
  end process;

 
 --ad_data to fifo
 process(clk)
  begin
   if rising_edge (clk)then
    if(rst = '0')then
     fifo_wr_en<='0';
     ch_cnt<=0;
     fifo_din<=(others=>'0');
     wr_state<=WR_IDLE;
     flush_cnt<=0;
    else
     fifo_wr_en<='0';
     case wr_state is
      when WR_IDLE =>
       if(ad_valid = '1')then
        flush_cnt<=0;
        wr_state<=WR_FLUSH;
       end if;
      when WR_FLUSH  =>
       if(flush_cnt = 8)then
        ch_cnt<=0;
        flush_cnt<=0;
        wr_state<=WR_WRITE;
       else
        flush_cnt<=flush_cnt+1;
       end if;
      when WR_WRITE =>
       if(fifo_full = '0')then
        fifo_wr_en<='1';
       case ch_cnt is
        when 0 => fifo_din <= ad_ch1;
        when 1 => fifo_din <= ad_ch2;
        when 2 => fifo_din <= ad_ch3;
        when 3 => fifo_din <= ad_ch4;
        when 4 => fifo_din <= ad_ch5;
        when 5 => fifo_din <= ad_ch6;
        when 6 => fifo_din <= ad_ch7;
        when 7 => fifo_din <= ad_ch8;
        when others => fifo_din <= (others=>'0');
       end case;
        if(ch_cnt = 7)then
         ch_cnt<=0;
         wr_state<=WR_IDLE;
        else
         ch_cnt<=ch_cnt+1;
        end if;
       end if;
      when others => wr_state <= WR_IDLE;
     end case;
   end if;
  end if;
 end process;
     
 --fifo to uart_tx / ft232h
 process(clk)
  begin
    if rising_edge(clk) then
     --fifo_rd_en<='0';
     data_valid_seg<='0';
     if rst = '0' then         --reset
      tx_active<= '0';
      gap_cnt<=0;
      read_wait<= 0;
      tx_data_reg<=(others => '0');
      tx_count<=(others => '0');
      
      data_wr_en<='0';
      --ft232h_data_in<=(others => '0');
      tx_usb_mode<='0';
      --usb_stream_active<='0';
      fifo_tx_state<=FIFO_IDLE;
     else
      case fifo_tx_state is
      
       when FIFO_IDLE =>
        tx_active<='0';
        if(cmd_valid = '1' and uart_data_en = '1')then
         tx_usb_mode<='0';
         tx_active<='1';
         tx_count<=std_logic_vector(to_unsigned(to_integer(unsigned(cmd_count))*2,tx_count'length));
         fifo_tx_state<=FIFO_READ_WAIT;
        --elsif(ft232h_cmd_valid = '1' and ft232h_data_en = '1')then 
        -- tx_usb_mode<='1';
         --tx_active<='0';
        -- usb_stream_active<='1';
         --tx_count<=std_logic_vector(to_unsigned(to_integer(unsigned(ft232h_cmd_count))*2,tx_count'length));
         --fifo_tx_state<=FIFO_READ_WAIT;
        end if;
        
       when FIFO_READ_WAIT =>
        if(tx_usb_mode = '1')then 
         if(usb_stream_active = '0')then
          fifo_tx_state<=FIFO_IDLE;
         elsif(fifo_empty = '0')then
          --fifo_rd_en<='1';
          fifo_tx_state<=FIFO_WAIT_DOUT;
         end if;
        else
         if(unsigned(tx_count) = 0)then
          tx_active<='1';
          fifo_tx_state<=FIFO_IDLE;
         elsif(fifo_empty = '0' and tx_busy = '0')then
          --fifo_rd_en<='1';
          fifo_tx_state<=FIFO_WAIT_DOUT;
         end if;
        end if;
        
       -- 等待 FIFO 输出数据
       when FIFO_WAIT_DOUT =>
        fifo_tx_state<=FIFO_LOAD_DATA;
        
       when FIFO_LOAD_DATA =>
        if(tx_usb_mode = '0')then
         tx_data_reg<=fifo_dout;
         data_valid_seg<='1';
         tx_count<=std_logic_vector(unsigned(tx_count)-1);
         fifo_tx_state<=FIFO_WAIT_BUSY_HIGH;
        else
         if(usb_src_ready = '1')then
          usb_src_data<=fifo_dout;
          usb_src_valid<='1';
          --data_wr_en<='1';
          fifo_tx_state<=FIFO_USB_WAIT_ACCEPT;
         end if;
        end if;
        
       when FIFO_WAIT_BUSY_HIGH =>
        if(tx_busy = '1')then
         fifo_tx_state<=FIFO_WAIT_BUSY_LOW;
        end if;
        
       when FIFO_WAIT_BUSY_LOW =>
        if(tx_busy = '0')then
         gap_cnt<=0;
         fifo_tx_state<=FIFO_GAP;
        end if;
        
       when FIFO_GAP =>
        if(gap_cnt = GAP_CYCLES)then
         fifo_tx_state<=FIFO_READ_WAIT;
        else
         gap_cnt<=gap_cnt+1;
        end if;
        
       when FIFO_USB_WAIT_ACCEPT =>
        if(usb_src_ready = '0')then
         usb_src_valid<='0';
         fifo_tx_state<=FIFO_USB_WAIT_DONE;
        end if;
        
       when FIFO_USB_WAIT_DONE =>
        if(usb_src_ready = '1')then
         tx_count<=std_logic_vector(unsigned(tx_count) - 1);
         fifo_tx_state<=FIFO_READ_WAIT;
        end if;
       when others =>
        fifo_tx_state<=FIFO_IDLE;
     end case;
    end if;
   end if;
  end process;
  
  
 process(clk)
begin
    if rising_edge(clk) then

        fifo_rd_en <= '0';
        afifo_wr_en <= '0';

        if rst = '0' then
            afifo_wr_state <= AFIFO_WR_IDLE;
            afifo_din <= (others => '0');

        else
            case afifo_wr_state is

                when AFIFO_WR_IDLE =>
                    -- 原始 FIFO 有数据，且异步 FIFO 未满
                    if fifo_empty = '0' and afifo_full = '0' then
                        fifo_rd_en <= '1';
                        afifo_wr_state <= AFIFO_WR_WAIT_DOUT;
                    end if;

                when AFIFO_WR_WAIT_DOUT =>
                    -- 等待原始 FIFO Standard Read 输出
                    afifo_wr_state <= AFIFO_WR_WRITE;

                when AFIFO_WR_WRITE =>
                    -- 这里才是真正的数据来源
                    if afifo_full = '0' then
                        afifo_din <= fifo_dout;
                        afifo_wr_en <= '1';
                        afifo_wr_state <= AFIFO_WR_IDLE;
                    end if;

                when others =>
                    afifo_wr_state <= AFIFO_WR_IDLE;

            end case;
        end if;
    end if;
end process;
  
 process(ft232out_clk)
begin
    if rising_edge(ft232out_clk) then

        afifo_rd_en <= '0';

        if rst = '0' then
            afifo_usb_fsm <= AFIFO_USB_IDLE;
            usb_stream_active <= '0';
            ft232h_data_in <= (others => '0');
            usb_dst_valid <= '0';
        else

            if usb_stream_stop = '1' then
                usb_stream_active <= '0';
            end if;

            case afifo_usb_fsm is

                when AFIFO_USB_IDLE =>
                  usb_dst_valid <= '0';
                    if ft232h_cmd_valid = '1' then
                        usb_stream_active <= '1';
                        afifo_usb_fsm <= AFIFO_USB_READ_WAIT;
                    end if;

                when AFIFO_USB_READ_WAIT =>
                  usb_dst_valid <= '0';
                    if usb_stream_active = '0' then
                        afifo_usb_fsm <= AFIFO_USB_IDLE;

                    elsif afifo_empty = '0' then
                        afifo_rd_en <= '1';
                        afifo_usb_fsm <= AFIFO_USB_WAIT_DOUT;
                    end if;

                when AFIFO_USB_WAIT_DOUT =>
                    -- 等待 FIFO Standard Read 输出
                    afifo_usb_fsm <= AFIFO_USB_WRITE;

                when AFIFO_USB_WRITE =>
                    -- 将 FIFO 数据交给 FT232H 控制模块
                     usb_dst_valid <= '1';
                    ft232h_data_in <= afifo_dout;
                    afifo_usb_fsm <= AFIFO_USB_WAIT_DONE;

                when AFIFO_USB_WAIT_DONE =>
                    -- 等待 FT232H 完成当前字节写入
                    if usb_dst_ready = '1' then
                      usb_dst_valid <= '0';
                        afifo_usb_fsm <= AFIFO_USB_READ_WAIT;
                    end if;

                when others =>
                  usb_dst_valid <= '0';
                    afifo_usb_fsm <= AFIFO_USB_IDLE;

            end case;
        end if;
    end if;
end process;
   
        
 --uart_rx port
 u_uart_rx:entity work.uart_rx
  generic map(
  clk_freq=>50,
  baud_rate=>2000000,
  parity_on=>0,
  data_width=>8)
  port map(
   clk=>clk,
   rst=>rst,
   rx=>uart_rx,
   rx_data=>rx_data,
   rx_parity=>rx_parity,
   rx_done=>rx_done);
  
 --uart_rx_cmd port
 uart_cmd_parser:entity work.uart_cmd_parser
 port map(
  clk       =>clk,
  rst       =>rst,
  rx_data   =>rx_data,
  rx_valid  =>rx_done,
  cmd_valid =>cmd_valid,
  cmd_start =>cmd_start,
  cmd_count =>cmd_count,
  uart_data_en=>uart_data_en,
  ft232h_data_en=>ft232h_data_en);
 
 --ad7606 port 
 u_ad7606_ctrl:entity work.ad7606_ctrl
 port map(
  clk       =>clk,
  rst       =>rst,
  ad_rst    =>ad_rst,
  busy      =>ad_busy,
  frst      =>ad_frst,
  data_in   =>ad_data,
  convstA   =>ad_convstA,
  convstB   =>ad_convstB,
  os        =>os,
  rd        =>ad_rd,
  rage      =>ad_rage,
  ad_cs     =>ad_cs,
  ad_ch1    =>ad_ch1,
  ad_ch2    =>ad_ch2,
  ad_ch3    =>ad_ch3,
  ad_ch4    =>ad_ch4,
  ad_ch5    =>ad_ch5,
  ad_ch6    =>ad_ch6,
  ad_ch7    =>ad_ch7,
  ad_ch8    =>ad_ch8,
  data_valid=>ad_valid);
  
 u_fifo_generator_0_inst:entity work.fifo_generator_0
 port map(
  clk         =>clk,
  srst        =>fifo_srst,
  din         =>fifo_din,
  wr_en       =>fifo_wr_en,
  rd_en       =>fifo_rd_en,
  dout        =>fifo_dout,
  full        =>fifo_full,
  empty       =>fifo_empty,
  almost_full =>open,
  almost_empty=>open);
  
 u_signal_processor:entity work.signal_processor
  port map(
   clk        =>clk,
   rst        =>rst,
   data_A     =>data_A,
   data_B     =>data_B,
   adc_valid  =>adc_valid,
   start      =>start,
   sample_cnt_set=>sample_cnt_set,
   A_max_value=>A_max_value,
   A_min_value=>A_min_value,
   A_amplitude=>A_amplitude,
   A_offset   =>A_offset,
   B_max_value=>B_max_value,
   B_min_value=>B_min_value,
   B_amplitude=>B_amplitude,
   B_offset   =>B_offset,
   calcul_done=>calcul_done);

 u_uart_tx:entity work.uart_tx
  generic map(
  clk_freq   =>50,
  baud_rate  =>2000000,
  parity_on  =>0,
  data_width =>8)
  port map(
   clk       =>clk,
   rst       =>rst,
   tx_data   =>tx_data_reg,
   data_valid=>data_valid_seg,
   tx_busy   =>tx_busy,
   tx        =>uart_tx);
  
 u_ft232h_control:entity work.ft232h_control
  port map(
   clkout    =>ft232out_clk,
   rst       =>rst,
   rxf       =>rxf,
   txe       =>txe,
   data_rd_en    =>data_rd_en,
   data_wr_en    =>data_wr_en,
   rd_s_done     =>ft232h_rd_s_done,
   wr_s_done     =>ft232h_wr_s_done,
   ft232h_data_in=>ft232h_data_in,
   rd_length =>rd_length,
   wr_length =>wr_length,
   rd        =>rd_reg,
   wr        =>wr_reg,
   oe        =>oe_reg,
   ft232h_data_out=>ft232h_data_out,
   data      =>ft232h_data,
   usb_data_valid=>usb_dst_valid,
   usb_data      =>usb_dst_data,
   usb_data_ready=>usb_dst_ready,
   
   usb_stream_active=>usb_stream_active);
  
 u_ft232h_cmd_parser:entity work.ft232h_cmd_parser
  port map(
   clk             =>ft232out_clk,
   rst             =>rst,
   data_in         =>ft232h_data_out,
   uart_data_en    =>uart_data_en,
   rd_s_done       =>ft232h_rd_s_done,
   ft232h_data_en  =>ft232h_data_en,
   ft232h_cmd_valid=>ft232h_cmd_valid,
   ft232h_cmd_start=>ft232h_cmd_start,
   ft232h_cmd_count=>ft232h_cmd_count);
   
 u_usb_cdc:entity work.usb_cdc_handshake
  port map(
   src_clk         =>clk,
   src_rst         =>rst,
   src_valid       =>usb_src_valid,
   src_data        =>usb_src_data,
   src_ready       =>usb_src_ready,
   
   dst_clk         =>ft232out_clk,          
   dst_rst         =>rst,      
   dst_ready       =>usb_dst_ready,
   dst_valid       =>usb_dst_valid, 
   dst_data        =>usb_dst_data);
   
 u_fifo_generator_1_inst:entity work.fifo_generator_1
port map (
    -- 写侧：50 MHz
    wr_clk   => clk,
    wr_en    => afifo_wr_en,       -- 50 MHz 域产生
    din      => afifo_din,         -- 50 MHz 域产生
    full     => afifo_full,        -- 50 MHz 域使用

    -- 读侧：60 MHz
    rd_clk   => ft232out_clk,      -- 60 MHz
    rd_en    => afifo_rd_en,       -- 本状态机产生
    dout     => afifo_dout,        -- 本状态机使用
    empty    => afifo_empty,       -- 本状态机使用

    rst      => fifo_srst);
   
   
  probe2_vec(0)<=afifo_rd_en;
  probe3_vec(0)<=ft232h_cmd_valid;
  probe4_vec(0)<=usb_stream_active;
  u_ila_0:ila_0
   port map(
    clk=>ft232out_clk,
    probe0=>afifo_din,
    probe1=>afifo_dout,
    probe2=>probe2_vec,
    probe3=>probe3_vec,
    probe4=>probe4_vec);

end Behavioral;
