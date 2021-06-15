library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity DigitalClock_Stage1 is
	port(
		clkIn 		: 	in std_logic;
		resetDisp 	: 	in std_logic;
		mU				: 	out std_logic_vector(6 downto 0);
		mT				: 	out std_logic_vector(6 downto 0);
		hU				: 	out std_logic_vector(6 downto 0);
		hT				: 	out std_logic_vector(6 downto 0);
		clkT			: 	out std_logic
	);
end DigitalClock_Stage1;

architecture Structural of DigitalClock_Stage1 is
	
-- Divided clocks for clock components
signal clkTime 		: 	std_logic;
signal clkProg 		: 	std_logic;
signal clkDisp 		: 	std_logic;

-- PCounter4 enable signals
signal secTEnable 	: 	std_logic;
signal minUEnable 	: 	std_logic;
signal minTEnable 	: 	std_logic;
signal hourUEnable 	: 	std_logic;
signal hourTEnable 	: 	std_logic;

-- PCounter4 data signals
signal secUData 		: 	std_logic_vector(3 downto 0);
signal secTData 		: 	std_logic_vector(3 downto 0);
signal minUData 		: 	std_logic_vector(3 downto 0);
signal minTData 		: 	std_logic_vector(3 downto 0);
signal hourUData 		: 	std_logic_vector(3 downto 0);
signal hourTData 		: 	std_logic_vector(3 downto 0);

-- Mux signals
signal s_sel 			: 	std_logic_vector(1 downto 0);
signal s_dataOut 		: 	std_logic_vector(3 downto 0);

-- 7 seg decoder signals
signal s_decOutput 	: 	std_logic_vector(6 downto 0);

-- Final Values
signal s_finalOutMU 	: 	std_logic_vector(7 downto 0) := "01000000";
signal s_finalOutMT 	: 	std_logic_vector(7 downto 0) := "01000000";
signal s_finalOutHU 	: 	std_logic_vector(7 downto 0) := "01000000";
signal s_finalOutHT 	: 	std_logic_vector(7 downto 0) := "01000000";


begin

	-- Generate clocks
	syncGen 			: 	entity work.SyncGen(Structural)
								port map(
									clkIn 	=> 	clkIn,
									clkTime 	=> 	clkTime,
									clkProg 	=> 	clkProg,
									clkDisp 	=> 	clkDisp
								);
								
	-- Control display							
	disp				: entity work.RelogioDigital(Behavior)
								port map(
									clock 	=>		clkDisp,
									s0			=>		s_sel(0),
									s1			=>		s_sel(1),
									dispStart=>		'1',
									reset 	=>		resetDisp
								);
								
	-- Get time data
		-- Get time data
	counterSecU 	: entity work.PCounter4(Behavioral)
								port map(
									clk			=> 	clkIn,
									reset			=>		resetDisp,
									enable		=>		clkTime,
									TC				=>		secTEnable,
									Q				=>		secUData	
								);	
	counterSecT 	: entity work.PCounter4(Behavioral)
								generic map(
									limit			=> 6
								)
								port map(
									clk			=> 	clkIn,
									reset			=>		resetDisp,
									enable		=>		secTEnable,
									TC				=>		minUEnable,
									Q				=>		secTData
								);
	counterMinU 	: entity work.PCounter4(Behavioral)
								port map(
									clk			=> 	clkIn,
									reset			=>		resetDisp,
									enable		=>		minUEnable,
									TC				=>		minTEnable,
									Q				=>		minUData
								);
	counterMinT 	: entity work.PCounter4(Behavioral)
								generic map(
									limit			=> 6
								)
								port map(
									clk			=> 	clkIn,
									reset			=>		resetDisp,
									enable		=>		minTEnable,
									TC				=>		hourUEnable,
									Q				=>		minTData
								);
	counterHourU 	: entity work.PCounter4(Behavioral)
								port map(
									clk			=> 	clkIn,
									reset			=>		resetDisp,
									enable		=>		hourUEnable,
									TC				=>		hourTEnable,
									Q				=>		hourUData
								);
							
	counterHourT 	: entity work.PCounter4(Behavioral)
								port map(
									clk			=> 	clkIn,
									reset			=>		resetDisp,
									enable		=>		hourTEnable,
									Q				=>		hourTData
								);
	
	-- Iterate time data on refresh
	mux				: entity work.Mux8_1_4Bits(Behavioral)
								port map(
									sel 	  	=> 	s_sel,
									dataIn0 	=> 	minUData,
									dataIn1 	=> 	minTData,
									dataIn2 	=>		hourUData,
									dataIn3 	=> 	hourTData,
									dataOut 	=> 	s_dataOut
								);
								
	bin7SegDecoder : entity work.Bin7SegDecoder(Behavioral)
							port map(
								binInput	=>		s_dataOut,
								decOut_n =>		s_decOutput
							);
							
	-- Registers to store time data (HH:MM)
	minUReg			: entity work.Register_8Bits(Behavioral)
								generic map(
									defData	=>		"01000000"
								)
								port map(
									reset		=>		resetDisp,
									clk		=>		clkIn,
									wrEn		=> 	not s_sel(1) and not s_sel(0),
									dataIn 	=> 	'0' & s_decOutput,
									dataOut 	=> 	s_finalOutMU
								);
	
	minTReg			: entity work.Register_8Bits(Behavioral)
								generic map(
									defData	=>		"01000000"
								)
								port map(
									reset		=>		resetDisp,
									clk		=>		clkIn,
									wrEn		=> 	not s_sel(1) and s_sel(0),
									dataIn 	=> 	'0' & s_decOutput,
									dataOut 	=> 	s_finalOutMT
								);
								
	hourUReg			: entity work.Register_8Bits(Behavioral)
								generic map(
									defData	=>		"01000000"
								)
								port map(
									reset		=>		resetDisp,
									clk		=>		clkIn,
									wrEn		=> 	s_sel(1) and not s_sel(0),
									dataIn 	=> 	'0' & s_decOutput,
									dataOut 	=> 	s_finalOutHU
								);
								
	hourTReg			: entity work.Register_8Bits(Behavioral)
								generic map(
									defData	=>		"01000000"
								)
								port map(
									reset		=>		resetDisp,
									clk		=>		clkIn,
									wrEn		=> 	s_sel(1) and s_sel(0),
									dataIn 	=> 	'0' & s_decOutput,
									dataOut 	=> 	s_finalOutHT
								);
	
	-- Final connections
	mU			<= 	s_finalOutMU(6 downto 0);
	mT			<= 	s_finalOutMT(6 downto 0);
	hU			<= 	s_finalOutHU(6 downto 0);
	hT			<= 	s_finalOutHT(6 downto 0);
	clkT		<= 	clkTime;

end Structural;
