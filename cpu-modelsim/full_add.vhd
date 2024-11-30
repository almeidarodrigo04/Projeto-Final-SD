library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity full_add is
    port (
        X: in STD_LOGIC;
        Y: in STD_LOGIC; 
        Ci: in STD_LOGIC;
        S: out STD_LOGIC;
        Co: out STD_LOGIC
    );
end entity;

architecture Behaviour of full_add is

begin

    S <= X xor Y xor Ci;
    Co <= (X and Y) or (X and Ci) or (Y and Ci);

end architecture;