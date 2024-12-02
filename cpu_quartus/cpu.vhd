library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cpu is
    port (
        clk: in STD_LOGIC; 
        reset: in STD_LOGIC := '1';
        Key: in STD_LOGIC_VECTOR (7 downto 0) := "00000000"; --chaves FPGA
        w: buffer STD_LOGIC := '1'; --usado para o WAITT
        go: buffer STD_LOGIC := '1';
        Led: out STD_LOGIC_VECTOR (7 downto 0) := "00000000" --sa�das FPGA
    );
end entity;

architecture behaviour of cpu is

    type state_type is (FETCH, DECODE, IMMEDIATE, LOAD_MEM, EXECUTE, LOAD_ANS); --A opera��o fica pronta APENAS DEPOIS do EXECUTE
    --Poss�vel estado LOAD_ANS, p n precisar ir pro prox FETCH, j� que seria o come�o da prox instru��o (opera��es ULA)
    signal state: state_type := FETCH; --criando a vari�vel estado e atribui�ndo valor inicial para FETCH

    --Facilitando pra verificar as opera��es
    constant ADD   : STD_LOGIC_VECTOR (3 downto 0) := "0000";
    constant SUB   : STD_LOGIC_VECTOR (3 downto 0) := "0001";
    constant ANDD  : STD_LOGIC_VECTOR (3 downto 0) := "0010";
    constant ORR   : STD_LOGIC_VECTOR (3 downto 0) := "0011";
    constant NOTT  : STD_LOGIC_VECTOR (3 downto 0) := "0100";
    constant CMP   : STD_LOGIC_VECTOR (3 downto 0) := "0101";
    constant JMP   : STD_LOGIC_VECTOR (3 downto 0) := "0110";
    constant JEQ   : STD_LOGIC_VECTOR (3 downto 0) := "0111";
    constant JGR   : STD_LOGIC_VECTOR (3 downto 0) := "1000";
    constant LOAD  : STD_LOGIC_VECTOR (3 downto 0) := "1001";
    constant STORE : STD_LOGIC_VECTOR (3 downto 0) := "1010";
    constant MOV   : STD_LOGIC_VECTOR (3 downto 0) := "1011";
    constant INN   : STD_LOGIC_VECTOR (3 downto 0) := "1100";
    constant OUTT  : STD_LOGIC_VECTOR (3 downto 0) := "1101";
    constant WAITT : STD_LOGIC_VECTOR (3 downto 0) := "1110";

    component ram256x8 is
        port(
            address: in STD_LOGIC_VECTOR (7 downto 0) := "00000000";
            clock: in STD_LOGIC  := '1';
            data: in STD_LOGIC_VECTOR (7 downto 0);
            wren: in STD_LOGIC;
            q: out STD_LOGIC_VECTOR (7 downto 0)
        );
    end component;

    component ula is
        port (
            op: in STD_LOGIC_VECTOR (3 downto 0);
            A: in STD_LOGIC_VECTOR (7 downto 0);
            B: in STD_LOGIC_VECTOR (7 downto 0);
            R: out STD_LOGIC_VECTOR (7 downto 0);
            Zero: out STD_LOGIC := '0';
            Sinal: out STD_LOGIC := '0';
            Carry: out STD_LOGIC := '0';
            Overflow: out STD_LOGIC := '0'
        );
    end component;

    --registradores
    signal r1, r2, rs: STD_LOGIC_VECTOR (7 downto 0);

    --para a ram
    signal address, data, q: STD_LOGIC_VECTOR (7 downto 0);
    signal wen: STD_LOGIC := '0'; 

    --para a ula
    signal A, B, R: STD_LOGIC_VECTOR (7 downto 0);
    signal zero, sinal, over, carry: STD_LOGIC;
    signal z, s, c, o: STD_LOGIC;

    --input decodificado
    signal operation: STD_LOGIC_VECTOR (3 downto 0);
    signal operator1, operator2: STD_LOGIC_VECTOR (1 downto 0);


