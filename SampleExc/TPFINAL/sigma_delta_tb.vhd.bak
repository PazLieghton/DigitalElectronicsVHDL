
entity ffd is
	port(
		clk	: in bit;
		rst : in bit;
		d	: in bit;
		q	: out bit
	);
end ffd;

architecture ffd_arq of ffd is
begin
	process(clk) 
	begin
		if clk'event and clk = '1' then
			if rst = '1' then
				q <= '0';
			else
				q <= d;
			end if;
		end if; 
	end process;
end;