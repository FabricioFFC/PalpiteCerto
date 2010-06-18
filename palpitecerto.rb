require 'rubygems'
require 'sinatra'
require 'twitter'
require 'haml'
require 'active_record'

ActiveRecord::Base.establish_connection(
 :adapter => "postgresql",  
 :database => "palpite_certo",
 :username => "postgres",
 :password => "hexabrasil" 
)

class Game < ActiveRecord::Base
end

def twitter_exists?(twitter)
  size = Game.find_by_sql(["select twitter from games where twitter = ?", twitter]).size
  size == 1
end

def discover_placar(palpite)
    resultado = palpite[/#bra(.*?)$/, 1].upcase
    posicao_do_X = resultado.index('X')
    placar_brasil = resultado[1...posicao_do_X][/\d/]
    placar_adversario = resultado[(posicao_do_X+1)..resultado.length][/\d/]
    "#{placar_brasil}X#{placar_adversario}"
end


def add_new_twitter(result)
    registro = Game.new
    registro.twitter = result.from_user
    registro.url_avatar = result.profile_image_url
    registro.palpite = result.text
    registro.placar = discover_placar(result.text)
    registro.pontos = 0
    registro.hora_do_palpite = result.created_at
    registro.save  
end

def search
  search = Twitter::Search.new.containing('#palpitecerto')
  search.per_page(1000)
  search.each do |result| 
    if !twitter_exists?(result.from_user) and result.text.include?("#bra")
      add_new_twitter(result)
    end
  end
end

get '/stylesheet.css' do
  content_type 'text/css'
  File.read 'stylesheet.css'
end

get '/' do
  search
  @palpites = Game.all
  haml :index
end

get '/ranking' do
  haml :ranking
end

__END__

@@ layout
!!!
%html(lang='pt-BR')
  %head
    %meta(charset='utf-8')
    %title #PalpiteCerto
  %body
    %link{:rel => "stylesheet", :href => "/stylesheet.css", :type => "text/css"}
    %img{:src => "/images/palpite_certo.png"}
    = yield
    #footer
      Copyright © 2010 
      %a{:href => "http://www.voicetechnology.com.br/"}Voice Technology.
      Powered by 
      %a{:href => "http://twitter.com/fabricioffc"}@fabricioffc
      and
      %a{:href=>"http://twitter.com/andre_pantaliao"}@andre_pantaliao.

@@ index
#wrapper
  #title
    %h2
      .quantity
        ="Já foram #{@palpites.size} palpites."
        %br
        %a{:href => "/ranking"}Ir para o Ranking
      Próximo Jogo
      %img{:src => "/images/bra.png"} #bra X #prk 
      %img{:src => "/images/prk.png"}     
  #explication
    %p
      Twitte o seu palpite até às 15 horas da terça-feira (15/06), usando as hashtags:
      %b #palpitecerto
      e
      %b #bra
      %br
      .example 
        Exemplo: #palpitecerto #bra 5 X 2 #prk
    %p
      Só serão aceitos os palpites* em jogos do Brasil. Quem fizer mais pontos até o último jogo do Brasil na Copa, ganha a camisa de uma seleção a sua escolha**. 
    %p
      %i Placar exato: 15 pontos
      %br
      %i Acertar o resultado: 10 pontos.      
    %p
      %i 
        *só é válido o último palpite de cada pessoa. 
        %br
        **em caso de empate haverá sorteio entre os primeiros lugares.
  %h3 Últimos palpites:
  #header
    -i=0
    -@palpites.each do |palpite| 
      #user_bar
        %img{:src => palpite.url_avatar}
        %b
          %a{:href => "http://www.twitter.com/#{palpite.twitter}"}="@#{palpite.twitter}"
        = " palpitou: #{palpite.palpite}"
      .clearfix
      -i+=1
      -if i == 15 
        -break

@@ ranking
#wrapper
  %h2
    .quantity
      %a{:href => "/"}Voltar para a página inicial
    Ranking
  #header
    %p
      %i O Brasil ainda não jogou, aguarde o término da partida do Brasil para ver o ranking.
      %br
      %i 
        %b Pra cima deles Brasil!
