# Add a callback - to be executed before each request in development,
# and at startup in production - to patch existing app classes.
# Doing so in init/environment.rb wouldn't work in development, since
# classes are reloaded, but initialization is not run each time.
# See http://stackoverflow.com/questions/7072758/plugin-not-reloading-in-development-mode
#
Rails.configuration.to_prepare do
    # Front page needs some additional info
    GeneralController.class_eval do
        # Make sure it doesn't break if blog is not available 
        def frontpage
            begin
                blog
            rescue
                @blog_items = []
                @twitter_user = MySociety::Config.get('TWITTER_USERNAME', '')
            end
            
            begin
                @featured_requests = MySociety::Config.get("FRONTPAGE_FEATURED_REQUESTS", []).map{|i| InfoRequest.find(i)}
            rescue
                @featured_requests = []
            end
        end
    end

    PublicBodyController.class_eval do
        def index
            @public_bodies = PublicBody.where(false).paginate(:page => 10)
            @description = ''
            render :template => "public_body/list"
        end
    end

    HelpController.class_eval do
        def help_out
            render :template => "help/help_out"
        end

        def press
            render :template => "help/press"
        end

        def privacy_policy
            render :template => "help/privacy_policy"
        end

        def terms_of_use
            render :template => "help/terms_of_use"
        end

        def borrador_transparencia
            render :template => "help/borrador_transparencia"
        end

        def proyecto_transparencia
            render :template => "help/proyecto_transparencia"
        end
    end
end