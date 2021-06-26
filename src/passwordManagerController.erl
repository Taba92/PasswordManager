-module(passwordManagerController).
-export([init/0, init/1]).
-export([handle_info/2, handle_call/3]).
-define(LOW(String),string:to_lower(String)).
-record(state,{username,password,vi,window,database}).

init()->gen_server:start_link({local,passwordManagerController},?MODULE,[],[]).
init([])->
    wx:new(),
    State = #state{},
    {ok,State}.

handle_info({wx,0,_,_,_},State)->
    #state{database = Dets} = State,
    dets:close(Dets),
	init:stop(),
    {noreply,State};
handle_info({wx,7,_,{ServiceBox,UserNameBox,PasswordBox},_},State)->
    #state{password = Pwd, vi = VI, database = Dets} = State,
	Service=wxTextCtrl:getValue(ServiceBox),
	case Service=="" of
		false->case passwordManagerService:get(Dets,?LOW(Service)) of
					{EncUser,EncPass}->
						wxTextCtrl:setValue(UserNameBox,passwordManagerService:decrypt(VI,Pwd,EncUser)),
						wxTextCtrl:setValue(PasswordBox,passwordManagerService:decrypt(VI,Pwd,EncPass));
					Msg->showMsg(Msg)
				end;
		true->
			showMsg("INSERIRE IL NOME DEL SERVIZIO")
	end,
    {noreply,State};
handle_info({wx,8,_,{ServicesBox,ServiceBox,UserNameBox,PasswordBox},_},State)->
    #state{password = Pwd, vi = VI, database = Dets} = State,
	{Service,UserName,Password}={wxTextCtrl:getValue(ServiceBox),wxTextCtrl:getValue(UserNameBox),wxTextCtrl:getValue(PasswordBox)},
	case (Service=="")or(UserName=="")or(Password=="") of
		false->
			{EncUser,EncPassword}={passwordManagerService:encrypt(VI,Pwd,UserName),passwordManagerService:encrypt(VI,Pwd,Password)},
			Msg=passwordManagerService:save(Dets,?LOW(Service),EncUser,EncPassword),
			showMsg(Msg);
		true->
			showMsg("CONTROLLARE CHE LE TRE TEXTBOX NON SIANO VUOTE!")
	end,
	wxTextCtrl:setValue(ServicesBox,passwordManagerService:getServices(Dets)),
    {noreply,State};
handle_info({wx,9,_,{ServicesBox,ServiceBox},_},State)->
    #state{database = Dets} = State,
	Service=wxTextCtrl:getValue(ServiceBox),
	case Service=="" of
		false->
			Msg=passwordManagerService:delete(Dets,?LOW(Service)),
			showMsg(Msg);
		true->
			showMsg("INSERIRE IL NOME DEL SERVIZIO")
	end,
	wxTextCtrl:setValue(ServicesBox,passwordManagerService:getServices(Dets)),
    {noreply,State};
handle_info({wx,10,_,{ServiceBox,PasswordBox},_},State)->
    #state{password = Pwd , vi = VI, database = Dets} = State,
	{Service,NewPassword}={wxTextCtrl:getValue(ServiceBox),wxTextCtrl:getValue(PasswordBox)},
	case (Service=="") or (NewPassword=="") of
		false->
			Msg=passwordManagerService:modify(Dets,Service,passwordManagerService:encrypt(VI,Pwd,NewPassword)),
			showMsg(Msg);
		true->
			showMsg("CONTROLLARE CHE SERVIZIO E PASSWORD NON SIANO VUOTI!")
	end,
	{noreply,State}.

handle_call({onloginok,Name,VI,Pwd},_,State)->
    Database = passwordManagerService:open_database(Name),
    Window = passwordManagerGraphic:getInitialFrame(Database),
    NewState = State#state{username = Name, password = Pwd, vi = VI, window = Window, database = Database},
    wxFrame:show(Window),
    {reply,ok,NewState};
handle_call({oncredentialchangeok,Name,NewName,VI,Pwd,NewPwd},_,State)->
    Database = passwordManagerService:open_database(Name),
    passwordManagerService:recipherDb(Database,VI,Pwd,NewPwd),
    passwordManagerService:changeDatabaseName(Name,NewName),
    dets:close(Database),
    {reply,ok,State}.
showMsg(Msg)->
	wxMessageDialog:showModal(wxMessageDialog:new(wx:null(),Msg)).