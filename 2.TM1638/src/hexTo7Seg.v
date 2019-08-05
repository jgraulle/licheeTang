module hexTo7Seg(
		input wire [3:0] HEX,
		input wire DOT,
		output wire [7:0] SEG
	);


	//  AAAA            AAAA    AAAA            AAAA    AAAA    AAAA    AAAA    AAAA    AAAA                            AAAA    AAAA
	// F    B       B       B       B  F    B  F       F            B  F    B  F    B  F    B  F                    B  F       F
	// F    B       B       B       B  F    B  F       F            B  F    B  F    B  F    B  F                    B  F       F
	//                  GGGG    GGGG    GGGG    GGGG    GGGG            GGGG    GGGG    GGGG    GGGG    GGGG    GGGG    GGGG    GGGG
	// E    C       C  E            C       C       C  E    C       C  E    C       C  E    C  E    C  E       E    C  E       E
	// E    C       C  E            C       C       C  E    C       C  E    C       C  E    C  E    C  E       E    C  E       E
	//  DDDD            DDDD    DDDD            DDDD    DDDD            DDDD    DDDD            DDDD    DDDD    DDDD    DDDD

	assign a = HEX[3];
	assign b = HEX[2];
	assign c = HEX[1];
	assign d = HEX[0];

	// Segment A
	// 0 || 2 || 3 || 5 || 6 || 7 || 8 || 9 || A || E || F
	// 0000    || 0010   || 0011  || 0101  || 0110  || 0111 || 1000   || 1001  || 1010  || 1110 || 1111
	// !a!b!c!d + !a!bc!d + !a!bcd + !ab!cd + !abc!d + !abcd + a!b!c!d + a!b!cd + a!bc!d + abc!d + abcd
	assign SEG[0] = (a && ! b && ! c) || (! a && b && d) || (! a && c) || (b && c) || (! b && ! d);

	// Segment B
	// 0 || 1 || 2 || 3 || 4 || 7 || 8 || 9 || A || D
	// 0000    || 0001   || 0010   || 0011  || 0100   || 0111 || 1000   || 1001  || 1010  || 1101
	// !a!b!c!d + !a!b!cd + !a!bc!d + !a!bcd + !ab!c!d + !abcd + a!b!c!d + a!b!cd + a!bc!d + ab!cd
	assign SEG[1] = (a && ! c && d) || (! a && ! b) || (! a && c && d) || (! a && ! c && ! d) || (! b && ! d);

	// Segment C
	// 0 || 1 || 3 || 4 || 5 || 6 || 7 || 8 || 9 || A || B || D
	// 0000    || 0001   || 0011  || 0100   || 0101  || 0110  || 0111 || 1000   || 1001  || 1010  || 1011 || 1101
	// !a!b!c!d + !a!b!cd + !a!bcd + !ab!c!d + !ab!cd + !abc!d + !abcd + a!b!c!d + a!b!cd + a!bc!d + a!bcd + ab!cd
	assign SEG[2] = (a && ! b) || (! a && b) || (! a && ! c) || (! a && d) || (! c && d);

	// Segment D
	// 0 || 2 || 3 || 5 || 6 || 8 || 9 || B || C || D || E
	// 0000    || 0010   || 0011  || 0101  || 0110  || 1000   || 1001  || 1011 || 1100  || 1101 || 1110
	// !a!b!c!d + !a!bc!d + !a!bcd + !ab!cd + !abc!d + a!b!c!d + a!b!cd + a!bcd + ab!c!d + ab!cd + abc!d
	assign SEG[3] = (a && ! c) || (! a && ! b && ! d) || (b && c && ! d) || (b && ! c && d) || (! b && c && d);

	// Segment E
	// 0 || 2 || 6 || 8 || A || B || C || D || E || F
	// 0000    || 0010   || 0110  || 1000   || 1010  || 1011 || 1100  || 1101 || 1110 || 1111
	// !a!b!c!d + !a!bc!d + !abc!d + a!b!c!d + a!bc!d + a!bcd + ab!c!d + ab!cd + abc!d + abcd
	assign SEG[4] = (a && b) || (a && c) || (! b && ! d) || (c && ! d);

	// Segment F
	// 0 || 4 || 5 || 6 || 8 || 9 || A || B || E || F
	// 0000    || 0100   || 0101  || 0110  || 1000   || 1001  || 1010  || 1011 || 1110 || 1111
	// !a!b!c!d + !ab!c!d + !ab!cd + !abc!d + a!b!c!d + a!b!cd + a!bc!d + a!bcd + abc!d + abcd
	assign SEG[5] = (a && ! b) || (a && c) || (! a && b && ! c) || (! a && b && ! d) || (! a && ! c && ! d);

	// Segment G
	// 2 || 3 || 4 || 5 || 6 || 8 || 9 || A || B || C || D || E || F
	// 0010   || 0011  || 0100   || 0101  || 0110  || 1000   || 1001   || 1010  || 1011 || 1100  || 1101 || 1110 || 1111
	// !a!bc!d + !a!bcd + !ab!c!d + !ab!cd + !abc!d + a!b!c!d + a!b!cd + a!bc!d + a!bcd + ab!c!d + ab!cd + abc!d + abcd
	assign SEG[6] = a || (b && ! c) || (b && ! d) || (! b && c);

	// Segment dot
	assign SEG[7] = DOT;

endmodule
