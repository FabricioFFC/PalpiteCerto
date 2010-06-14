require 'rubygems'
require 'sinatra'
require 'twitter'
require 'haml'

def search
  Twitter::Search.new.containing('#palpitecerto')  
end

def process(palpites)
  @placares = []
  @acertadores = []
  palpites.each do |palpite|
    resultado = palpite.text[/#bra(.*?)$/, 1].upcase
    posicao_do_X = resultado.index('X')
    placar_brasil = resultado[1...posicao_do_X][/\d/]
    placar_adversario = resultado[(posicao_do_X+1)..resultado.length][/\d/]
    if "#{placar_brasil}X#{placar_adversario}"== "FXF" then
      @acertadores << {:usuario => palpite.from_user, :avatar => palpite.profile_image_url}
    end
    @placares << "#{placar_brasil}X#{placar_adversario}"
  end
end

get '/stylesheet.css' do
  content_type 'text/css'
  File.read 'stylesheet.css'
end

get '/' do
  @palpites = search
  haml :index
end

get '/resultados' do
  @palpites = search
  process(@palpites)
  haml :resultados
end

__END__

@@ layout
!!!
%title #PalpiteCerto
%link{:rel => "stylesheet", :href => "/stylesheet.css", :type => "text/css"}
%img{:src => "/images/palpite_certo.png"}
= yield
#footer
  Copyright © 2010 Palpite Certo. Powered by <a href="http://twitter.com/fabricioffc" target="_blank">@fabricioffc</a> and <a href="http://twitter.com/andre_pantaliao" target="_blank">@andre_pantaliao</a>.


@@ index
#wrapper
  %h2
    Próximo Jogo
    %img{:src => "http://a1.twimg.com/a/1276197224/images/worldcup/24/bra.png"} #bra X #prk 
    %img{:src => "http://a1.twimg.com/a/1276197224/images/worldcup/24/prk.png"}
  %p
    Apostas até às 15 horas da terça-feira (15/06), usando a hashtag
    %b #palpitecerto
  %p
    Quem fizer mais pontos até o último jogo do Brasil na Copa, ganha a camisa de uma seleção a sua escolha. 
  #header
    -@palpites.each do |palpite| 
      #user_bar
        %img{:src => palpite.profile_image_url}
        %b
          ="@#{palpite.from_user}"
        = " palpitou: #{palpite.text}"
      .clearfix

@@ resultados
#wrapper
  %h2
    Ranking
  #header
    - if @acertadores.empty?
      %p
        %i O Brasil ainda não jogou, aguarde o término da partida do Brasil para ver o ranking.
        %br
        %i 
          %b Pra cima deles Brasil!
    - else
      -@acertadores.each do |acertador|
        #user_bar
          %img{:src => acertador[:avatar]}
          %b
            ="@#{acertador[:usuario]}"
        .clearfix
