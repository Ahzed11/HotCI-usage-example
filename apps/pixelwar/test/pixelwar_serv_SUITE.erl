-module(pixelwar_serv_SUITE).
-include_lib("stdlib/include/assert.hrl").
-include_lib("common_test/include/ct.hrl").
-compile(export_all).

all() ->
    [get_state_test_case, place_out_of_bounds_test_case].

init_per_testcase(_Case, Config) ->
    application:load(pixelwar),
    Width = 128,
    Height = 128,
    application:set_env(pixelwar, matrix_width, Width),
    application:set_env(pixelwar, matrix_height, Height),

    {ok, Apps} = application:ensure_all_started([pixelwar]),
    [{apps, Apps}, {width, Width}, {height, Height} | Config].

end_per_testcase(_Case, Config) ->
    [application:stop(App) || App <- lists:reverse(?config(apps, Config))],
    Config.

get_state_test_case() ->
    [
        {doc, "Tries to get the current matrix as binary"},
        {timetrap, timer:seconds(5)}
    ].

get_state_test_case(_Config) ->
    pixelwar_matrix_serv:set_element(matrix, {42, 42, 12}),
    pixelwar_matrix_serv:set_element(matrix, {42, 42, 42}),
    pixelwar_matrix_serv:set_element(matrix, {11, 12, 13}),

    MatrixAsBin = pixelwar_matrix_serv:get_state(matrix),
    ?assertEqual(
        MatrixAsBin,
        <<11:16/little, 12:16/little, 13:16/little, 42:16/little, 42:16/little, 42:16/little>>
    ).

place_out_of_bounds_test_case(Config) ->
    Width = ?config(width, Config),
    Height = ?config(height, Config),

    InboundWidth = Width - 2,
    InboundHeight = Height - 2,

    % In bounds
    pixelwar_matrix_serv:set_element(matrix, {InboundWidth, InboundHeight, 13}),
    % Out of bounds
    pixelwar_matrix_serv:set_element(matrix, {Width + 2, Height + 2, 13}),

    MatrixAsBin = pixelwar_matrix_serv:get_state(matrix),

    ?assertEqual(MatrixAsBin, <<InboundWidth:16/little, InboundHeight:16/little, 13:16/little>>).