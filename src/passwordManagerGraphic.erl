-module(passwordManagerGraphic).
-export([getInitialFrame/1]).
-include_lib("wx/include/wx.hrl").

getInitialFrame(Dets)->
	Frame=wxFrame:new(wx:null(),0,"PASSWORD MANAGER"),
	wxFrame:connect(Frame, close_window, [{skip, true}]),%%quando schiacchio sulla chiusura finestra,fermo tutto il sistema|
	wxStaticText:new(Frame,1,"Nome servizio",[{pos,{20,30}}]),
	Service=wxTextCtrl:new(Frame,2,[{pos,{150, 30}}]),
	wxTextCtrl:setSize(Service,210,37),
	wxStaticText:new(Frame,3,"Username servizio",[{pos,{20,80}}]),
	UserName=wxTextCtrl:new(Frame,4,[{pos,{150, 80}}]),
	wxTextCtrl:setSize(UserName,210,37),
	wxStaticText:new(Frame,5,"Password servizio",[{pos,{20,130}}]),
	Password=wxTextCtrl:new(Frame,6,[{pos,{150,130}}]),
	wxTextCtrl:setSize(Password,210,37),
	Services= wxTextCtrl:new(Frame,50,[{style, ?wxTE_MULTILINE bor ?wxTE_READONLY},{pos,{150,180}}]),
	wxTextCtrl:setSize(Services,300,300),
	wxTextCtrl:setValue(Services,passwordManagerService:getServices(Dets)),
	GetCredential=wxButton:new(Frame,7, [{label, "OTTIENI"}, {pos,{20, 180}}]),
	wxButton:connect(GetCredential, command_button_clicked,[{userData,{Service,UserName,Password}}]),
	SetCredential=wxButton:new(Frame,8, [{label, "AGGIUNGI"}, {pos,{20, 230}}]),
	wxButton:connect(SetCredential, command_button_clicked,[{userData,{Services,Service,UserName,Password}}]),
	DeleteCredential=wxButton:new(Frame,9, [{label, "ELIMINA"}, {pos,{20, 280}}]),
	wxButton:connect(DeleteCredential, command_button_clicked,[{userData,{Services,Service}}]),
	ModifyCredential=wxButton:new(Frame,10, [{label, "MODIFICA\nPASSWORD"}, {pos,{20, 330}}]),
	wxButton:connect(ModifyCredential, command_button_clicked,[{userData,{Service,Password}}]),
	Frame.