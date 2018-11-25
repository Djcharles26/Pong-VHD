Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;


Entity PONG is
	port(clk,reset:in std_logic;
			Btn: in std_logic_vector(3 downto 0);
			blann : out std_logic;
			RGB: out std_logic_vector(2 downto 0):="000";
			lm,rm: out std_logic_vector(6 downto 0);
			VGA_HS: inout std_logic;
			VGA_VS,VGA_SYNC_N,VGA_BLANK_N,VGA_CLK: out std_logic
		);
end PONG;

architecture funcional of PONG is

--ball Signals--
signal hmove: Integer :=908;
signal rH : Integer := 10;
signal vmove: Integer :=261;
signal rV : Integer := 5;
signal hband: std_logic:='1';
signal vband: std_logic:='1';
--Racket signals--
signal lRacket : Integer:=408;
signal lRacketY : Integer:=261;
signal rRacketY : Integer:=261;
signal rHeight : Integer := 40;
Signal rRacket : Integer :=1448;
Signal BtnIsClicked: std_logic_vector(3 downto 0);
Signal collision: std_logic:='0';
Signal lcnt : Integer:=0;
Signal rcnt : Integer:=0;
--FRAME RATE cnt Signal--
Signal cnt : Integer range 0 to 50000000 := 0;
--Screen signals--
signal hcont:STD_LOGIC_vector(10 downto 0);
signal vcont: STD_LOGIC_vector(10 downto 0);
signal blank: STD_LOGIC;
--score
signal dig_0, dig_1 : std_logic_vector(6 downto 0);


	Begin
	dig_0 <= "0111111" when lcnt = 0 else  
	"0000110" when lcnt = 1 else                 -- Desplegar el uno 
	"1011011" when lcnt = 2 else                 -- Desplegar el dos 
	"1001111" when lcnt = 3 else                 -- Desplegar el tres 
	"1100110" when lcnt = 4 else                 -- Desplegar el cuatro 
	"1101101" when lcnt = 5 else                 -- Desplegar el cinco 
	"1111101" when lcnt = 6 else                 -- Desplegar el seis 
	"0000111" when lcnt = 7 else                 -- Desplegar el siete 
	"1111111" when lcnt = 8 else                	-- Desplegar el ocho 
	"1101111" when lcnt = 9 else                	-- Desplegar el nueve 
	"0000000";
	
	
	lm (6 downto 0)<=not(dig_0);
	
	dig_1 <= "0111111" when rcnt = 0 else  
	"0000110" when rcnt = 1 else                 -- Desplegar el uno 
	"1011011" when rcnt = 2 else                 -- Desplegar el dos 
	"1001111" when rcnt = 3 else                 -- Desplegar el tres 
	"1100110" when rcnt = 4 else                 -- Desplegar el cuatro 
	"1101101" when rcnt = 5 else                 -- Desplegar el cinco 
	"1111101" when rcnt = 6 else                 -- Desplegar el seis 
	"0000111" when rcnt = 7 else                 -- Desplegar el siete 
	"1111111" when rcnt = 8 else                	-- Desplegar el ocho 
	"1101111" when rcnt = 9 else                	-- Desplegar el nueve 
	"0000000";
	
	rm (6 downto 0)<=not(dig_1);
	
	
	--This should be in all programs--
	VGA_SYNC_N<='1';
	VGA_BLANK_N<='1';
	VGA_CLK<=CLK;
	blann <= blank;
--Contador Horizontal	
	a:process(clk,reset,hcont)
	begin
		if(reset='1') then 
				hcont<="00000000000";
		elsif(rising_edge (clk)) then
			if hcont>= 1600 then
				hcont<=(others=>'0');
			else
				hcont<=hcont +1 ;
			end if;
		end if;
	end process;
	
--Sincronia Horizontal
	b:process(reset,hcont,clk)
	begin
		if reset='1' then
			VGA_HS<='1';
		elsif(rising_edge(clk)) then
			if(hcont>=0 and hcont<192)then
				VGA_HS<='0';
			else
				VGA_HS<='1';
			end if;
		end if;
	end process;
	
