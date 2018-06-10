# ログイン機能の実装
def set_user(user_id)
  return nil if user_id.nil?
  @user = db.xquery("SELECT * From users WHERE id = ?", user_id).to_a.first
end

def login?
  !session[:user_id].nil?
end

class LoginApp < Sinatra::Base
  enable :sessions

  set :public_folder, File.dirname(__FILE__) + '/public'

  get '/' do
    set_user
    erb :index
  end

  get '/login' do
    redirect '/' if login?

    erb :login
  end

  post '/login' do
    email = params[:email]
    password = params[:password]

    user = db.xquery("SELECT * FROM users where email = ? and password = ?",email, password).to_a.first


    if user
      session[:user_id] = user[:id]
      redirect '/'
    else
      erb :login
    end
  end
end


get '/login' do
  erb :login
end


# sign up画面
get '/welcome' do
  erb :welcome
end

post '/welcome' do
  @user_id = params[:user_id];
  @email = params[:email];
  @password = params[:password]


  # ユーザーを新規作成
  query = 'INSERT INTO users (user_id, email, password) VALUES (?,?,?)'
  client.xquery(query, params[:user_id], params[:email], params[:password])

  # ログイン画面にリダイレクト
  redirect to('/login')
end