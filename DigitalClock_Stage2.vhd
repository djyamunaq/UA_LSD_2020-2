-- library IEEE;
--use IEEE.std_logic_1164.all;
--use IEEE.numeric_std.all;
--
--entity DigitalClock_Stage2 is
--	port(
--		clkIn 		: 	in 	std_logic;
--		reset		 	: 	in 	std_logic;
--		ctrl			: 	in		std_logic_vector(1 downto 0);
--		mU				: 	out 	std_logic_vector(6 downto 0);
--		mT				: 	out 	std_logic_vector(6 downto 0);
--		hU				: 	out 	std_logic_vector(6 downto 0);
--		hT				: 	out 	std_logic_vector(6 downto 0);
--		clkT			: 	out 	std_logic;
--		hexDisp1		:	out 	std_logic_vector(6 downto 0);
--		hexDisp2		:	out 	std_logic_vector(6 downto 0);
--		hexDisp3		:	out 	std_logic_vector(6 downto 0)
----		;
----		secUD			: 	out 	std_logic_vector(3 downto 0);
----		secTD			: 	out 	std_logic_vector(3 downto 0);
----		minUD			: 	out 	std_logic_vector(3 downto 0);
----		minTD			: 	out 	std_logic_vector(3 downto 0);
----		hourUD		: 	out 	std_logic_vector(3 downto 0);
----		hourTD		: 	out 	std_logic_vector(3 downto 0);
----		regSel		: 	out 	std_logic_vector(7 downto 0);
----		sel   		: 	out 	std_logic_vector(1 downto 0);
----		dO				: 	out 	std_logic_vector(3 downto 0);
----		decOutput 	: 	out 	std_logic_vector(6 downto 0)
--	);
--end DigitalClock_Stage2;
--
--architecture Structural of DigitalClock_Stage2 is
--	
---- Divided clocks for clock components
--signal clkTime 			: 	std_logic;
--signal clkProg 			: 	std_logic;
--signal clkDisp 			: 	std_logic;
--
---- Debounced input signals
--signal cntrlDebounced	:	std_logic_vector(1 downto 0);
--
---- Main Control FSM signals
--signal s_dispStart		: 	std_logic := '1';
--signal s_progStart		: 	std_logic := '0';
--signal s_res				:	std_logic;
--
---- 7Seg signals for mode visor (Disp -> on / Prog -> SEt)
--signal s_hexDisp1			:	std_logic_vector(6 downto 0);
--signal s_hexDisp2			:	std_logic_vector(6 downto 0);
--signal s_hexDisp3			:	std_logic_vector(6 downto 0);
--
---- Disp FSM signals
--signal s_selDisp 			:	std_logic_vector(1 downto 0);
--signal s_dispBusy			:	std_logic;
--
---- Prog FSM signals
--signal s_selProg			:	std_logic_vector(1 downto 0);
--signal s_progBusy			:	std_logic;
--
---- PCounter4 enable signals
--signal secTEnable 		: 	std_logic;
--signal minUEnable 		: 	std_logic;
--signal minTEnable 		: 	std_logic;
--signal hourUEnable 		: 	std_logic;
--signal hourTEnable 		: 	std_logic;
--
---- PCounter4 data signals
--signal secUData 			: 	std_logic_vector(3 downto 0);
--signal secTData 			: 	std_logic_vector(3 downto 0);
--signal minUData 			: 	std_logic_vector(3 downto 0);
--signal minTData 			: 	std_logic_vector(3 downto 0);
--signal hourUData 			: 	std_logic_vector(3 downto 0);
--signal hourTData 			: 	std_logic_vector(3 downto 0);
--
---- Mux signals
--signal s_sel 				: 	std_logic_vector(1 downto 0);
--signal s_dataOut 			: 	std_logic_vector(3 downto 0);
--
---- 7 seg decoder signals
--signal s_decOutput 		: 	std_logic_vector(6 downto 0);
--
---- Final Values
--signal s_mU 				: 	std_logic_vector(7 downto 0) := "01000000";
--signal s_mT 				: 	std_logic_vector(7 downto 0) := "01000000";
--signal s_hU 				: 	std_logic_vector(7 downto 0) := "01000000";
--signal s_hT 				: 	std_logic_vector(7 downto 0) := "01000000";
--
--begin
--
--	-- Generate clocks
--	syncGen 			: 	entity work.SyncGen(Structural)
--								port map(
--									clkIn 		=> 	clk,
--									clkTime 		=> 	clkTime,
--									clkProg 		=> 	clkProg,
--									clkDisp 		=> 	clkDisp
--								);
--	
--	-- Debounced input keys
--	debounceK0		: entity work.Debouncer(Behavioral)
--								port map(
--									refClk		=>		clk,
--									dirtyIn		=>		cntrl(0),
--									pulsedOut	=>		s_cntrlDebounced(0),
--								);
--	debounceK1		: entity work.Debouncer(Behavioral)
--								port map(
--									refClk		=>		clk,
--									dirtyIn		=>		cntrl(1),
--									pulsedOut	=>		s_cntrlDebounced(1),
--								);	
--	
--	-- Main control: Switch between modes Disp/Prog
--	main				: entity work.RelogioDigital(Behavior)
--								port map(
--									clock 		=>		clk,
--									reset 		=>		reset,
--									dispBusy		=> 	s_dispBusy,
--									progBusy		=> 	s_progBusy,
--									k0				=>		ctrlDebounced(0),
--									dispStart	=>		s_dispStart,
--									progStart	=>		s_progStart,
--									resOut		=>		s_res
--								);
--	
--	-- Mode indication on HEX's 3..1
--	muxHex1			: entity work.Mux2_1_NBits(Behavioral)
--								generic(
--									N				=>	7;
--								)
--								port map(
--									sel			=> not s_dispBusy and s_progBusy,		
--									dataIn0		=> "1110000",	-- t
--									dataIn1		=>	"1111111",	-- OFF
--									dataOut		=>	s_hexDisp1
--								);
--	muxHex2			: entity work.Mux2_1_NBits(Behavioral)
--								generic(
--									N				=>	7;
--								)
--								port map(
--									sel			=> not s_dispBusy and s_progBusy,		
--									dataIn0		=> "0110000",	-- E
--									dataIn1		=>	"1101010",	-- n
--									dataOut		=>	s_hexDisp2
--								);
--	muxHex3			: entity work.Mux2_1_NBits(Behavioral)
--								generic(
--									N				=>	7;
--								)
--								port map(
--									sel			=> not s_dispBusy and s_progBusy,		
--									dataIn0		=> "1100010",	-- o
--									dataIn1		=>	"0100100",	-- S
--									dataOut		=> s_hexDisp3
--								);
--								
--	-- Control display							
--	disp				: entity work.RelogioDigital(Behavior)
--								port map(
--									clock 		=>		clkDisp,
--									reset 		=>		reset,
--									s0				=>		s_selDisp(0),
--									s1				=>		s_selDisp(1),
--									dispStart	=>		s_dispStart,
--									dispBusy		=> 	s_dispBusy
--								);
--								
--	-- Control prog mode
--	prog				: entity work.ProgFSM(Behavior)
--								port map(
--									clock 		=>		clkProg,
--									reset 		=>		reset,
--									s0				=>		s_selProg(0),
--									s1				=>		s_selProg(1),
--									k0				=>		ctrlDebounced(0),
--									k1				=>		ctrlDebounced(1),
--									up				=>		s_up,
--									down			=>		s_down,
--									progStart	=>		s_progStart,
--									progBusy		=> 	s_progBusy
--								);
--								
--	-- Get time data
--	counterSecU 	: entity work.PCounter4(Behavioral)
--								port map(
--									reset			=>		s_res,
--									enable		=>		clkTime,
--									TC				=>		secTEnable,
--									Q				=>		secUData	
--								);	
--	counterSecT 	: entity work.PCounter4(Behavioral)
--								generic map(
--									limit			=> 6
--								)
--								port map(
--									reset			=>		s_res,
--									enable		=>		secTEnable,
--									TC				=>		minUEnable,
--									Q				=>		secTData
--								);
--	counterMinU 	: entity work.PCounter4(Behavioral)
--								port map(
--									reset			=>		s_res,
--									enable		=>		minUEnable,
--									TC				=>		minTEnable,
--									Q				=>		minUData
--								);
--	counterMinT 	: entity work.PCounter4(Behavioral)
--								generic map(
--									limit			=> 6
--								)
--								port map(
--									reset			=>		s_res,
--									enable		=>		minTEnable,
--									TC				=>		hourUEnable,
--									Q				=>		minTData
--								);
--	counterHourU 	: entity work.PCounter4(Behavioral)
--								port map(
--									reset			=>		s_res,
--									enable		=>		hourUEnable,
--									TC				=>		hourTEnable,
--									Q				=>		hourUData
--								);
--							
--	counterHourT 	: entity work.PCounter4(Behavioral)
--								port map(
--									reset			=>		s_res,
--									enable		=>		hourTEnable,
--									Q				=>		hourTData
--								);
--								
--	-- Iterate time data on refresh
--	muxDisp			: entity work.Mux8_1_4Bits(Behavioral)
--								port map(
--									sel 	  		=> 	s_selDisp,
--									dataIn0 		=> 	minUData,
--									dataIn1 		=> 	minTData,
--									dataIn2 		=>		hourUData,
--									dataIn3 		=> 	hourTData,
--									dataOut 		=> 	s_dataOut
--								);
--								
--	bin7SegDecoder : entity work.Bin7SegDecoder(Behavioral)
--							port map(
--								binInput			=>		s_dataOut,
--								decOut_n 		=>		s_decOutput
--							);
--
--	minUReg			: entity work.Register_8Bits(Behavioral)
--								generic map(
--									defData		=>		"01000000"
--								)
--								port map(
--									reset			=>		res,
--									clk			=>		clk,
--									wrEn			=> 	not s_sel(1) and not s_sel(0),
--									dataIn 		=> 	'0' & s_decOutput,
--									dataOut 		=> 	s_mU
--								);
--	
--	minTReg			: entity work.Register_8Bits(Behavioral)
--								generic map(
--									defData		=>		"01000000"
--								)
--								port map(
--									reset			=>		res,
--									clk			=>		clk,
--									wrEn			=> 	not s_sel(1) and s_sel(0),
--									dataIn 		=> 	'0' & s_decOutput,
--									dataOut 		=> 	s_mT
--								);
--								
--	hourUReg			: entity work.Register_8Bits(Behavioral)
--								generic map(
--									defData		=>		"01000000"
--								)
--								port map(
--									reset			=>		res,
--									clk			=>		clk,
--									wrEn			=> 	s_sel(1) and not s_sel(0),
--									dataIn 		=> 	'0' & s_decOutput,
--									dataOut 		=> 	s_hU
--								);
--								
--	hourTReg			: entity work.Register_8Bits(Behavioral)
--								generic map(
--									defData		=>		"01000000"
--								)
--								port map(
--									reset			=>		res,
--									clk			=>		clk,
--									wrEn			=> 	s_sel(1) and s_sel(0),
--									dataIn 		=> 	'0' & s_decOutput,
--									dataOut 		=> 	s_hT
--								);
--	
--	-- Output connections
--	mU			<= 	s_mU(6 downto 0);
--	mT			<= 	s_mT(6 downto 0);
--	hU			<= 	s_hU(6 downto 0);
--	hT			<= 	s_hT(6 downto 0);
--	hexDisp1	<=		s_hexDisp1;
--	hexDisp2	<=		s_hexDisp2;
--	hexDisp3	<=		s_hexDisp3;
--	clkT		<= 	clkTime;
----	secUD 	<= 	secUData;
----	secTD 	<= 	secTData;
----	minUD 	<= 	minUData;
----	minTD 	<= 	minTData;
----	hourUD 	<= 	hourUData;
----	hourTD 	<= 	hourTData;
----	sel 		<= 	s_sel;
----	regSel	<= 	s_regSel;
----	dO			<= 	s_dataOut;
----	decOutPut<= 	s_decOutput;
--	
--end Structural;
