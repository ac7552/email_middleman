require 'net/http'
require 'uri'
SENDGRID_API_URL= "https://api.sendgrid.com/v3/mail/send"

class SendGridApiService

  def initialize(data)
    @data = data
    @uri = URI.parse(SENDGRID_API_URL)
  end

  def send_email
    http = set_http_object
    request = set_request_headers
    http.request(request)
  end

  private
  def set_http_object
    http = Net::HTTP.new(@uri.host, @uri.port)
    http.use_ssl = true
    http
  end

  def set_request_headers
    request = Net::HTTP::Post.new(@uri)
    request['content-type'] = "application/json"
    request["Authorization"] = "Bearer #{ENV['SENDGRID_PASSWORD']}"
    request.body = santize_payload
    request
  end

  def santize_payload
      {"personalizations": [{"to": [{"email": @data[:to]}]}],
       "from": {"email": @data[:from]},
       "subject": @data[:subject],
       "content": [{"type": "text/plain", "value": @data[:body]}]
      }.to_json
  end
end
