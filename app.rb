require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/contrib'
require 'active_record'
require 'mysql2'
require 'mysql2-cs-bind'
require 'rack/csrf'

use Rack::Session::Cookie,secret: "thisissomethingsecret"
use Rack::Csrf, raise: true

helpers do
  def csrf_tag
    Rack::Csrf.csrf_tag(env)
  end

  def csrf_token
    Rack::Csrf.csrf_token(env)
  end

  def h(str)
    Rack::Utils.escape_html(str)
  end
end

enable :sessions

# Mysqlドライバの設定
client = Mysql2::Client.new(
    host: 'localhost',
    port: 3306,
    username: 'root',
    password: '',
    database: 'marine_life',
    reconnect: true,
    )

# users.rbの読み込み
require ('./users.rb')


get '/' do
  @title = 'Marine Life'
  # Home画面に全投稿を取得
  @posts = client.xquery("SELECT * FROM POSTS")
  erb :index
end

# 新規作成
get '/create' do
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
  # erb :show


  # 投稿を新規作成
  query = 'INSERT INTO posts (title, description, filename) VALUES (?,?,?)'
  client.xquery(query, params[:title], params[:description], "/img/#{@filename}")


  # トップページにリダイレクト
  redirect to('/')
end


# 削除
delete '/destroy/:id' do
  query = 'DELETE FROM posts WHERE id = ?'
  client.xquery(query, params[:id])

  redirect to('/')
end


