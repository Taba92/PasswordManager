-module(passwordManager_app).
-behaviour(application).
-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    application:start(loginWindow),
    Listeners = #{onLoginOk => [passwordManagerController], onCredentialChange => [passwordManagerController]},
    gen_server:call(userLoginController,{set_listeners,Listeners}),
    passwordManagerController:init().

stop(_State) ->
    ok.

%% internal functions
