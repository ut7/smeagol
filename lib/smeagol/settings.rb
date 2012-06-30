module Smeagol

  # Wiki settings.
  #
  # Note not all of these settings are fully supported yet.
  class Settings

    # Directory which contains user settings.
    CONFIG_HOME = ENV['XDG_CONFIG_HOME'] || '~/.config'

    #
    def self.load(wiki_dir=Dir.pwd)
      file = File.join(wiki_dir, '_smeagol', 'settings.yml')
      file = File.expand_path(file)
      if File.exist?(file)
        settings = YAML.load_file(file)
      else
        settings = {}
      end

      settings[:wiki_dir] = wiki_dir

      new(settings)
    end

    #
    #
    def initialize(settings={})
      @site_dir      = '_smeagol/site'
      #@build_dir    = '_smeagol/build'
      @index         = 'Home'
      @rss           = false
      @exclude       = []
      @include       = []
      @layouts       = {}

      update(settings)
    end

    # TODO: temporary
    def [](key)
      __send__(key)
    end

    #
    def update(settings={})
      settings.each do |k,v|
        __send__("#{k}=", v)
      end
    end

    #
    attr_accessor :wiki_dir

    # Site's URL. If someone wanted to visit your website, this
    # is the link they would follow, e.g. `http://trans.github.com`
    attr_accessor :url


    # Gollum wiki's repo uri.
    # e.g. `git@github.com:trans/trans.github.com.wiki.git`
    attr_accessor :wiki_origin

    # The particular tag or reference id to serve. Default is 'master'.
    attr_accessor :wiki_ref

    # Site's git repo uri.
    # e.g. `git@github.com:trans/trans.github.com.git`
    attr_accessor :site_origin

    # If your repo is using (stupid) detached branch approach,
    # then specify the branch name here. This will typically
    # be of used for GitHub projects using Pages feature and set
    # to 'gh-pages'.
    attr_accessor :site_branch

    # Where to sync site. (For static builds only.)
    # Default value is `_smeagol/site`.
    attr_accessor :site_dir

    # Where to build static files. (For static builds only.)
    # Default value is `_smeagol/build`.
    #attr_accessor :build_dir

    # Page to use as site index. The default is `Home`. A non-wiki
    # page can be used as well, such as `index.html` (well, duh!).
    attr_accessor :index

    # Boolean flag to produce an rss.xml feed file for blog posts.
    attr_accessor :rss

    # Files to include that would not otherwise be included. A good example
    # is `.htaccess` becuase dot files are excluded by default.
    attr_accessor :include

    # Files to exclude that would otherwise be included.
    attr_accessor :exclude

    # Include posts with future dates? By default all posts dated in the
    # future are omitted. (TODO)
    attr_accessor :future

    # Do not load plugins. (TODO?)
    #attr_accessor :safe

    # Mapping of file to layout to be used to render.
    attr_accessor :layouts


    # Title of site.
    attr_accessor :title

    # Single line description of site.
    attr_accessor :tagline

    # Detailed description of site.
    attr_accessor :description

    # Primary author/maintainer of site.
    attr_accessor :author

    # Menu that can be used in site template.
    #
    # Note this will probably be deprecated as it is easy
    # enough to add a menu to your site's custom page template.
    #
    # Examples
    #
    #   menu:
    #   - title: Blog
    #     href: /
    #   - title: Projects
    #     href: /Projects/
    #   - title: Tools
    #     href: /Tools/
    #   - title: Reads
    #     href: /Reads/
    #
    attr_accessor :menu

    # Google analytics tracking id. Could be used for other such
    # services if custom template is used.
    #
    # Note this will probably be deprecates because you can add
    # the code snippet easily enough to your custom page template.
    attr_accessor :tracking_id

    # Include a GitHub "Fork Me" ribbon in corner of page. Entry 
    # should give color and position separated by a space.
    # The resulting ribbon will have a link to `source_url`.
    #
    # TODO: Rename this `github_forkme` or something like that.
    #
    # Examples
    #
    #   ribbon: red right
    #
    # Note this might be deprecated as one can add it by
    # hand to custom page template.
    attr_accessor :ribbon

    # Project's development site, if applicable.
    # e.g. `http://github.com/trans`
    #
    # TODO: Rename this field.
    attr_accessor :source_url

=begin
    # Location of cross-project configuration file.
    #
    # The location of this file can be adjusted via `SMEAGOL_CONFIG`
    # environment variable.
    #
    # Returns String of file's path.
    def config_file
      file = ENV['SMEAGOL_CONFIG']
      if file
        puts "Cannot find configuration file: #{path}" unless File.exists?(file)
        puts "Cannot read configuration file: #{path}" unless File.readable?(file)
      end
      file || File.join(home_config_dir, 'smeagol/config.yml')
    end

    # Loads cross-project configuration file.
    #
    # The location of this file can be adjusted via `SMEAGOL_CONFIG`
    # environment variable.
    #
    # Returns Hash of options from the config file.
    def load_config
      config = {}

      path = config_file

      if File.exists?(path)
        # Notify the user if the config file exists but is not readable.
        unless File.readable?(path)
          puts "Config file not readable: #{path}"
          exit
        end
        
        config = YAML.load(IO.read(path))
      end

      config = config.inject({}){ |h, (k,v)| h[k.to_sym] = v; h }

      return config
    end
=end

  end

end
