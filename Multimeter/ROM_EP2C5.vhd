entity ROM is
    port (
		clk			: in bit;
		char_address: in bit_vector(3 downto 0);
		font_col	: in bit_vector(2 downto 0);
		font_row	: in bit_vector(2 downto 0);
		data_out	: out bit
	);
end;
architecture ROM_arq of ROM is

	signal fila_rom_bin: bit_vector(6 downto 0);

	type ROM_type is array(0 to 127) of bit_vector(0 to 7);

	constant ROM: ROM_type :=(
		
		x"3C",x"42",x"42",x"42",x"42",x"42",x"3C",x"00", -- Caracter '0'
		x"08",x"18",x"08",x"08",x"08",x"08",x"1C",x"00", -- Caracter '1'
		x"3C",x"42",x"04",x"08",x"10",x"20",x"7E",x"00", -- Caracter '2'
		x"3C",x"42",x"02",x"0C",x"02",x"42",x"3C",x"00", -- Caracter '3'
		x"0C",x"14",x"24",x"44",x"44",x"7E",x"04",x"00", -- Caracter '4'
		x"7C",x"40",x"40",x"3C",x"02",x"42",x"3C",x"00", -- Caracter '5'
		x"3C",x"40",x"40",x"7C",x"42",x"42",x"3C",x"00", -- Caracter '6'
		x"3E",x"02",x"04",x"08",x"10",x"10",x"10",x"00", -- Caracter '7'
		x"1C",x"22",x"22",x"1C",x"22",x"22",x"1C",x"00", -- Caracter '8'
		x"1C",x"22",x"22",x"22",x"1E",x"02",x"1C",x"00", -- Caracter '9' 
		x"42",x"42",x"42",x"24",x"24",x"18",x"18",x"00", -- Caracter 'V'
		x"00",x"00",x"00",x"00",x"00",x"18",x"18",x"00", -- Caracter '.'
		x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00", -- Caracter ' ' 
		x"00",x"00",x"00",x"3C",x"00",x"00",x"00",x"00", -- Caracter '-' 
		x"00",x"00",x"00",x"3C",x"00",x"00",x"00",x"00", -- Caracter '-' 
		x"00",x"00",x"00",x"3C",x"00",x"00",x"00",x"00"  -- Caracter '-' 
	);
	
	function conv_to_integer (a: bit_vector) return natural is
		variable result: natural := 0;
	begin
		for i in a'range loop
			if a(i)='1' then
				result:= result + 2**i;
			end if;
		end loop;
		return result;
	end;

begin

	fila_rom_bin <= char_address & font_row;
	
	process(clk)
    begin
        if clk'event and clk = '1' then
            data_out <= ROM(conv_to_integer(fila_rom_bin))(conv_to_integer(font_col));
        end if;
    end process;

end; 
