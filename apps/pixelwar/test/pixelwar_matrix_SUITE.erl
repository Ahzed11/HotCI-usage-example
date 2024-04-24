-module(pixelwar_matrix_SUITE).
-include_lib("stdlib/include/assert.hrl").
-include_lib("common_test/include/ct.hrl").
-include_lib("apps/pixelwar/src/matrix.hrl").
-compile(export_all).

all() ->
    [
        create_invalid_size_matrix_test_case,
        create_matrix_with_pixels_test_case,
        matrix_to_binary_test_case,
        set_pixel_invalid_location_test_case,
        resize_matrix_test_case
    ].

create_invalid_size_matrix_test_case() ->
    [
        {doc, "Tries to create a matrix with an invalid width"},
        {timetrap, timer:seconds(5)}
    ].
create_invalid_size_matrix_test_case(_Config) ->
    {error, invalid_width} = pixelwar_matrix:create(-2, 100),
    {error, invalid_height} = pixelwar_matrix:create(100, -2).


create_matrix_with_pixels_test_case() ->
    [
        {doc, "Tries to create a matrix with already created pixels"},
        {timetrap, timer:seconds(5)}
    ].
create_matrix_with_pixels_test_case(_Config) ->
    Pixels = #{{42,42} => 1, {11, 11} => 2},
    {ok, Matrix} = pixelwar_matrix:create(100, 100, Pixels),
    Pixels =:= Matrix#matrix.pixels.

matrix_to_binary_test_case() ->
    [
        {doc, "Tries to represent the pixels of a matrix as binary"},
        {timetrap, timer:seconds(5)}
    ].
matrix_to_binary_test_case(_Config) ->
    Pixels = #{{42,42} => 42, {11, 12} => 13},
    {ok, Matrix} = pixelwar_matrix:create(100, 100, Pixels),
    Bin = pixelwar_matrix:to_binary(Matrix),
    ?assertEqual(
        Bin,
        <<11:16/little, 12:16/little, 13:16/little, 42:16/little, 42:16/little, 42:16/little>>
    ).

set_pixel_invalid_location_test_case() ->
    [
        {doc, "Tries to place a pixel at an invalid location with an invalid height"},
        {timetrap, timer:seconds(5)}
    ].
set_pixel_invalid_location_test_case(_config) ->
    {ok, Matrix} = pixelwar_matrix:create(),
    {error, invalid_width} = pixelwar_matrix:set_pixel(Matrix, -2, 10, 12),
    {error, invalid_width} = pixelwar_matrix:set_pixel(Matrix, 200, 10, 12),
    {error, invalid_height} = pixelwar_matrix:set_pixel(Matrix, 10, -2, 12),
    {error, invalid_height} = pixelwar_matrix:set_pixel(Matrix, 10, 200, 12).

resize_matrix_test_case() ->
    [
        {doc, "Tries to resize the matrix"},
        {timetrap, timer:seconds(5)}
    ].
resize_matrix_test_case(_Config) ->
    {ok, Start} = pixelwar_matrix:create(),
    {ok, Modified} = pixelwar_matrix:set_pixel(Start, 42, 42, 42),
    {ok, ModifiedTwice} = pixelwar_matrix:set_pixel(Modified, 11, 12, 13),
    {error, invalid_width} = pixelwar_matrix:resize(ModifiedTwice, 0, 100),
    {error, invalid_width} = pixelwar_matrix:resize(ModifiedTwice, -1, 100),
    {error, invalid_height} = pixelwar_matrix:resize(ModifiedTwice, 100, 0),
    {error, invalid_height} = pixelwar_matrix:resize(ModifiedTwice, 100, -1),
    {ok, Resized} = pixelwar_matrix:resize(ModifiedTwice, 21, 22),
    ?assertEqual(
        #{{11, 12} => 13},
        Resized#matrix.pixels
    ),
    ?assertEqual(
        21,
        Resized#matrix.width
    ),
    ?assertEqual(
        22,
        Resized#matrix.height
    ).

    