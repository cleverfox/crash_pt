-module(crash_pt_test).
-compile([export_all, nowarn_export_all, {parse_transform, crash_pt}, debug]).

test1() ->
  try
    3/0
  catch
    throw:xxx -> xxx;
    Ec:Ee -> CRASH("Can't divideaasssssasa "), x
  end.

%test2() ->
%  try
%    3/0
%  catch
%    throw:xxx -> xxx;
%    Ec:Ee ->
%      Stack=erlang:get_stacktrace(),
%      error_logger:error_msg("Can't divide ~p:~p",[Ec,Ee]),
%      [ error_logger:error_msg("@ ~p",[Where]) ||  Where <- Stack ],
%      x
%  end.

