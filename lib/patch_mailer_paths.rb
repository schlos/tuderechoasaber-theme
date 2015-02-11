# Add a callback - to be executed before each request in development,
# and at startup in production - to patch existing app classes.
# See http://stackoverflow.com/questions/7072758/plugin-not-reloading-in-development-mode
#
Rails.configuration.to_prepare do
  # Override mailer templates with theme ones. Note doing this in a before_filter,
  # as we do with the controller paths, doesn't seem to have any effect when
  # running in production
  ActionMailer::Base.prepend_view_path  File.join(File.dirname(__FILE__), "views")


  # Override standard incoming mail handling to cope with malformed messages in Spain
  RequestMailer.class_eval do
    def self.receive(raw_email)
      logger.info "Received mail:\n #{raw_email}" unless logger.nil?
      mail = MailHandler.mail_from_raw_email(raw_email)

      # We need to add this bit to cope with the Spanish 'Portal de Transparencia':
      # their emails don't include the target address in the To: field, which points
      # to a non-reply address. Instead the target address is part of the Received: field,
      # but it comes in a separate line, so they mail gem can't process it. We are thus
      # forced to dig into the beginning of the raw email (thousand characters should do).
      # TODO: I should use the configured mail prefix instead of hardcoding "tdas+" in
      # the regex, but this is so specific anyway...
      if mail.to.size==1 and mail.to.first == 'noreply.gesat@correo.gob.es'
        raw_email[0..1000] =~ /<(tdas\+request-.+)>/
        mail.to = [$1]
      end

      new.receive(mail, raw_email)
    end
  end
end