library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

entity ram256x8 is
	port(
		address: in STD_LOGIC_VECTOR (7 downto 0) := "00000000";
		clock: in STD_LOGIC  := '1';
		data: in STD_LOGIC_VECTOR (7 downto 0);
		wen: in STD_LOGIC;
		q: out STD_LOGIC_VECTOR (7 downto 0)
	);
end entity;

architecture Behaviour of ram256x8 is

	type mem is ARRAY (0 to 255) of STD_LOGIC_VECTOR (7 downto 0);

	impure function read_mem return mem is 
		file text_file : text open read_mode is "programa.hex";
		variable ram_content : mem;
		variable text_line : line;
	begin
		for i in 0 to 255 loop
			readline(text_file, text_line);
			hread(text_line, ram_content(i));
		end loop;
		  
		return ram_content;
	end function;

	signal memory_array : mem := read_mem;

begin

	process(clock)
	begin
		if rising_edge(clock) then
			if wen = '1' then
				memory_array(to_integer(unsigned(address))) <= data;
			end if;
		end if;
	end process;
	
	
	q <= memory_array(to_integer(unsigned(address)));

end architecture;