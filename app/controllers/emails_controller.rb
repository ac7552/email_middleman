class EmailsController < ActionController::API
  before_action :all_fields_exist, only: [:create]
  before_action :all_fields_occupied, only: [:create]
  before_action :valid_to_address, only: [:create]
  before_action :valid_from_address, only: [:create]


  def create
    begin
      EmailMailer.send_email(email_params).deliver
      render json: {}, status: :ok and return
    rescue StandardError => e
      render json: {error_message: e}, status: 500 and return
    end
  end

  private

  def all_fields_exist
    missing_fields = EmailMailer::PERMITTED_FIELDS.sort - email_params.keys.map(&:to_sym).sort
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

  def email_params
    params.require(:email).permit(EmailMailer::PERMITTED_FIELDS)
  end
end
