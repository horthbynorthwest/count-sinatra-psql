require "sinatra"
require "./lib/counter"
require './database_connection_setup'

class CounterApp < Sinatra::Base

  before do
    @counter = Counter.instance
  end

  get '/' do
    erb :index
  end

  post '/increment' do
    @counter.increment
    redirect '/'
  end

  post '/decrement' do
    @counter.decrement
    redirect '/'
  end
end
