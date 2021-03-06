%%%-------------------------------------------------------------------
%%% Part of rebar3_warn_outdated_deps Erlang App
%%% MIT License
%%% Copyright (c) 2021 Jose Maria Perez Ramos
%%%-------------------------------------------------------------------
-module(rebar3_warn_outdated_deps).

%% API
-export([
         init/1,
         do/1,
         format_error/1
        ]).

-define(PROVIDER, warn_outdated_deps).
-define(DEPS, [lock]).


%%====================================================================
%% API functions
%%====================================================================

-spec init(rebar_state:t()) -> {ok, rebar_state:t()}.
init(State) ->
    Provider = providers:create([
            {name, ?PROVIDER},            % The 'user friendly' name of the task
            {module, ?MODULE},            % The module implementation of the task
            {bare, true},                 % The task can be run by the user, always true
            {deps, ?DEPS},                % The list of dependencies
            {example, "rebar3 warn_outdated_deps"}, % How to use the plugin
            {opts, [                      % list of options understood by the plugin
                    {abort_on_mismatch, $a, "abort_on_mismatch", boolean, "Abort if a mismatch is found. Default: false"}
                   ]},
            {short_desc, "Warns when a locked dep needs to be updated to match rebar.config"},
            {desc,       "Warns when a locked dep needs to be updated to match rebar.config"}
    ]),
    {ok, StateWithLockWarnAbortCommand} = rebar3_warn_outdated_deps_abort:init(State),
    {ok, rebar_state:add_provider(StateWithLockWarnAbortCommand, Provider)}.

-spec do(rebar_state:t()) -> {ok, rebar_state:t()} | {error, string()}.
do(State) ->
    {Args, _} = rebar_state:command_parsed_args(State),
    case proplists:get_value(abort_on_mismatch, Args, false) of
        true ->
            rebar3_warn_outdated_deps_abort:do(State);
        _ ->
            rebar3_warn_outdated_deps_common:report(State),
            {ok, State}
    end.

-spec format_error(any()) ->  iolist().
format_error(Reason) ->
    io_lib:format("~p", [Reason]).

