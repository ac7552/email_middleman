require 'rails_helper'

RSpec.describe EmailMailer, :type => :mailer do

  let(:proper_email) { {"from" => "Test_Joe@gmail.com",
                        "to" => "Test_Jack@gmail.com",
                        "from_name" => "Testing_Joe",
                        "to_name" => "Testing_Jack",
                        "subject" => "Testing123",
                        "body" => "<h1>Testing!</h1>"}
                      }

  it "sends an email" do
    EmailMailer.should_receive(:send_email)
    EmailMailer.send_email(proper_email)
  end

  describe 'send_email' do
    let(:mail) { EmailMailer.send_email(proper_email) }

    it 'renders the sender' do
      expect(mail.from).to eql(['Test_Joe@gmail.com'])
    end
    it 'renders the receiver' do
      expect(mail.to).to eql(['Test_Jack@gmail.com'])
    end
    it 'renders the subject' do
      expect(mail.subject).to eql('Testing123')
    end
    it 'renders santized body' do
      expect(mail.body.raw_source).to include "Testing!"
    end
  end
end
