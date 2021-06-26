-module(passwordManagerService).
-export([open_database/1,changeDatabaseName/2,recipherDb/4,decrypt/3,encrypt/3,getServices/1,get/2,save/4,delete/2,modify/3]).
-define(BIN(String),list_to_binary(String)).
-define(STR(Bin),binary_to_list(Bin)).
-define(PATHDATABASE,"./priv/Passwords/").
-define(DATABASESUFFIX,"Password").

open_database(Username)->
    DatabaseFileName = ?PATHDATABASE++Username++?DATABASESUFFIX,
    {ok,Dets}=dets:open_file(pwd,[{file,DatabaseFileName},{type,set}]),
    Dets.
get(Dets,Service)->
	case dets:member(Dets,Service) of
		true->
			[{_,EncUser,EncPass}]=dets:lookup(Dets,Service),
			{EncUser,EncPass};
		false->"SERVIZIO NON PRESENTE"
	end.

save(Dets,Service,EncUser,EncPassword)->
	case dets:member(Dets,Service) of
		false->
			dets:insert(Dets,{Service,EncUser,EncPassword}),
			"SERVIZIO REGISTRATO";
		true->"SERVIZIO GIÀ PRESENTE"
	end.

delete(Dets,Service)->
	case dets:member(Dets,Service) of
		true->
			dets:delete(Dets,Service),
			"SERVIZIO CANCELLATO";
		false->"SERVIZIO NON PRESENTE"
	end.

modify(Dets,Service,EncNewPassword)->
	case dets:member(Dets,Service) of
		true->
			[{_,EncUser,_}]=dets:lookup(Dets,Service),
				dets:insert(Dets,{Service,EncUser,EncNewPassword}),
				"CREDENZIALI SERVIZIO AGGIORNATE";
		false->"SERVIZIO NON PRESENTE"
	end.

recipherDb(Dets,VI,OldPwd,NewPwd)->
	Acc={VI,OldPwd,NewPwd,[]},
	{_,_,_,NewObjs}=dets:foldl(fun recipherRd/2,Acc,Dets),
	dets:delete_all_objects(Dets),
	dets:insert(Dets,NewObjs),
	"DATABASE RICIFRATO".

recipherRd({Service,OldEncUser,OldEncPass},{VI,OldPwd,NewPwd,Acc})->
	{Service,User,Password}={Service,decrypt(VI,OldPwd,OldEncUser),decrypt(VI,OldPwd,OldEncPass)},
	{Service,NewEncUser,NewEncPass}={Service,encrypt(VI,NewPwd,User),encrypt(VI,NewPwd,Password)},
	{VI,OldPwd,NewPwd,[{Service,NewEncUser,NewEncPass}|Acc]}.

decrypt(VI,Password,Field)->
	?STR(crypto:crypto_one_time(aes_128_ctr,?BIN(Password),VI,?BIN(Field),true)).
encrypt(VI,Password,Field)->
	?STR(crypto:crypto_one_time(aes_128_ctr,?BIN(Password),VI,?BIN(Field),false)).

getServices(Dets)->
	A=fun({Service,_,_},Acc)->Acc++Service++"\n" end,
	dets:foldl(A,"",Dets).

changeDatabaseName(Name,NewName)->
	DatabaseFileName = ?PATHDATABASE++Name++?DATABASESUFFIX,
	NewDatabaseFileName = ?PATHDATABASE++NewName++?DATABASESUFFIX,
	file:rename(DatabaseFileName,NewDatabaseFileName).