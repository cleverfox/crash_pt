-module(crash_pt).
-export([parse_transform/2]).
-export([hint/0, replacer/1]).

parse_transform(AST, _Opts) ->
  AST1=replacer(AST),
  error_logger:error_msg("AST0 ~p",[AST]),
  error_logger:error_msg("AST1 ~p",[AST1]),
  AST1.

replacer([]) ->
  [];
replacer([E0|Rest]=All) ->
  [replace(E0)|replacer(Rest)].

replace({function, LINE, Name, Arity, Body}) ->
  {function, LINE, Name, Arity, replacer(Body)};

replace({clause, Line, [{tuple,_,[{var,_,'Ec'},{var,_,'Ee'},_]}]=Match, 
         Where, 
         [{call,_, {var,_,'CRASH'}, [{string,_,Crash_Arg}|_]}|Return]}=Clause) ->
  {clause, Line, Match, Where, 
   [
    code2ast("Stack=erlang:get_stacktrace()."),
    code2ast("error_logger:error_msg(\""++Crash_Arg++" ~p:~p\",[Ec,Ee])."),
    code2ast("[ error_logger:error_msg(\"@ ~p\",[Where]) ||  Where <- Stack ].")
    | Return]};

%{ok,{_,[{abstract_code,{_,AC}}]}} = beam_lib:chunks(crash_pt_test,[abstract_code]).
%erl_prettypr:format(erl_syntax:form_list(AC)).
replace({block, Line, Body}) ->
  {block, Line, replacer(Body)};

replace({'catch', Line, Body}) ->
  {'catch', Line, replacer(Body)};

replace({'case', Line, Rep0, Body}) ->
  {'case', Line, Rep0, replacer(Body)};

replace({clause, Line, Match, Where, Body}) ->
  {clause, Line, Match, Where, replacer(Body)};

replace({'try', LINE, Body, Arg1, Catches, Arg2}=Any) ->
  {'try', LINE, replacer(Body), Arg1, replacer(Catches), Arg2};

replace(Any) ->
  Any.

code2ast(LOC) ->
  {ok, Tokens, _} = erl_scan:string(LOC),
  {ok, [Parsed]} = erl_parse:parse_exprs(Tokens),
  Parsed.
