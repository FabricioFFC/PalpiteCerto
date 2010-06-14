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
"Rendered at #{Time.now}"
#wrapper
  %h2
    Próximo Jogo
    %img{:src => "/images/bra.png"} #bra X #prk 
    %img{:src => "/images/prk.png"}
  #explication
    %p
      Palpites até às 15 horas da terça-feira (15/06), usando as hashtags:
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
  %h3
    Últimos palpites:
  #header
    -@palpites.each do |palpite| 
      #user_bar
        %img{:src => palpite.profile_image_url}
        %b
          %a{:href => "http://www.twitter.com/#{palpite.from_user}"}="@#{palpite.from_user}"
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
