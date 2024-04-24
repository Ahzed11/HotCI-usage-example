-module(pixelwar_matrix).
-include_lib("matrix.hrl").
-export([create/0, create/2, create/3, to_binary/1, set_pixel/4, resize/3]).

create() ->
    Matrix = #matrix{pixels = #{}, width = ?DEFAULT_SIZE, height = ?DEFAULT_SIZE},
    {ok, Matrix}.

create(Width, _Height) when Width =< 0 -> {error, invalid_width};
create(_Width, Height) when Height =< 0 -> {error, invalid_height};
create(Width, Height) ->
    {ok, #matrix{ pixels = #{}, width = Width, height = Height}}.

create(Width, Height, Pixels) ->
    case create(Width, Height) of
        {ok, Matrix} -> {ok, Matrix#matrix{pixels=Pixels}} ;
        Error -> Error
    end.

to_binary(#matrix{} = Matrix) ->
    ToBinary = fun(K, V, Acc) ->
        {X, Y} = K,
        <<Acc/binary, X:16/little, Y:16/little, V:16/little>>
    end,
    maps:fold(ToBinary, <<>>, Matrix#matrix.pixels).

set_pixel(Matrix, X, _Y, _Color) when X >= Matrix#matrix.width orelse X < 0 ->
    {error, invalid_width};

set_pixel(Matrix, _X, Y, _Color) when Y >= Matrix#matrix.height orelse Y < 0 ->
    {error, invalid_height};

set_pixel(Matrix, X, Y, Color) ->
    Key = {X, Y},
    NewPixels = maps:put(Key, Color, Matrix#matrix.pixels),
    NewMatrix = Matrix#matrix{pixels=NewPixels},
    {ok, NewMatrix}.

resize(_Matrix, Width, _Height) when Width =< 0 ->
    {error, invalid_width};

resize(_Matrix, _Width, Height) when Height =< 0 ->
    {error, invalid_height};

resize(Matrix, Width, Height) ->
    IsInBound = fun({X, Y}, _V) -> X < Width andalso X >= 0 andalso Y < Height andalso Y >= 0 end,
    FilteredPixels = maps:filter(IsInBound, Matrix#matrix.pixels),
    NewMatrix = Matrix#matrix{pixels=FilteredPixels, width=Width, height=Height},
    {ok, NewMatrix}.
