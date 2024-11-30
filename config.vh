// 行数
`define ROW_COUNT 6
// 行数を表すビット幅
`define ROW_SIZE $clog2(`ROW_COUNT+1)

// 列数
`define COL_COUNT 7
// 列数を表すビット幅
`define COL_SIZE $clog2(`COL_COUNT+1)

// 行数 x 列数
`define FIELD_SIZE `ROW_COUNT*`COL_COUNT

`define PILE_COUNT_ARRAY_SIZE `ROW_SIZE*`COL_COUNT


/*
* 右シフト時にかけたいマスク
* 1000000
* 1000000
* 1000000
* 1000000
* 1000000
* 1000000
* の反転
*/
`define RIGHT_SHIFT_MASK ~{6{7'b1000000}}


/*
* 左シフト時にかけたいマスク
* 0000001
* 0000001
* 0000001
* 0000001
* 0000001
* 0000001
* の反転
*/
`define LEFT_SHIFT_MASK ~{6{7'b0000001}}

/*
* 右下シフト (右 COL_SIZE + 1 シフト)
* 1000000
* 1000000
* 1000000
* 1000000
* 1000000
* 1000000
* の反転
*/
`define RIGHT_DOWN_SHIFT_MASK ~{6{7'b1000000}}


/*
* 右下シフト (右 COL_SIZE - 1 シフト)
* 0000001
* 0000001
* 0000001
* 0000001
* 0000001
* 0000001
* の反転
*/
`define LEFT_DOWN_SHIFT_MASK ~{6{7'b0000001}}