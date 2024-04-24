-define(DEFAULT_SIZE, 128).
-record(matrix, {
    pixels = #{} :: #{{non_neg_integer(), non_neg_integer()} => non_neg_integer()},
    width = ?DEFAULT_SIZE :: non_neg_integer(),
    height = ?DEFAULT_SIZE :: non_neg_integer()
}).