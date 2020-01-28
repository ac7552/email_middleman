class EmailMailer < ApplicationMailer
  PERMITTED_FIELDS = [:to, :to_name, :from, :from_name, :subject, :body]

  def send_email(email_params)
    email_body = santize_body(email_params)
    to_address = santize_to(email_params)
    from_address = santize_from(email_params)
    mail(to: to_address, from: from_address, subject: email_params["subject"], body: email_body).deliver
  end

  private

  def santize_to(email_params)
    "#{email_params["to_name"]} <#{email_params["to"]}>"
  end

  def santize_from(email_params)
    "#{email_params["from_name"]} <#{email_params["from"]}>"
  end

  def strip_body_tags(html)
    ActionController::Base.helpers.strip_tags(html)
  end

  def santize_body(email)
    strip_body_tags(email["body"])
  end
end
