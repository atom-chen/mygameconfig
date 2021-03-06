
-- local _cardres = {
-- 	10,11,12,13, -- 2
-- 	20,21,22,23, --3
-- 	30,31,32,33, --4
-- 	40,41,42,43, --5
-- 	50,51,52,53, --6
-- 	60,61,62,63, --7
-- 	70,71,72,73, --8
-- 	80,81,82,83, --9
-- 	90,91,92,93, --10
-- 	100,101,102,103, --j
-- 	110,111,112,113, --Q
-- 	120,121,122,123, --k
-- 	130,131,132,133} -- A

-- logic.ct_flushstraight = 9	--同花顺
-- logic.ct_quad = 8 		   	--4张
-- logic.ct_fullhouse = 7 		--葫芦
-- logic.ct_flush = 6			--同花
-- logic.ct_straight = 5		--顺子
-- logic.ct_set = 4			--三张
-- logic.ct_twopair = 3		--两队
-- logic.ct_pair = 2			--对子
-- logic.ct_highcard = 1		--高牌



local test = {
	[1] = {cards1 = {130, 10, 20, 30, 40}, cards2 = {131, 11, 21, 31, 42}, win = 1},
	[2] = {cards1 = {130, 10, 20, 30, 41}, cards2 = {132, 12, 22, 32, 42}, win = 2},
	[3] = {cards1 = {130, 120, 110, 100, 90}, cards2 = {121, 111, 101, 91, 81}, win = 1},
	[4] = {cards1 = {133, 123, 113, 103, 93}, cards2 = {112, 102, 92, 82, 72}, win = 1},
	[5] = {cards1 = {132, 122, 112, 102, 92}, cards2 = {103, 93, 83, 73, 63}, win = 1},
	[6] = {cards1 = {131, 121, 111, 101, 91}, cards2 = {90, 80, 70, 60, 50}, win = 1},
	[7] = {cards1 = {132, 122, 112, 102, 92}, cards2 = {81, 71, 61, 51, 41}, win = 1},
	[8] = {cards1 = {133, 123, 113, 103, 93}, cards2 = {72, 62, 52, 42, 32}, win = 1},
	[9] = {cards1 = {130, 120, 110, 100, 90}, cards2 = {63, 53, 43, 33, 23}, win = 1},
	[10] = {cards1 = {132, 122, 112, 102, 92}, cards2 = {50, 40, 40, 20, 10}, win = 1},
	[11] = {cards1 = {131, 121, 111, 101, 91}, cards2 = {43, 33, 23, 13, 133}, win = 1},
	[12] = {cards1 = {121, 111, 101, 91, 81}, cards2 = {130, 120, 110, 100, 90}, win = 2},
	[13] = {cards1 = {122, 112, 102, 92, 82}, cards2 = {113, 103, 93, 83, 73}, win = 1},
	[14] = {cards1 = {120, 110, 100, 90, 80}, cards2 = {103, 93, 83, 73, 63}, win = 1},
	[15] = {cards1 = {121, 111, 101, 91, 81}, cards2 = {90, 80, 70, 60, 50}, win = 1},
	[16] = {cards1 = {123, 113, 103, 93, 83}, cards2 = {81, 71, 61, 51, 41}, win = 1},
	[17] = {cards1 = {120, 110, 100, 90, 80}, cards2 = {72, 62, 52, 42, 32}, win = 1},
	[18] = {cards1 = {121, 111, 101, 91, 81}, cards2 = {63, 53, 43, 33, 23}, win = 1},
	[19] = {cards1 = {122, 112, 102, 92, 82}, cards2 = {50, 40, 30, 20, 10}, win = 1},
	[20] = {cards1 = {120, 110, 100, 90, 80}, cards2 = {41, 31, 21, 11, 131}, win = 1},
	[21] = {cards1 = {113, 103, 93, 83, 73}, cards2 = {130, 120, 110, 100, 90}, win = 2},
	[22] = {cards1 = {112, 102, 92, 82, 72}, cards2 = {121, 111, 101, 91, 81}, win = 2},
	[23] = {cards1 = {113, 103, 93, 83, 73}, cards2 = {102, 92, 82, 72, 62}, win = 1},
	[24] = {cards1 = {110, 100, 90, 80, 70}, cards2 = {93, 83, 73, 63, 53}, win = 1},
	[25] = {cards1 = {113, 103, 93, 83, 73}, cards2 = {81, 71, 61, 51, 41}, win = 1},
	[26] = {cards1 = {112, 102, 92, 82, 72}, cards2 = {70, 60, 50, 40, 30}, win = 1},
	[27] = {cards1 = {111, 101, 91, 81, 71}, cards2 = {63, 53, 43, 33, 23}, win = 1},
	[28] = {cards1 = {110, 100, 90, 80, 70}, cards2 = {51, 41, 31, 21, 11}, win = 1},
	[29] = {cards1 = {113, 103, 93, 83, 73}, cards2 = {42, 32, 22, 12, 132}, win = 1},
	[30] = {cards1 = {103, 93, 83, 73, 63}, cards2 = {112, 102, 92, 82, 72}, win = 2},
	[31] = {cards1 = {102, 92, 82, 72, 62}, cards2 = {123, 113, 103, 93, 83}, win = 2},
	[32] = {cards1 = {101, 91, 81, 71, 61}, cards2 = {130, 120, 110, 100, 90}, win = 2},
	[33] = {cards1 = {100, 90, 80, 70, 60}, cards2 = {91, 81, 71, 61, 51}, win = 1},
	[34] = {cards1 = {100, 90, 80, 70, 60}, cards2 = {82, 72, 62, 52, 42}, win = 1},
	[35] = {cards1 = {101, 91, 81, 71, 61}, cards2 = {73, 63, 53, 43, 33}, win = 1},
	[36] = {cards1 = {102, 92, 82, 72, 62}, cards2 = {61, 51, 41, 31, 21}, win = 1},
	[37] = {cards1 = {103, 93, 83, 73, 63}, cards2 = {50, 40, 30, 20, 10}, win = 1},
	[38] = {cards1 = {100, 90, 80, 70, 60}, cards2 = {41, 31, 21, 11, 131}, win = 1},
	[39] = {cards1 = {90, 80, 70, 60, 50}, cards2 = {103, 93, 83, 73, 63}, win = 2},
	[40] = {cards1 = {91, 81, 71, 61, 51}, cards2 = {113, 103, 93, 83, 73}, win = 2},
	[41] = {cards1 = {92, 82, 72, 62, 52}, cards2 = {120, 110, 100, 90, 80}, win = 2},
	[42] = {cards1 = {93, 83, 73, 63, 53}, cards2 = {132, 122, 112, 102, 92}, win = 2},
	[43] = {cards1 = {80, 70, 60, 50, 40}, cards2 = {91, 81, 71, 61, 51}, win = 2},
	[44] = {cards1 = {82, 72, 62, 52, 42}, cards2 = {101, 91, 81, 71, 61}, win = 2},
	[45] = {cards1 = {81, 71, 61, 51, 41}, cards2 = {112, 102, 92, 82, 72}, win = 2},
	[46] = {cards1 = {83, 73, 63, 53, 43}, cards2 = {120, 110, 100, 90, 80}, win = 2},
	[47] = {cards1 = {80, 70, 60, 50, 40}, cards2 = {131, 121, 111, 101, 91}, win = 2},
	[48] = {cards1 = {41, 31, 21, 11, 131}, cards2 = {130, 120, 110, 110, 90}, win = 1},
	[49] = {cards1 = {41, 31, 21, 11, 131}, cards2 = {122, 112, 102, 92, 82}, win = 2},
	[50] = {cards1 = {42, 32, 22, 12, 132}, cards2 = {111, 101, 91, 81, 71}, win = 2},
	[51] = {cards1 = {43, 33, 23, 13, 133}, cards2 = {100, 90, 80, 70, 60}, win = 2},
	[52] = {cards1 = {40, 30, 20, 10, 130}, cards2 = {93, 83, 73, 63, 53}, win = 2},
	[53] = {cards1 = {41, 31, 21, 11, 131}, cards2 = {82, 72, 62, 52, 42}, win = 2},
	[54] = {cards1 = {41, 31, 21, 11, 131}, cards2 = {73, 63, 53, 43, 33}, win = 2},
	[55] = {cards1 = {40, 30, 20, 10, 130}, cards2 = {61, 51, 41, 31, 21}, win = 2},
	[56] = {cards1 = {43, 33, 23, 13, 133}, cards2 = {52, 42, 32, 22, 12}, win = 2},
	[57] = {cards1 = {130, 120, 110, 100, 90}, cards2 = {131, 121, 111, 101, 41}, win = 1},
	[58] = {cards1 = {121, 111, 101, 91, 81}, cards2 = {131, 130, 133, 132, 120}, win = 1},	
	[59] = {cards1 = {111, 101, 91, 81, 71}, cards2 = {131, 130, 133, 122, 120}, win = 1},
	[60] = {cards1 = {103, 93, 83, 73, 63}, cards2 = {131, 120, 111, 103, 90}, win = 1},
	[61] = {cards1 = {90, 80, 70, 60, 50}, cards2 = {131, 130, 133, 92, 120}, win = 1},
	[62] = {cards1 = {82, 72, 62, 52, 42}, cards2 = {131, 130, 123, 121, 10}, win = 1},
	[63] = {cards1 = {71, 61, 51, 41, 31}, cards2 = {131, 130, 113, 132, 120}, win = 1},
	[64] = {cards1 = {63, 53, 43, 33, 23}, cards2 = {131, 121, 110, 102, 70}, win = 1},
	[65] = {cards1 = {130, 121, 101, 103, 81}, cards2 = {132, 122, 112, 102, 92}, win = 2},
	[66] = {cards1 = {130, 131, 121, 103, 61}, cards2 = {122, 112, 102, 92, 82}, win = 2},
	[67] = {cards1 = {130, 131, 121, 122, 31}, cards2 = {110, 101, 91, 81, 71}, win = 2},
	[68] = {cards1 = {130, 131, 132, 103, 70}, cards2 = {100, 90, 80, 70, 60}, win = 2},
	[69] = {cards1 = {130, 121, 111, 103, 91}, cards2 = {92, 82, 72, 62, 52}, win = 2},
	[70] = {cards1 = {130, 131, 132, 103, 102}, cards2 = {81, 71, 61, 51, 41}, win = 2},
	[71] = {cards1 = {130, 131, 133, 132, 51}, cards2 = {73, 63, 53, 43, 33}, win = 2},
	[72] = {cards1 = {130, 120, 110, 100, 50}, cards2 = {51, 41, 31, 21, 11}, win = 2},
	[73] = {cards1 = {130, 131, 132, 133, 10}, cards2 = {120, 121, 122, 123, 111}, win = 1},
	[74] = {cards1 = {130, 131, 132, 133, 20}, cards2 = {110, 111, 112, 113, 102}, win = 1},
	[75] = {cards1 = {130, 131, 132, 133, 31}, cards2 = {100, 101, 102, 103, 93}, win = 1},
	[76] = {cards1 = {130, 131, 132, 133, 42}, cards2 = {90, 91, 92, 93, 80}, win = 1},
	[77] = {cards1 = {130, 131, 132, 133, 50}, cards2 = {80, 81, 82, 83, 71}, win = 1},
	[78] = {cards1 = {130, 131, 132, 133, 63}, cards2 = {70, 71, 72, 73, 62}, win = 1},
	[79] = {cards1 = {130, 131, 132, 133, 72}, cards2 = {60, 61, 62, 63, 53}, win = 1},
	[80] = {cards1 = {130, 131, 132, 133, 83}, cards2 = {50, 51, 52, 53, 41}, win = 1},
	[81] = {cards1 = {130, 131, 132, 133, 92}, cards2 = {40, 41, 42, 43, 31}, win = 1},
	[82] = {cards1 = {130, 131, 132, 133, 100}, cards2 = {30, 31, 32, 33, 23}, win = 1},
	[83] = {cards1 = {130, 131, 132, 133, 112}, cards2 = {20, 21, 22, 23, 12}, win = 1},
	[84] = {cards1 = {130, 131, 132, 133, 123}, cards2 = {10, 11, 12, 13, 101}, win = 1},
	[85] = {cards1 = {10, 11, 12, 13, 20}, cards2 = {130, 131, 132, 133, 120}, win = 2},
	[86] = {cards1 = {10, 11, 12, 13, 30}, cards2 = {120, 121, 122, 123, 111}, win = 2},
	[87] = {cards1 = {10, 11, 12, 13, 41}, cards2 = {110, 111, 112, 113, 102}, win = 2},
	[88] = {cards1 = {10, 11, 12, 13, 53}, cards2 = {100, 101, 102, 103, 93}, win = 2},
	[89] = {cards1 = {10, 11, 12, 13, 62}, cards2 = {90, 91, 92, 93, 80}, win = 2},
	[90] = {cards1 = {10, 11, 12, 13, 73}, cards2 = {80, 81, 82, 83, 70}, win = 2},
	[91] = {cards1 = {10, 11, 12, 13, 81}, cards2 = {70, 71, 72, 73, 62}, win = 2},
	[92] = {cards1 = {10, 11, 12, 13, 92}, cards2 = {60, 61, 62, 63, 52}, win = 2},
	[93] = {cards1 = {10, 11, 12, 13, 103}, cards2 = {50, 51, 52, 53, 43}, win = 2},
	[94] = {cards1 = {10, 11, 12, 13, 112}, cards2 = {40, 41, 42, 43, 50}, win = 2},
	[95] = {cards1 = {10, 11, 12, 13, 121}, cards2 = {30, 31, 32, 33, 61}, win = 2},
	[96] = {cards1 = {10, 11, 12, 13, 133}, cards2 = {20, 21, 22, 23, 73}, win = 2},
	[97] = {cards1 = {130, 131, 132, 120, 121}, cards2 = {120, 121, 122, 111, 112}, win = 1},
	[98] = {cards1 = {120, 121, 123, 111, 113}, cards2 = {111, 112, 113, 100, 103}, win = 1},
	[99] = {cards1 = {112, 111, 113, 101, 102}, cards2 = {100, 101, 102, 90, 93}, win = 1},
	[100] = {cards1 = {100, 101, 102, 83, 80}, cards2 = {90, 91, 92, 81, 82}, win = 1},
	[101] = {cards1 = {91, 92, 93, 71, 72}, cards2 = {80, 81, 82, 73, 70}, win = 1},
	[102] = {cards1 = {80, 81, 83, 91, 93}, cards2 = {72, 73, 71, 60, 61}, win = 1},
	[103] = {cards1 = {72, 71, 70, 90, 92}, cards2 = {60, 61, 63, 52, 53}, win = 1},
	[104] = {cards1 = {51, 52, 53, 100, 101}, cards2 = {40, 41, 42, 30, 33}, win = 1},
	[105] = {cards1 = {62, 61, 63, 112, 111}, cards2 = {50, 51, 53, 131, 132}, win = 1},
	[106] = {cards1 = {40, 43, 41, 80, 81}, cards2 = {32, 33, 31, 111, 112}, win = 1},
	[107] = {cards1 = {30, 31, 32, 120, 121}, cards2 = {20, 21, 22, 111, 112}, win = 1},
	[108] = {cards1 = {20, 22, 23, 60, 61}, cards2 = {10, 11, 12, 51, 52}, win = 1},
	[109] = {cards1 = {10, 11, 12, 131, 133}, cards2 = {130, 131, 132, 120, 121}, win = 2},
	[110] = {cards1 = {21, 22, 23, 11, 13}, cards2 = {120, 121, 123, 111, 112}, win = 2},
	[111] = {cards1 = {30, 31, 32, 22, 23}, cards2 = {111, 112, 113, 100, 103}, win = 2},
	[112] = {cards1 = {41, 42, 43, 30, 33}, cards2 = {100, 102, 103, 90, 91}, win = 2},
	[113] = {cards1 = {51, 52, 53, 40, 41}, cards2 = {90, 91, 92, 82, 83}, win = 2},
	[114] = {cards1 = {60, 61, 63, 52, 51}, cards2 = {81, 82, 83, 70, 71}, win = 2},
	[115] = {cards1 = {72, 73, 71, 60, 61}, cards2 = {131, 133, 132, 110, 111}, win = 2},
	[116] = {cards1 = {130, 120, 110, 100, 70}, cards2 = {121, 111, 101, 81, 71}, win = 1},
	[117] = {cards1 = {122, 112, 102, 82, 72}, cards2 = {113, 93, 63, 53, 43}, win = 1},
	[118] = {cards1 = {112, 92, 62, 52, 42}, cards2 = {103, 43, 63, 73, 83}, win = 1},
	[119] = {cards1 = {102, 42, 62, 72, 82}, cards2 = {90, 40, 20, 10, 30}, win = 1},
	[120] = {cards1 = {93, 43, 23, 13, 33}, cards2 = {81, 61, 51, 41, 31}, win = 1},
	[121] = {cards1 = {82, 62, 52, 12, 32}, cards2 = {73, 43, 33, 53, 13}, win = 1},
	[122] = {cards1 = {70, 40, 30, 50, 10}, cards2 = {62, 52, 42, 42, 12}, win = 1},
	[123] = {cards1 = {63, 53, 43, 33, 13}, cards2 = {130, 120, 110, 100, 70}, win = 2},
	[124] = {cards1 = {72, 42, 22, 52, 12}, cards2 = {121, 111, 101, 81, 71}, win = 2},
	[125] = {cards1 = {81, 61, 51, 41, 31}, cards2 = {112, 92, 62, 52, 42}, win = 2},
	[126] = {cards1 = {90, 40, 20, 10, 50}, cards2 = {103, 43, 63, 73, 83}, win = 2},
	[127] = {cards1 = {133, 123, 110, 101, 92}, cards2 = {120, 110, 100, 90, 83}, win = 1},
	[128] = {cards1 = {121, 112, 103, 92, 82}, cards2 = {111, 103, 93, 83, 71}, win = 1},
	[129] = {cards1 = {110, 103, 92, 82, 72}, cards2 = {93, 81, 71, 63, 50}, win = 1},
	[130] = {cards1 = {92, 80, 71, 61, 52}, cards2 = {80, 70, 60, 50, 43}, win = 1},
	[131] = {cards1 = {80, 70, 60, 51, 40}, cards2 = {71, 61, 52, 43, 32}, win = 1},
	[132] = {cards1 = {73, 62, 51, 43, 30}, cards2 = {62, 52, 42, 32, 20}, win = 1},
	[133] = {cards1 = {60, 51, 43, 31, 22}, cards2 = {42, 30, 22, 12, 130}, win = 1},
	[134] = {cards1 = {40, 30, 22, 21, 131}, cards2 = {132, 122, 110, 101, 92}, win = 2},
	[135] = {cards1 = {52, 42, 32, 22, 13}, cards2 = {120, 110, 100, 91, 83}, win = 2},
	[136] = {cards1 = {63, 52, 42, 32, 21}, cards2 = {103, 93, 81, 73, 60}, win = 2},
	[137] = {cards1 = {71, 61, 52, 43, 32}, cards2 = {93, 82, 72, 62, 52}, win = 2},
	[138] = {cards1 = {80, 70, 60, 51, 40}, cards2 = {130, 121, 110, 101, 92}, win = 2},
	[139] = {cards1 = {130, 131, 132, 121, 113}, cards2 = {120, 121, 122, 50, 80}, win = 1},
	[140] = {cards1 = {121, 122, 123, 60, 83}, cards2 = {111, 112, 113, 23, 43}, win = 1},
	[141] = {cards1 = {110, 111, 112, 40, 60}, cards2 = {100, 103, 102, 131, 11}, win = 1},
	[142] = {cards1 = {101, 102, 103, 30, 23}, cards2 = {91, 92, 93, 51, 73}, win = 1},
	[143] = {cards1 = {93, 91, 90, 100, 113}, cards2 = {80, 81, 82, 101, 112}, win = 1},
	[144] = {cards1 = {81, 82, 83, 112, 122}, cards2 = {70, 71, 73, 92, 102}, win = 1},
	[145] = {cards1 = {70, 71, 72, 90, 81}, cards2 = {63, 62, 60, 73, 81}, win = 1},
	[146] = {cards1 = {61, 60, 62, 30, 23}, cards2 = {51, 52, 50, 41, 90}, win = 1},
	[147] = {cards1 = {53, 51, 50, 130, 33}, cards2 = {40, 42, 43, 90, 73}, win = 1},
	[148] = {cards1 = {41, 42, 43, 71, 83}, cards2 = {31, 32, 33, 72, 61}, win = 1},
	[149] = {cards1 = {30, 32, 33, 50, 63}, cards2 = {20, 22, 23, 91, 82}, win = 1},
	[150] = {cards1 = {21, 22, 23, 41, 90}, cards2 = {11, 12, 13, 102, 111}, win = 1},
	[151] = {cards1 = {10, 12, 13, 132, 100}, cards2 = {130, 131, 133, 110, 102}, win = 2},
	[152] = {cards1 = {20, 21, 23, 91, 82}, cards2 = {122, 121, 123, 113, 101}, win = 2},
	[153] = {cards1 = {31, 32, 33, 72, 61}, cards2 = {111, 112, 113, 53, 73}, win = 2},
	[154] = {cards1 = {40, 41, 43, 53, 63}, cards2 = {100, 103, 101, 132, 12}, win = 2},
	[155] = {cards1 = {51, 53, 50, 33, 21}, cards2 = {92, 90, 93, 50, 72}, win = 2},
	[156] = {cards1 = {61, 60, 62, 93, 120}, cards2 = {80, 81, 83, 112, 122}, win = 2},
	[157] = {cards1 = {70, 72, 71, 12, 110}, cards2 = {130, 131, 132, 90, 102}, win = 2},
	[158] = {cards1 = {130, 133, 121, 122, 12}, cards2 = {110, 111, 101, 102, 21}, win = 1},
	[159] = {cards1 = {112, 113, 101, 103, 32}, cards2 = {93, 91, 81, 82, 33}, win = 1},
	[160] = {cards1 = {72, 73, 60, 61, 43}, cards2 = {53, 51, 42, 43, 62}, win = 1},
	[161] = {cards1 = {90, 93, 83, 82, 12}, cards2 = {70, 71, 62, 61, 103}, win = 1},
	[162] = {cards1 = {53, 52, 40, 43, 110}, cards2 = {30, 31, 22, 23, 73}, win = 1},
	[163] = {cards1 = {33, 32, 20, 21, 73}, cards2 = {21, 22, 10, 11, 50}, win = 1},
	[164] = {cards1 = {132, 131, 120, 123, 63}, cards2 = {120, 121, 103, 101, 33}, win = 1},
	[165] = {cards1 = {23, 20, 13, 12, 70}, cards2 = {133, 132, 123, 120, 62}, win = 2},
	[166] = {cards1 = {33, 32, 23, 21, 92}, cards2 = {121, 120, 101, 102, 133}, win = 2},
	[167] = {cards1 = {53, 50, 40, 43, 32}, cards2 = {110, 112, 103, 100, 21}, win = 2},
	[168] = {cards1 = {72, 73, 63, 62, 42}, cards2 = {90, 92, 82, 83, 33}, win = 2},
	[169] = {cards1 = {130, 131, 120, 110, 100}, cards2 = {123, 122, 61, 81, 73}, win = 1},
	[170] = {cards1 = {123, 120, 30, 20, 10}, cards2 = {111, 112, 31, 43, 52}, win = 1},
	[171] = {cards1 = {113, 110, 20, 10, 60}, cards2 = {103, 100, 91, 81, 71}, win = 1},
	[172] = {cards1 = {102, 101, 51, 61, 91}, cards2 = {90, 93, 123, 113, 80}, win = 1},
	[173] = {cards1 = {92, 91, 100, 12, 63}, cards2 = {82, 83, 102, 112, 73}, win = 1},
	[174] = {cards1 = {80, 81, 103, 113, 90}, cards2 = {70, 72, 62, 50, 41}, win = 1},
	[175] = {cards1 = {71, 73, 50, 100, 93}, cards2 = {63, 62, 132, 121, 101}, win = 1},
	[176] = {cards1 = {60, 61, 21, 32, 41}, cards2 = {50, 52, 130, 40, 12}, win = 1},
	[177] = {cards1 = {51, 53, 90, 82, 101}, cards2 = {42, 43, 92, 112, 102}, win = 1},
	[178] = {cards1 = {40, 41, 80, 53, 112}, cards2 = {33, 32, 43, 52, 60}, win = 1},
	[179] = {cards1 = {30, 31, 13, 21, 72}, cards2 = {13, 12, 131, 120, 110}, win = 1},
	[180] = {cards1 = {11, 10, 101, 70, 80}, cards2 = {131, 132, 112, 80, 73}, win = 2},
	[181] = {cards1 = {33, 32, 42, 70, 82}, cards2 = {120, 122, 62, 51, 92}, win = 2},
	[182] = {cards1 = {40, 41, 93, 113, 122}, cards2 = {110, 112, 31, 52, 63}, win = 2},
	[183] = {cards1 = {50, 52, 131, 61, 12}, cards2 = {102, 100, 32, 41, 50}, win = 2},
	[184] = {cards1 = {61, 62, 133, 120, 101}, cards2 = {91, 92, 122, 113, 71}, win = 2},
	[185] = {cards1 = {70, 72, 62, 50, 42}, cards2 = {80, 81, 102, 90, 122}, win = 2},
	[186] = {cards1 = {130, 120, 110, 100, 83}, cards2 = {121, 111, 101, 72, 82}, win = 1},
	[187] = {cards1 = {120, 112, 103, 10, 30}, cards2 = {113, 103, 91, 83, 72}, win = 2},
	[188] = {cards1 = {111, 110, 20, 33, 10}, cards2 = {101, 92, 83, 70, 42}, win = 1},
	[189] = {cards1 = {103, 91, 83, 70, 40}, cards2 = {93, 83, 73, 63, 21}, win = 1},
	[190] = {cards1 = {90, 62, 52, 41, 20}, cards2 = {80, 51, 42, 33, 13}, win = 1},
	[191] = {cards1 = {82, 72, 33, 22, 43}, cards2 = {71, 63, 51, 42, 13}, win = 1},
	[192] = {cards1 = {72, 12, 23, 33, 51}, cards2 = {62, 53, 41, 30, 10}, win = 1},
	[193] = {cards1 = {60, 12, 23, 33, 53}, cards2 = {133, 122, 112, 102, 81}, win = 2},
	[194] = {cards1 = {71, 63, 52, 41, 12}, cards2 = {120, 111, 101, 72, 81}, win = 2},
	[195] = {cards1 = {83, 50, 73, 32, 22}, cards2 = {113, 103, 192, 82, 71}, win = 2},
	[196] = {cards1 = {92, 81, 71, 60, 23}, cards2 = {102, 90, 80, 70, 40}, win = 2},
	[197] = {cards1 = {131, 11, 21, 31, 41}, cards2 = {13, 12, 11, 22, 23}, win = 1},
	[198] = {cards1 = {10, 11, 12, 13, 20}, cards2 = {20, 31, 41, 51, 73}, win = 1},
	[199] = {cards1 = {13, 12, 11, 22, 23}, cards2 = {130, 11, 22, 33, 40}, win = 1},
	[200] = {cards1 = {10, 11, 12, 20, 31}, cards2 = {20, 31, 41, 51, 73}, win = 1},
	[201] = {cards1 = {11, 12, 21, 22, 33}, cards2 = {10, 13, 20, 31, 42}, win = 1},
	[202] = {cards1 = {20, 31, 41, 51, 73}, cards2 = {12, 13, 20, 31, 42}, win = 2},
	[203] = {cards1 = {12, 13, 20, 31, 42}, cards2 = {11, 12, 21, 22, 33}, win = 2},
	[204] = {cards1 = {10, 11, 12, 20, 31}, cards2 = {130, 13, 22, 32, 43}, win = 2},
	[205] = {cards1 = {131, 10, 21, 30, 42}, cards2 = {13, 11, 12, 23, 20}, win = 2},
	[206] = {cards1 = {13, 11, 12, 23, 22}, cards2 = {130, 10, 20, 30, 40}, win = 2},
	[207] = {cards1 = {23, 32, 42, 52, 71}, cards2 = {10, 11, 12, 13, 80}, win = 2},
	[208] = {cards1 = {11, 10, 13, 120, 122}, cards2 = {12, 10, 13, 121, 122}, win = -1},
	[209] = {cards1 = {130, 132, 133, 71, 70}, cards2 = {131, 132, 133, 73, 71}, win = -1},
	[210] = {cards1 = {100, 102, 103, 113, 110}, cards2 = {101, 102, 103, 112, 110}, win = -1},
	[211] = {cards1 = {50, 53, 52, 130, 133}, cards2 = {51, 53, 52, 131, 133}, win = -1},
	[212] = {cards1 = {130, 121, 110, 101, 93}, cards2 = {131, 120, 110, 101, 93}, win = -1},
	[213] = {cards1 = {40, 33, 22, 12, 131}, cards2 = {42, 31, 22, 12, 131}, win = -1},
	[214] = {cards1 = {83, 70, 60, 52, 43}, cards2 = {82, 72, 60, 52, 43}, win = -1},
	[215] = {cards1 = {113, 101, 93, 82, 70}, cards2 = {112, 102, 93, 82, 70}, win = -1},
	[216] = {cards1 = {120, 112, 123, 121, 100}, cards2 = {122, 110, 123, 121, 100}, win = -1},
	[217] = {cards1 = {10, 111, 12, 11, 101}, cards2 = {13, 113, 12, 11, 101}, win = -1},
	[218] = {cards1 = {62, 71, 63, 61, 93}, cards2 = {60, 72, 63, 61, 93}, win = -1},
	[219] = {cards1 = {113, 20, 110, 111, 43}, cards2 = {112, 21, 110, 111, 43}, win = -1},
	[220] = {cards1 = {130, 12, 132, 120, 121}, cards2 = {131, 11, 132, 120, 121}, win = -1},
	[221] = {cards1 = {90, 92, 80, 81, 130}, cards2 = {91, 93, 80, 81, 130}, win = -1},
	[222] = {cards1 = {21, 22, 13, 12, 121}, cards2 = {23, 20, 13, 12, 121}, win = -1},
	[223] = {cards1 = {73, 60, 71, 63, 90}, cards2 = {70, 61, 71, 63, 90}, win = -1},
	[224] = {cards1 = {110, 103, 112, 131, 80}, cards2 = {113, 103, 111, 131, 80}, win = -1},
	[225] = {cards1 = {90, 80, 91, 100, 31}, cards2 = {92, 83, 91, 100, 31}, win = -1},
	[226] = {cards1 = {10, 11, 130, 123, 113}, cards2 = {12, 13, 130, 123, 113}, win = -1},
	[227] = {cards1 = {70, 83, 131, 120, 100}, cards2 = {72, 82, 131, 120, 100}, win = -1},
	[228] = {cards1 = {91, 101, 121, 83, 72}, cards2 = {93, 103, 121, 83, 72}, win = -1},
	[229] = {cards1 = {41, 83, 50, 13, 60}, cards2 = {43, 82, 50, 13, 60}, win = -1},
}

return test