begin

    ram: ram256x8
     port map(
        address => address,
        clock => clk,
        data => data,
        wren => wen,
        q => q
    );

    alu: ula
     port map(
        op => operation,
        A => A,
        B => B,
        R => R,
        Zero => z,
        Sinal => s,
        Carry => c,
        Overflow => o
    );

    process(clk, reset)

        --program counter
        variable pcounter: STD_LOGIC_VECTOR (7 downto 0) := "00000000";

        variable ers: STD_LOGIC := '0';

        variable eflag: STD_LOGIC := '0';
		  
		  variable econt: STD_LOGIC := '0';
		  
		  variable cont : NATURAL := 0;

    begin
        if reset='0' then 
            state <= FETCH;
        elsif rising_edge(clk) then
            case state is
                when FETCH =>
                    go <= '1';
                    w <= '1';
                    address <= pcounter;
                    pcounter := STD_LOGIC_VECTOR(unsigned(pcounter)+1);
                    state <= DECODE;
                when DECODE =>
                    operation <= q(7 downto 4);
                    operator1 <= q(3 downto 2);
                    operator2 <= q(1 downto 0);
                    state <= IMMEDIATE;
                when IMMEDIATE => 
                    case operation is
                        when ADD =>
                            if operator1 = "11" or operator2 = "11" then
                                address <= pcounter;
                                pcounter := STD_LOGIC_VECTOR(unsigned(pcounter)+1);
                            end if;
                        when SUB =>
                            if operator1 = "11" or operator2 = "11" then
                                address <= pcounter;
                                pcounter := STD_LOGIC_VECTOR(unsigned(pcounter)+1);
                            end if;
                        when ANDD =>
                            if operator1 = "11" or operator2 = "11" then
                                address <= pcounter;
                                pcounter := STD_LOGIC_VECTOR(unsigned(pcounter)+1);
                            end if;
                        when ORR =>
                            if operator1 = "11" or operator2 = "11" then
                                address <= pcounter;
                                pcounter := STD_LOGIC_VECTOR(unsigned(pcounter)+1);
                            end if;
                        when CMP =>
                            if operator1 = "11" or operator2 = "11" then
                                address <= pcounter;
                                pcounter := STD_LOGIC_VECTOR(unsigned(pcounter)+1);
                            end if;
                        when MOV=>
                            if operator1 = "11" or operator2 = "11" then
                                address <= pcounter;
                                pcounter := STD_LOGIC_VECTOR(unsigned(pcounter)+1);
                            end if;
                        when NOTT =>
                            if operator1 = "11" then
                                address <= pcounter;
                                pcounter := STD_LOGIC_VECTOR(unsigned(pcounter)+1);
                            end if;
                        when JMP =>
                            if operator2 = "11" then
                                address <= pcounter;
                                pcounter := STD_LOGIC_VECTOR(unsigned(pcounter)+1);
                            end if;
                        when JEQ =>
                            if operator2 = "11" then
                                address <= pcounter;
                                pcounter := STD_LOGIC_VECTOR(unsigned(pcounter)+1);
                            end if;
                        when JGR =>
                            if operator2 = "11" then
                                address <= pcounter;
                                pcounter := STD_LOGIC_VECTOR(unsigned(pcounter)+1);
                            end if;
                        when LOAD =>
                            if operator2 = "11" then
                                address <= pcounter;
                                pcounter := STD_LOGIC_VECTOR(unsigned(pcounter)+1);
                            end if;
                        when STORE=>
                            if operator2 = "11" then
                                address <= pcounter;
                                pcounter := STD_LOGIC_VECTOR(unsigned(pcounter)+1);
                            end if;
                        when others =>
                    end case;
                    if operation=LOAD or operation=STORE then
                        state <= LOAD_MEM;
                    else 
                        state <= EXECUTE;
                    end if;
                when LOAD_MEM =>
                    if operation = STORE then
                        wen <= '1'; 
                        data <= q;
                    end if;
                    state <= EXECUTE;
                when EXECUTE => 
                    case operation is
                        when ADD =>
                            if operator1="00" then 
                                A <= r1;
                            elsif operator1="01" then
                                A <= r2;
                            elsif operator1="10" then
                                A <= rs;
                            elsif operator1="11" then
                                A <= q;
                            end if;
                            if operator2="00" then 
                                B <= r1;
                            elsif operator2="01" then
                                B <= r2;
                            elsif operator2="10" then
                                B <= rs;
                            elsif operator2="11" then
                                B <= q;
                            end if;
                            ers := '1';
                            eflag := '1';
                        when SUB =>
                            if operator1="00" then 
                                A <= r1;
                            elsif operator1="01" then
                                A <= r2;
                            elsif operator1="10" then
                                A <= rs;
                            elsif operator1="11" then
                                A <= q;
                            end if;
                            if operator2="00" then 
                                B <= r1;
                            elsif operator2="01" then
                                B <= r2;
                            elsif operator2="10" then
                                B <= rs;
                            elsif operator2="11" then
                                B <= q;
                            end if;
                            ers := '1';
                            eflag := '1';
                        when ANDD =>
                            if operator1="00" then 
                                A <= r1;
                            elsif operator1="01" then
                                A <= r2;
                            elsif operator1="10" then
                                A <= rs;
                            elsif operator1="11" then
                                A <= q;
                            end if;
                            if operator2="00" then 
                                B <= r1;
                            elsif operator2="01" then
                                B <= r2;
                            elsif operator2="10" then
                                B <= rs;
                            elsif operator2="11" then
                                B <= q;
                            end if;
                            ers := '1';
                            eflag := '1';
                        when ORR =>
                            if operator1="00" then 
                                A <= r1;
                            elsif operator1="01" then
                                A <= r2;
                            elsif operator1="10" then
                                A <= rs;
                            elsif operator1="11" then
                                A <= q;
                            end if;
                            if operator2="00" then 
                                B <= r1;
                            elsif operator2="01" then
                                B <= r2;
                            elsif operator2="10" then
                                B <= rs;
                            elsif operator2="11" then
                                B <= q;
                            end if;
                            ers := '1';
                            eflag := '1';
                        when NOTT =>
                            if operator1="00" then 
                                A <= r1;
                            elsif operator1="01" then
                                A <= r2;
                            elsif operator1="10" then
                                A <= rs;
                            elsif operator1="11" then
                                A <= q;
                            end if;
                            ers := '1';
                            eflag := '1';
                        when CMP =>
                            if operator1="00" then 
                                A <= r1;
                            elsif operator1="01" then
                                A <= r2;
                            elsif operator1="10" then
                                A <= rs;
                            elsif operator1="11" then
                                A <= q;
                            end if;
                            if operator2="00" then 
                                B <= r1;
                            elsif operator2="01" then
                                B <= r2;
                            elsif operator2="10" then
                                B <= rs;
                            elsif operator2="11" then
                                B <= q;
                            end if;
                            eflag := '1';
                        when JMP =>
                            if operator2 = "00" then
                                pcounter := r1; 
                                address <= pcounter;
                            elsif operator2 = "01" then
                                pcounter := r2; 
                                address <= pcounter;
                            elsif operator2 = "10" then
                                pcounter := rs; 
                                address <= pcounter;
                            elsif operator2 = "11" then 
                                pcounter := q; 
                                address <= pcounter;
                            end if;
                        when JEQ =>
                            if zero='1' then
                                if operator2 = "00" then
                                    pcounter := r1; 
                                    address <= pcounter;
                                elsif operator2 = "01" then
                                    pcounter := r2; 
                                    address <= pcounter;
                                elsif operator2 = "10" then
                                    pcounter := rs; 
                                    address <= pcounter;
                                elsif operator2 = "11" then 
                                    pcounter := q; 
                                    address <= pcounter;
                                end if;
                            end if;
                        when JGR =>
                            if sinal='0' then
                                if operator2 = "00" then
                                    pcounter := r1; 
                                    address <= pcounter;
                                elsif operator2 = "01" then
                                    pcounter := r2; 
                                    address <= pcounter;
                                elsif operator2 = "10" then
                                    pcounter := rs; 
                                    address <= pcounter;
                                elsif operator2 = "11" then 
                                    pcounter := q; 
                                    address <= pcounter;
                                end if;
                            end if;
                        when LOAD =>
                            if operator2 = "00" then
                                address <= r1;
                            elsif operator2 = "01" then
                                address <= r2;
                            elsif operator2 = "10" then
                                address <= rs;
                            elsif operator2 = "11" then 
                                address <= q;
                            end if;
                        when STORE =>
                            if operator2 = "00" then
                                address <= r1;
                            elsif operator2 = "01" then
                                address <= r2;
                            elsif operator2 = "10" then
                                address <= rs;
                            elsif operator2 = "11" then 
                                address <= q;
                            end if;
                            if operator1="00" then
                                data <= r1;
                            elsif operator1="01" then
                                data <= r2;
                            elsif operator1="10" then
                                data <= rs;
                            end if;
                        when MOV =>
                            if operator1 = "00" then 
                                if operator2 = "00" then 
                                    r1 <= r1;
                                elsif operator2 = "01" then
                                    r1 <= r2;
                                elsif operator2 = "10" then
                                    r1 <= rs;
                                elsif operator2 = "11" then 
                                    r1 <= q;
                                end if;
                            elsif operator1 = "01" then
                                if operator2 = "00" then 
                                    r2 <= r1;
                                elsif operator2 = "01" then
                                    r2 <= r2;
                                elsif operator2 = "10" then
                                    r2 <= rs;
                                elsif operator2 = "11" then 
                                    r2 <= q;
                                end if;
                            elsif operator1 = "10" then
                                if operator2 = "00" then 
                                    rs <= r1;
                                elsif operator2 = "01" then
                                    rs <= r2;
                                elsif operator2 = "10" then
                                    rs <= rs;
                                elsif operator2 = "11" then 
                                    rs <= q;
                                end if;
                            end if;
                        when INN =>
                            if operator1 = "00" then 
                                r1 <= Key;
                            elsif operator1 = "01" then
                                r2 <= Key;
                            elsif operator1 = "10" then
                                rs <= Key;
                            end if;
                        when OUTT =>
                            if operator1 = "00" then 
                                Led <= r1;
                            elsif operator1 = "01" then
                                Led <= r2;
                            elsif operator1 = "10" then
                                Led <= rs;
                            end if;
                        when others =>
                    end case;
                    if operation = WAITT then 
                        if w = '0' then 
                            w <= '1';
                            state <= LOAD_ANS;
                        else
                            state <= EXECUTE;
                        end if;
                    elsif operation = INN then
                        if go = '0' then
                            econt := '1';
                        else
                            if econt = '1' then 
										 cont := cont + 1;
										 if cont = 25000000 then
											 econt := '0';
											 state <= LOAD_ANS;
										 end if;
									 else
										 state <= EXECUTE;
									 end if;
                        end if;
                    else
                        state <= LOAD_ANS;
                    end if;
                when LOAD_ANS =>
                    if ers = '1' then
                        rs <= R;
                        ers := '0';
                    end if;
                    if eflag = '1' then
                        zero <= z;
                        sinal <= s;
                        carry <= c;
                        over <= o;
                        eflag := '0';
                    end if;
                    if operation = LOAD then 
                        if operator1="00" then
                            r1 <= q;
                        elsif operator1="01" then
                            r2 <= q;
                        elsif operator1="10" then
                            rs <= q;
                        end if;
                    end if;
                    if operation = STORE then 
                        wen <= '0';
                    end if;
                    state <= FETCH;
                when others =>
            end case; 
        end if;
    end process;

end architecture;