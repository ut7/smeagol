module Smeagol

  module Views

    class Page < Base

      # The Gollum::Page that this view represents. This is
      # the same as `#file`.
      alias page file

      # Public: The title of the page.
      def title
        page.title
      end

      # TODO: temporary alias
      alias_method :page_title, :title

      # Public: The HTML formatted content of the page.
      def content
        page.formatted_data
      end

      #
      def summary
        i = content.index('</p>')
        i ? content[0..i+3] : content  # any other way if no i, 5 line limit?
      end

      # Public: The last author of this page.
      def author
        page.version.author.name
      end

      # Public: The last edit date of this page.
      def date
        post_date || commit_date
      end

      # Public: The last edit date of this page.
      def commit_date
        page.version.authored_date.strftime(settings.date_format)
      end

      # Public: A flag stating that this is not the home page.
      def not_home?
        page.title != "Home"  # settings.index
      end

      # Public: static href, used when generating static site.
      def href
        dir  = ::File.dirname(page.path)
        name = slug(page.filename_stripped)
        ext  = ::File.extname(page.path)

        if dir != '.'
          ::File.join(dir, name, 'index.html')
        else
          if name == settings.index #|| 'Home'
            'index.html'
          else
            ::File.join(name, 'index.html')
          end
        end
      end

      # Internal: Apply slug rules to name.
      #
      # TODO: Support configurable slugs.
      #
      # Returns [String] Sluggified name.
      def slug(name)
        if /^\d\d+\-/ =~ name
          dirs = [] 
          parts = name.split('-')
          while /^\d+$/ =~ parts.first
            dirs << parts.shift             
          end
          dirs << parts.join('-')
          dirs.join('/')
        else
          name
        end
      end

      # If the name of the page begins with a date, then it is the "post date"
      # and is taken to be a blog entry, rather then an ordinary static page.
      def post_date
        if md = /^(\d\d\d\d-\d\d-\d\d)/.match(filename)
          Time.parse(md[1]).strftime(settings.date_format)
        end
      end

      #
      def post?
        /^(\d\d\d\d-\d\d-\d\d)/.match(filename)
      end

      def has_header
        @header = (@page.header || false) if @header.nil?
        !!@header
      end

      def header_content
        has_header && @header.formatted_data
      end

      def header_format
        has_header && @header.format.to_s
      end

      def has_footer
        @footer = (@page.footer || false) if @footer.nil?
        !!@footer
      end

      def footer_content
        has_footer && @footer.formatted_data
      end

      def footer_format
        has_footer && @footer.format.to_s
      end

      def has_sidebar
        @sidebar = (@page.sidebar || false) if @sidebar.nil?
        !!@sidebar
      end

      def sidebar_content
        has_sidebar && @sidebar.formatted_data
      end

      def sidebar_format
        has_sidebar && @sidebar.format.to_s
      end

      def has_toc
        !@toc_content.nil?
      end

      def toc_content
        @toc_content
      end

      def mathjax
        @mathjax
      end

    end

  end

end
