class PagesController < ApplicationController
  def hello
    ActionCable.server.broadcast 'AlertsChannel', "Hello from Akashy"
  end
end
