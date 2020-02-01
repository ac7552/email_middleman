class EmailsController < ActionController::API
  before_action :all_fields_exist, only: [:create]
  before_action :all_fields_occupied, only: [:create]
  before_action :valid_to_address, only: [:create]
  before_action :valid_from_address, only: [:create]

  PERMITTED_FIELDS = [:to, :to_name, :from, :from_name, :subject, :body]

  def create
    begin
      send_mail
      render json: {}, status: :ok and return
    rescue StandardError => e
      render json: {error_message: e}, status: 500 and return
    end
  end

  private

  def all_fields_exist
    missing_fields = PERMITTED_FIELDS.sort - email_params.keys.map(&:to_sym).sort
    return if missing_fields.empty?
    missing_fields = missing_fields.join(",")
    render json: {error_message: "Missing Fields: #{missing_fields}"}, status: 422 and return
  end

  def all_fields_occupied
    empty_fields = []
    email_params.each {|key, value| empty_fields.push(key) if value.empty?}
    return if empty_fields.empty?
    empty_fields = empty_fields.join(",")
    render json: {error_message: "Current Fields are empty: #{empty_fields}"}, status: 422 and return
  end

  def valid_to_address
    return if email_address_valid?(email_params[:to])
    render json: {error_message: "Invalid to Address"}, status: 422 and return
  end

  def valid_from_address
    return if email_address_valid?(email_params[:from])
    render json: {error_message: "Invalid from Address"}, status: 422 and return
  end

  def email_address_valid?(email_address)
    return false if email_address.split("@").first.length > 64
    !(email_address =~ URI::MailTo::EMAIL_REGEXP).nil?
  end

  def santize_to(email_data)
    "#{email_params["to_name"]} <#{email_params["to"]}>"
  end

  def santize_from(email_data)
    "#{email_params["from_name"]} <#{email_params["from"]}>"
  end

  def strip_body_tags(html)
    ActionController::Base.helpers.strip_tags(html)
  end

  def santize_body(email_data)
    strip_body_tags(email_data["body"])
  end

  def bundle_payload(email_data)
    email_body = santize_body(email_data)
    to_address = santize_to(email_data)
    from_address = santize_from(email_data)
    data = {to: to_address,
            from: from_address,
            body: email_body,
            subject: email_data["subject"]
            }
  end

  def default_mailer_enabled?
    flipper_gate = Flipper::Adapters::ActiveRecord::Gate.find_by(feature_key: "default_mailer", key: "boolean")
    return false if flipper_gate.nil?
    flipper_gate.value == "true"
  end

  def send_mail
    data = bundle_payload(email_params)
    if default_mailer_enabled?
      MailGunApiService.new(data).send_email
    else
      SendGridApiService.new(data).send_email
    end
  end

  def email_params
    params.require(:email).permit(PERMITTED_FIELDS)
  end
end
