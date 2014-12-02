require 'bundler'
Bundler.require

class App < Sinatra::Base
    set :root, File.dirname(__FILE__)

    # register
    register Sinatra::AssetPack
    Rabl.register!

    configure do
        APPLICATION_ID = ENV['FACEBOOK_APP_ID'] 
        APPLICATION_SECRET = ENV['FACEBOOK_APP_SECRET'] 
        set :sessions, true
        enable :sessions
    end

    assets do
        serve '/javascript', from: 'assets/javascript'
        serve '/stylesheet', from: 'assets/stylesheet'

        js :app, '/javascript/application.js', [
            '/javascript/*.js',
            '/javascript/*.coffee',
        ]

        css :app, '/stylesheet/application.css', [
            '/stylesheet/*.scss',
            '/stylesheet/*.css',
        ]

        js_compression :jsmin
        css_compression :sass
    end

    before do
        if session[:facebook_access_token]
            @graph = Koala::Facebook::API.new(session[:facebook_access_token])
        else
            @graph = nil
        end
    end

    def base_url
        "#{request.scheme}://#{request.host}:#{request.port.to_s}"
    end

    def oauth_consumer
        Koala::Facebook::OAuth.new(APPLICATION_ID, APPLICATION_SECRET)
    end

    get '/' do
        if @graph
            @me = @graph.get_object('me')
        else
            @me = nil
        end
        haml :index 
    end

    get '/api/in' do
        if @graph
            @me = @graph.get_object('me')
            @graph.put_connections("me", "feed", :message => "#{@me['name']} -> in #socialtimecard")
        end
        rabl :foo, :format => 'json'             
    end

    get '/api/out' do
        if @graph
            @me = @graph.get_object('me')
            @graph.put_connections("me", "feed", :message => "#{@me['name']} -> out #socialtimecard")
        end
        rabl :bar, :format => 'json'             
    end

    get '/sign_in' do
        callback_url = "#{base_url}/fb/callback"
        Koala::Facebook::OAuth.new(APPLICATION_ID, APPLICATION_SECRET, callback_url)
        redirect oauth_consumer.url_for_oauth_code(:permissions => ['email', 'user_status', 'publish_actions'], :callback => callback_url)
    end

    get '/fb/callback' do
        if params[:code]
            callback_url = "#{base_url}/fb/callback"
            session[:facebook_access_token] = oauth_consumer.get_access_token(params[:code], :redirect_uri => callback_url)
            redirect '/'
        end
    end

    get '/sign_out' do
        session[:facebook_access_token] = nil
        redirect '/'
    end
end
