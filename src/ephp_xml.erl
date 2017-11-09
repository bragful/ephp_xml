-module(ephp_xml).
-author('manuel@altenwald.com').
-compile([warnings_as_errors]).

-include_lib("ephp/include/ephp.hrl").

-export([main/1]).

-spec main(Args :: [string()]) -> integer().
%% @doc this function is here to generate the script for this project.
main(Args) ->
    ephp:main(Args).
