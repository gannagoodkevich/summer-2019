require 'fileutils'
require_relative 'path_loader'

module CheckoutContext
@@path_checkout

  def checkout!(message = nil, *)
    if message
      path_geo = @@path_checkout.load_path_checkout + "#{payload["from"]["username"]}.txt"
      dirname = File.dirname(path_geo)
      puts path_geo
      FileUtils.mkdir_p(dirname) unless File.directory?(dirname)
      File.open(path_geo,'w') do |h| 
        h.write payload['text']
      end
      respond_with :message, text: 'Have fun and good luck!!!'
    else
      if payload['text'].nil?
        @@path_checkout = PathLoader.new(payload)
        puts payload.inspect
        save_context :checkout!
        puts payload.inspect
        file_id =  payload['photo'].first['file_id']
        response = HTTParty.get("https://api.telegram.org/bot#{TOKEN}/getFile?file_id=#{file_id}")
        photo_url  = "https://api.telegram.org/file/bot#{TOKEN}/#{response['result']['file_path']}"
        path_img = @@path_checkout.load_path_checkout + "#{payload["from"]["username"]}.jpg"
        dirname = File.dirname(path_img)
        FileUtils.mkdir_p(dirname) unless File.directory?(dirname)
        open(path_img, 'wb') do |file|
         file << open(photo_url).read
        end
        respond_with :message, text: 'Then send me your coordinates, pleas'
      else
        save_context :checkout!
        respond_with :message, text: 'Send me your selfie, please'
      end
    end
  end
end
