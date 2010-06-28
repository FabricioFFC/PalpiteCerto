require 'rubygems'
require 'sinatra'
require 'twitter'
require 'haml'
require 'pg'
require 'active_record'
require 'lib/shot'

dbconfig = YAML.load(File.read('config/database.yml'))
ActiveRecord::Base.establish_connection dbconfig['production']

get '/stylesheet.css' do
  content_type 'text/css'
  File.read 'stylesheet.css'
end

get '/' do
    @shot = Shot.new
    @shot.update_shots
    @shots = Game.find(:all, :order => "id DESC")
    @mais_apostados = Game.find_by_sql("select scores, count(*) as ct from games where match = 'braXchi' group by scores order by ct desc limit 5 ")
  haml :index
end

get '/ranking' do
  @shots = Game.find_by_sql("select twitter, url_avatar, SUM(points) as points from games group by twitter, url_avatar order by points DESC")
  haml :ranking
end

get '/admin' do
  @shot = Shot.new
  @shot.admin_shots
  haml :admin
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
        -if @shots.nil?
          Seja o primeiro a dá um palpite.
        -else
          ="Já foram #{@shots.size} palpites."
        %br
        %a{:href => "/ranking"}Ir para o Ranking
      Próximo jogo
      %img{:src => "/images/bra.png"} #bra X
      %img{:src => "/images/chi.png"} #chi
    .example 
      Mais apostados: 
      -if !@mais_apostados.nil?
        -@mais_apostados.each do |aposta| 
          = "#{aposta.scores}   "
  #explication
    %p
      Twitte o seu palpite até às 15 horas da segunda-feira (28/06), usando as hashtags:
      %b #palpitecerto
      e
      %b #bra
      %br
      .example 
        Exemplo: #palpitecerto #bra 1 X 0 #chi
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
    -if !@shots.nil?
      -i=0
      -@shots.each do |shot| 
        #user_bar
          %img{:src => shot.url_avatar}
          %b
            %a{:href => "http://www.twitter.com/#{shot.twitter}"}="@#{shot.twitter}"
          = " palpitou: #{shot.shot}"
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
  Após o empate contra Portugal, o ranking está assim:
  #header
    -if !@shots.nil?
      -@shots.each do |shot|
        #user_bar
          -if shot.twitter == "palpite_certo" then
            %img{:src => shot.url_avatar}
            %b
              %a{:href => "http://www.twitter.com/#{shot.twitter}"}="@#{shot.twitter}"
            =" tem 0 pontos, está de olho só nos palpites. :)"
          -else
            %img{:src => shot.url_avatar}
            %b
              %a{:href => "http://www.twitter.com/#{shot.twitter}"}="@#{shot.twitter}"
            =" tem #{shot.points} pontos"
        .clearfix

@@ admin
Ok