--Contador Vertical
	c:process(reset,VGA_HS,vcont)
	begin
		if reset='1' then
			vcont<=(others=>'0');
		elsif (VGA_HS'event and VGA_HS='0')then
			if vcont>=521 then
				vcont<=(others=>'0');
			else
				vcont<=vcont+1;
			end if;
		end if;
	end process;
	
	
	
	
	
	
--Sincronia Vertical	
	d:process(reset,vcont,clk)
	begin
		if reset='1' then
			VGA_VS<='1';
		elsif(rising_edge(clk))then
			if(vcont>=0 and vcont<2)then
				VGA_VS<='0';
			else
				VGA_VS<='1';
			end if;
		end if;
	end process;
	
	
	
--Blank	
	e:process(clk,hcont,vcont)
	begin
		if(hcont>288 and hcont<1568 and vcont>31 and vcont<511)then
			blank<='1';
		else
			blank<='0';
		end if;
	end process;
	
	
---------------------------------ball--------------------------------
	h : process(reset,clk,blank,hcont,vcont,hmove,vmove,hband,vband,Btn(3 downto 0), rv, rh,rRacket,lRacket,rRacketY,lRacketY,rHeight,collision,BtnIsClicked(3 downto 0))
	Begin
		if(reset='1') then
			RGB<="000";
			hmove <= 928;
			vmove <=271;
			lRacketY <= 261;
			rRacketY <= 261;
			lcnt <= 0;
			rcnt <= 0;
		elsif(rising_edge(clk))then
			if blank = '1' then
				if(lcnt>=9)then
					RGB<="100";
				elsif(rcnt>=9)then
					RGB<="010";
				else
					if(hcont>= 288 + 640 and hcont < 280 + 660 and vcont>=31 and vcont<511)then
						RGB<="111";
					end if;
					
					if(hcont>=hmove - rH and hcont<hmove + rH and vcont>=vmove - rV and vcont<vmove + rV) then
						RGB <="111";
					else
						RGB <="000";
					end if;
					if( cnt = 199999) then
						if(vband = '1')then
							vmove<=vmove +1;
						else 
							vmove<= vmove -1;
						end if;
						if(hband  = '1')then
							hmove <= hmove +2 ;
						else
							hmove <= hmove -2;
						end if;
						if(collision = '1') then
							collision <= '0';
						end if;
						cnt <= 0;
					else
						cnt <= cnt + 1;
					end if;
					if(vmove +rV = 511) then
						vband <= '0';
					elsif(vmove -rV = 31) then
						vband <= '1';
					end if;
					if(hcont>=lRacket - rH and hcont<lRacket + rH and vcont>= lRacketY -rHeight and vcont < lRacketY + rHeight)then
						RGB<="111";
					elsif(hcont>=rRacket - rH and hcont<rRacket + rH and vcont>= rRacketY -rHeight and vcont < rRacketY + rHeight) then
						RGB<="111";
					end if;
					if(hmove -rH = lRacket + rH  and (vmove >= lRacketY -rHeight -5  and vmove < lRacketY + rHeight +5) and collision = '0') then
						hband<= not hband;
						collision <= '1';
					elsif(hmove +rH = rRacket - rH and (vmove >= rRacketY -rHeight -5 and vmove < rRacketY + rHeight + 5) and collision = '0')then
						hband<= not hband;
						collision <='1';
					end if;
					if(hmove +rH = 1568)then
						hmove <= 928;
						vmove <= 271;
						lcnt <= lcnt + 1;
					elsif( hmove -rH = 288)then
						hmove <= 928;
						vmove <= 271;
						rcnt <= rcnt +1;
					end if;
					
					if(Btn(0)='0' and BtnIsClicked(0)='0') then 
						lRacketY <= lRacketY - 40;
						BtnIsClicked(0) <= '1';
					elsif(Btn(0)='1') then
						BtnIsClicked(0) <='0';
					end if;
					if(Btn(1)='0' and BtnIsClicked(1)='0') then
						lRacketY <= lRacketY + 40;
						BtnIsClicked(1) <='1';
					elsif(Btn(1)='1') then
						BtnIsClicked(1) <='0';
					end if;
					
					if(Btn(2)='0' and BtnIsClicked(2)='0') then 
						rRacketY <= rRacketY - 40;
						BtnIsClicked(2) <= '1';
					elsif(Btn(2)='1') then
						BtnIsClicked(2) <='0';
					end if;
					
					if(Btn(3)='0' and BtnIsClicked(3)='0') then
						rRacketY <= rRacketY + 40;
						BtnIsClicked(3) <='1';
					elsif(Btn(3)='1') then
						BtnIsClicked(3) <='0';
					end if;
				end if;
			else
				RGB<="000";
			end if;
		end if;
	End process;
	

	
	
	
End funcional;