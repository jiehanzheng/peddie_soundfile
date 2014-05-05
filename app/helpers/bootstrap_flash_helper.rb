module BootstrapFlashHelper
  ALERT_TYPES = ['success', 'info', 'warning', 'danger']

  def bootstrap_flash
    flash_messages = []
    flash.each do |type, message|
      next if message.blank?
      
      type = 'success' if type == 'notice'
      type = 'danger'  if type == 'alert' || type == 'error'
      next unless ALERT_TYPES.include?(type)

      Array(message).each do |msg|
        text = content_tag(:div,
                           msg.html_safe, :class => "alert alert-#{type}")
        flash_messages << text if msg
      end
    end
    flash_messages.join("\n").html_safe
  end
end
