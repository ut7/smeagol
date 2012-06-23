require 'gollum'
require 'rack/file'
require 'sinatra'
require 'mustache'
require 'tmpdir'
require 'smeagol/views/base'
require 'smeagol/views/page'
require 'smeagol/views/versions'

module Smeagol
  class App < Sinatra::Base

    #  S E T T I N G S

    set :public_folder, File.dirname(__FILE__) + '/public'

    #  R O U T E S

    # Update the gollum repository
    get '/update/?*' do
      key = params[:splat].first
      
      # If a secret key is specified for the repository, only update if the
      # secret is appended to the URL.
      if repository.secret.nil? || key == repository.secret
        wiki = Smeagol::Wiki.new(repository.path)
        if wiki.update(settings.git)
          'ok'
        else
          'error'
        end
      else
        # Show a forbidden response if the secret was not correct
        'forbidden'
      end
    end

    # Lists the tagged versions of the repo.
    get '/versions' do
      wiki = Smeagol::Wiki.new(repository.path)
      Mustache.render(get_template('versions'), Smeagol::Views::Versions.new(wiki))
    end

    # All other resources go through Gollum.
    get '/*' do
      name, version = parse_params(params)

      name = "Home" if name == ""   # TODO wiki.settings.index instead of 'Home'
      name = name.gsub(/\/+$/, '')
      name = File.sanitize_path(name)
      file_path = "#{repository.path}/#{name}"
      
      wiki  = Smeagol::Wiki.new(repository.path, {:base_path => mount_path})
      cache = Smeagol::Cache.new(wiki)

      # First check the cache
      if settings.cache_enabled && cache.cache_hit?(name, version)
        cache.get_page(name, version)
      # Then try to create the wiki page
      elsif page = wiki.page(name, version)
        view_page = Smeagol::Views::Page.new(page, version) #tag_name)
        template_type = view_page.post? ? 'post' : 'page'
        content = Mustache.render(get_template(template_type), view_page)
        cache.set_page(name, page.version.id, content) if settings.cache_enabled
        content
      # If it is a directory, redirect to the index page
      elsif File.directory?(file_path)
        url = "/#{name}/index.html"
        url = "/#{tag_name}#{url}" unless tag_name.nil?
        redirect url
      #
      elsif name == 'rss.xml'
        if page = wiki.page('rss.xml', version)
          content = Mustache.render(page.text_data, wiki)  # TODO: wiki okay here?
        else
          rss = RSS.new(wiki, version)
          content = rss.to_s
        end
        content
      # If it is not a wiki page then try to find the file
      elsif file = wiki.file(name, version)
        content_type get_mime_type(name)
        file.raw_data
      # Otherwise return a 404 error
      else
        raise Sinatra::NotFound
      end
    end

    #  P R I V A T E  M E T H O D S
  
    private

    # If the path starts with a version identifier, use it.
    #
    # params - Request parameters.
    #
    # Returns version number String.
    def parse_params(params)
      name     = params[:splat].first
      version  = 'master'
      tag_name = nil

      if name.index(/^v\d/)
        repo = Grit::Repo.new(repository.path)
        tag_name = name.split('/').first
        repo.tags.each do |tag|
          if tag.name == tag_name  # TODO: don't assume actual v prefix
            version = tag.commit.id
            name = name.split('/')[1..-1].join('/')
          end
        end
      end

      return name, version
    end

    # The Mustache template to use for page rendering.
    #
    # name - The name of the template to use.
    #
    # Returns the content of the page.mustache file in the root of the Gollum
    # repository if it exists. Otherwise, it uses the default page.mustache file
    # packaged with the Smeagol library.
    def get_template(name)
      if File.exists?("#{repository.path}/_smeagol/layouts/#{name}.mustache")
        IO.read("#{repository.path}/_smeagol/layouts/#{name}.mustache")
      else
        IO.read(File.join(File.dirname(__FILE__), "templates/layouts/#{name}.mustache"))
      end
    end

    # Retrieves the mime type for a filename based on its extension.
    #
    # file - The filename.
    #
    # Returns the mime type for a file.
    def get_mime_type(file)
      if !file.nil?
        extension = File.extname(file)
        return Rack::Mime::MIME_TYPES[extension] || 'text/plain'
      end
      
      return 'text/plain'
    end

    # Determines the repository to use based on the hostname.
    def repository
      # Match on hostname
      settings.repositories.each do |repository|
        next if repository.cname.nil?
        if repository.cname.upcase == request.host.upcase
          return repository
        end
      end
      
      # If no match, use the first repository as the default
      settings.repositories.first
    end

    # Determines the mounted path to prefix to internal links.
    def mount_path
      path = settings.mount_path
      path += '/' unless path.end_with?('/')
      path
    end

  end
end
