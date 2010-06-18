require 'rubygems'
require 'active_record'

ActiveRecord::Base.establish_connection(
 :adapter => "postgresql",  
 :database => "palpite_certo",
 :username => "postgres",
 :password => "password"
)

ActiveRecord::Schema.define(:version => 0) do
  create_table "games", :force => true do |t|
    t.integer "id", :auto_increment => true, :primary_key=>true, :null => false
    t.string "twitter"
    t.string "url_avatar"
    t.string "palpite"
    t.string "placar"
    t.integer "pontos"
    t.datetime "hora_do_palpite"
  end
end
