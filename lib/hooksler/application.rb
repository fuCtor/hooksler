require 'hitimes'
module Hooksler
  class Application
    def self.run
      self.new
    end

    def initialize
      @root = File.dirname ENV['BUNDLE_GEMFILE']

      Dir.glob(File.join(@root, 'inbounds/*.rb')).each do |file|
        require file
      end
      Dir.glob(File.join(@root, 'outbounds/*.rb')).each do |file|
        require file
      end

      require File.join(@root, 'config', 'routing.rb')

      Hooksler::Router.print
    end

    def call(env)
      req = Rack::Request.new(env)

      from_instance, routes = Hooksler::Router.resolve_path req.fullpath
      return ['410', {'Content-Type' => 'text/html'}, ['Gone']] unless from_instance

      message = from_instance.load(req)

      routes.each do |route|
        route.process(message)
      end

      ['200', {'Content-Type' => 'text/html'}, ['']]
    rescue => e
      puts e
      puts e.backtrace
      ['503', {'Content-Type' => 'text/html'}, [e.to_s]]
    end
  end
end
