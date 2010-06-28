require 'rubygems'
require 'active_record'

ActiveRecord::Base.establish_connection(
 :adapter => "postgresql",  
 :database => "palpite_certo",
 :username => "postgres",
 :password => "hexabrasil"
)

ActiveRecord::Schema.define(:version => 0) do
  create_table "games", :force => true do |t|
    t.integer "id", :auto_increment => true, :primary_key=>true, :null => false
    t.string "twitter"
    t.string "url_avatar"
    t.string "shot"
    t.string "scores"
    t.string "result"
    t.string "match"
    t.integer "points"
    t.datetime "shot_time"
  end
  create_table "controls", :force => true do |t|
    t.string :match
    t.boolean :finished
  end
end
