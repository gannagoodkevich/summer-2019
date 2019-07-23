require 'fileutils'
require_relative 'path_loader'
require_relative 'coordinates_handler'
require_relative 'selfie_handler'

module CheckinContext
  include ImageFileWriter
  include CoordinatesHandler
  include SelfieHandler

  def checkin!(message = nil, *)
    save_context :checkin!
    if message
      coord_handle(@@path_checkin, 'in')
    elsif payload['text']
      respond_with :message, text: 'Send me your selfie, please'
    else
      @@path_checkin = PathLoader.new(payload)
      selfie_handler(@@path_checkin, 'in')
    end
  end
end