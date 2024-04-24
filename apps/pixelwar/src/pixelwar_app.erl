%%%-------------------------------------------------------------------
%% @doc pixelwar public API
%% @end
%%%-------------------------------------------------------------------

-module(pixelwar_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    pixelwar_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
