require 'bundler'
Bundler.require
include Sprockets::Helpers

class App < Sinatra::Base
    set :sprockets, Sprockets::Environment.new(root)
    configure do
        APPLICATION_ID = "577577215707969"
        APPLICATION_SECRET = "6227419b9da54880f419ab45d7e8357e"
        set :sessions, true
        enable :sessions
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

    get '/sign_in' do
        callback_url = "#{base_url}/fb/callback"
        Koala::Facebook::OAuth.new(APPLICATION_ID, APPLICATION_SECRET, callback_url)
        redirect oauth_consumer.url_for_oauth_code(:callback => callback_url)
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
