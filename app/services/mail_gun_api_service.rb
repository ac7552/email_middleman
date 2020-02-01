require 'net/http'
require 'uri'

class MailGunApiService

  def initialize(data)
    @data = data
    @uri = URI.parse("https://api.mailgun.net/v3/#{ENV['MAILGUN_DOMAIN_NAME']}/messages")
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
    request = Net::HTTP::Post.new(@uri.request_uri)
    request.basic_auth("api", ENV['MAILGUN_APIKEY'])
    request.set_form_data(santize_payload)
    request
  end

  def santize_payload
    {'from' => @data[:from], 'to' => @data[:to], 'subject' => @data[:subject], 'text' => @data[:body]}
  end
end
