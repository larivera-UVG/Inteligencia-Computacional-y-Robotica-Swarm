% Extra�do de: https://la.mathworks.com/matlabcentral/answers/409343-sending-emails-through-matlab
% Este c�digo con diferentes mensajes se convirti� en archivos tipo p para
% proteger el email y contrase�a.
% Para convertir a pcode se hace:
% pcode(filename)
function error_mail()
mail = 'xxx@gmail.com'; %  Poner aqu� su correo
password = 'xxxx';  % Poner aqu� su contrase�a
setpref('Internet','SMTP_Server','smtp.gmail.com');
setpref('Internet','E_mail',mail);
setpref('Internet','SMTP_Username',mail);
setpref('Internet','SMTP_Password',password);
props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth','true');
props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
props.setProperty('mail.smtp.socketFactory.port','465');
% Send the email.  Note that the first input is the address you are sending the email to
sendmail(mail,'Thesis update','ERROR ERROR ERROR ERROR ERROR :( \n Algo sali� mal con el c�digo, and� a ver pls.')
end