-module(hexer).

-export([main/1]).

-spec main([string()]) -> ok.
main(Args) ->
  {ok, _} = application:ensure_all_started(hexer),
  OptSpecList = hexer_options:option_spec_list(),
  case getopt:parse(OptSpecList, Args) of
    {ok, {[], []}} ->
      hexer_options:help();
    {ok, {Options, Commands}} ->
      try
        AtomCommands = [list_to_atom(Cmd) || Cmd <- Commands],
        process(hexer_options, Options),
        process(hexer_commands, AtomCommands),
        ok
      catch
        _:Reason ->
          hexer_utils:error(Reason),
          hexer_utils:error(erlang:get_stacktrace())
      end;
    {error, Error} ->
      hexer_utils:error(Error),
      hexer_options:help()
  end.

-type option() :: {atom(), any()} | atom().
-type command() :: atom().

-spec process(module(), [option() | command()] | option() | command()) -> ok.
process(Module, Items) when is_list(Items) ->
  [process(Module, Item) || Item <- Items];
process(Module, {Name, Arg}) ->
  Module:Name(Arg);
process(Module, Name) ->
  Module:Name().
