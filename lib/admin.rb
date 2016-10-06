#!/usr/bin/env ruby
# interfaccia di amministrazione
##
### gente che amministra

# tiriamo fuori l'unico admin
utente = $db.execute("SELECT username, sha_password FROM amministratori LIMIT 1;");

set :username, utente[0][0]
set :token, "perilmomentousiamountokenstaticocheccazzo" #SecureRandom.uuid
set :password, utente[0][1]

helpers do
    def admin?
        request.cookies[settings.username] == settings.token
    end
    
    def protected!
        halt [ 401, 'Unathorized' ] unless admin?
    end

end

get '/login' do
    if admin?
        redirect to('/admin')
    else
        erb :admin_login, layout: :admin_layout
    end
end

get '/admin' do
    protected!
    #tiriamo fuori tutti i file
    @files = $db.execute("SELECT * FROM files;");
    erb :admin_panel, layout: :admin_layout
end

post '/login' do
    if params['username'] == settings.username && Digest::SHA256.hexdigest(params['password']) == settings.password
        response.set_cookie(settings.username, settings.token)
        redirect to('/admin')
    else
        erb :admin_failed, layout: :admin_layout
    end
end

get '/logout' do
    response.set_cookie(settings.username, false)
    redirect to('/login')
end
