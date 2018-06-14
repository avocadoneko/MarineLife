require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/contrib'
require 'active_record'
require 'mysql2'
require 'mysql2-cs-bind'
require 'rack/csrf'
# pryの読み込み
require 'pry'

use Rack::Session::Cookie, secret: "thisissomethingsecret"
use Rack::Csrf, raise: true


# Mysqlドライバの設定
# defにしてクラス内で読み込めるようにする
def client
  client = Mysql2::Client.new(
      host: 'localhost',
      port: 3306,
      username: 'root',
      password: '',
      database: 'marine_life',
      reconnect: true,
      )
end



class MarineLife < Sinatra::Base
  # セッション
  enable :sessions

  # メソッド set_user を定義
  def set_user
    return nil if session[:user_id].nil?
    # インスタンス変数 @user の定義
    # インスタンス変数ならメソッド定義外でも使える
    @user = client.xquery("SELECT * From users WHERE id = ?", session[:user_id]).to_a.first
  end


  #reloader
  # config.ruの呼び出し
  configure :development do
    register Sinatra::Reloader
  end

  # publicディレクトリを使えるようにする
  set :public_folder, File.dirname(__FILE__) + '/public'

  # 投稿画面
  get '/' do
    # さっき定義したやつ
    set_user

    @title = 'Marine Life'
    # Home画面に全投稿を取得
    @posts = client.xquery("SELECT * FROM POSTS")
    erb :index
  end


  # 新規作成
  get '/create' do
    # さっき定義したやつ
    set_user
    erb :create
  end

  # 新規作成(POST)
  post '/create' do

    # 画像情報を取得
    @filename = params[:file][:filename]
    file = params[:file][:tempfile]

    # 画像をディレクトリに配置
    File.open("./public/img/#{@filename}", 'wb') do |f|
      f.write(file.read)
    end

    @title = params[:title];
    @description = params[:description];
    @image_path = "/img/#{@filename}"
    @user_name = params[:name]


    # 投稿を新規作成
    query = 'INSERT INTO posts (title, description, filename, user_name) VALUES (?,?,?,?)'
    # @user_nameでnameカラムを呼び出す
    client.xquery(query, params[:title], params[:description], "/img/#{@filename}", @user_name)


    # トップページにリダイレクト
    redirect to('/')
  end


  # 削除
  post '/destroy/:id' do
    query = 'DELETE FROM posts WHERE id = ?'
    client.xquery(query, params[:id])

    redirect to('/')
  end



  # ログイン機能の実装

  def login?
    !session[:user_id].nil?
  end


  get '/login' do
    redirect '/' if login?

    erb :login
  end

  post '/login' do
    email = params[:email]
    password = params[:password]

    # pryでデバッグチェック
    # binding.pry

    # DBに検索かけて、一致するレコードが存在したらemailとpasswordのセットが存在するユーザーが居る
    user = client.xquery("SELECT * FROM users where email = ? and password = ?", email, password).to_a.first

    if user
      session[:user_id] = user['id']
      redirect '/'
    else
      erb :login
    end
  end


  # sign up画面
  get '/welcome' do
    erb :welcome
  end

  post '/welcome' do
    # @user_id = params[:user_id]
    # @email = params[:email]
    # @password = params[:password]

    # ユーザーを新規作成
    query = 'INSERT INTO users (name, email, password) VALUES (?,?,?)'
    client.xquery(query, params[:name], params[:email], params[:password])

    # 新規登録したあとすぐに、そのままログイン
    user = client.xquery("SELECT * FROM users where name = ?", params[:name]).to_a.first

    if user
      session[:user_id] = user['id']
      redirect '/'
    end

    # ログイン画面にリダイレクト
    redirect to('/')

  end


  # ログアウトの実装
  get '/logout' do
    session[:user_id] = nil
    redirect '/login'
  end


end






