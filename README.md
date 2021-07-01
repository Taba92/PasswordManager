passwordManager
=====

A password manager tool.

Build
-----
    $ rebar3 compile

For the login it is used the loginWindow application : https://github.com/Taba92/loginWindow

CONFIGURATION:
    Launch the script **install**, that will create a default user *root* with password *passwd1111111111*.
    It also creates the default storage for the *root* user.

ATTENTION:
    ***Every invocation of the configuration script install, remove all files in Credentials and Passwords folders and recreate the default user***.

***The passwords storage is encrypted with the credentials of the logged user, so it very important to change as soon as possible the default user with other login credentials***.
After the login credentials are changed, the password database is re-encrypted with the new credentials. 

USAGE BUTTONS:
    GET CREDENTIAL: retrieve username and password of the service.
    ADD CREDENTIAL: add a service.
    DELETE CREDENTIAL: delete a service.
    MODIFY PASSWORD: Modify the password of the service in exam.
                   

FUTURE DEVELOPMENTS: 
    1) Translate GUI in English.