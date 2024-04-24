-module(pixelwar_sup).

-behaviour(supervisor).
-define(DEFAULT_SIZE, 128).
%% API
-export([start_link/0]).
-export([init/1]).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init(_Args) ->
    SupervisorSpecification = #{
        % one_for_one | one_for_all | rest_for_one | simple_one_for_one
        strategy => one_for_one,
        intensity => 10,
        period => 60
    },

    Width =
        case application:get_env(pixelwar, matrix_width) of
            {ok, Vw} -> Vw;
            undefined -> ?DEFAULT_SIZE
        end,
    Height =
        case application:get_env(pixelwar, matrix_height) of
            {ok, Vh} -> Vh;
            undefined -> ?DEFAULT_SIZE
        end,

    ChildSpecifications = [
        #{
            id => matrix,
            start => {pixelwar_matrix_serv, start_link, [{Width, Height}]},
            % permanent | transient | temporary
            restart => permanent,
            shutdown => 2000,
            % worker | supervisor
            type => worker
        }
    ],

    {ok, {SupervisorSpecification, ChildSpecifications}}.
