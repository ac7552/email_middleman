require 'rails_helper'

RSpec.describe EmailsController, :type => :controller do
  let(:proper_email) { {"email": {"from" => "Test_Joe@gmail.com",
                        "to" => "Test_Jack@gmail.com",
                        "from_name" => "Testing_Joe",
                        "to_name" => "Testing_Jack",
                        "subject" => "Testing123",
                        "body" => "<h1>Testing!</h1>"}}
                      }

  describe "POST email" do
    let(:valid_email_addresses) { ['simple@example.com','very.common@example.com', 'disposable.style.email.with+symbol@example.com', 'other.email-with-hyphen@example.com',
                                     'fully-qualified-domain@example.com', 'user.name+tag+sorting@example.com', 'x@example.com',
                                     'example-indeed@strange-example.com', 'admin@mailserver1', 'example@s.example',
                                     'mailhost!username@example.org','user%example.com@example.org']
    }
    let(:invalid_email_addresses) {['Abc.example.com', 'A@b@c@example.com', 'a"b(c)d,e:f;g<h>i[j\k]l@example.com',
                                    'just"not"right@example.com', 'this is"not\allowed@example.com', 'this\ still\"not\\allowed@example.com',
                                    '1234567890123456789012345678901234567890123456789012345678901234+x@example.com']}
    it "returns 200" do
      post(:create, params: proper_email)
      expect(response.status).to eq(200)
    end
    it "returns 422 when missing fields" do
      proper_email[:email].each do |key, _|
        email_copy = proper_email[:email].clone
        email_copy.delete(key)
        post(:create, params: {email: email_copy})
        expect(response.status).to eq(422)
        expect(JSON.parse(response.body)["error_message"]).to eq("Missing Fields: #{key}")
      end
    end
    it "returns 422 when fields are empty" do
      proper_email[:email].each do |key, _|
        email_copy = proper_email[:email].clone
        email_copy[key] = ""
        post(:create, params: {email: email_copy})
        expect(response.status).to eq(422)
        expect(JSON.parse(response.body)["error_message"]).to eq("Current Fields are empty: #{key}")
      end
    end

    context 'sender address' do
      it "returns 200 when sender email address is valid" do
        valid_email_addresses.each do |valid_email|
          proper_email[:email]["from"] = valid_email
          post(:create, params: proper_email)
          expect(response.status).to eq(200)
        end
      end
      it "returns 422 when sender email address is invalid" do
        invalid_email_addresses.each do |invalid_email|
          proper_email[:email]["from"] = invalid_email
          post(:create, params: proper_email)
          expect(response.status).to eq(422)
          expect(JSON.parse(response.body)["error_message"]).to eq("Invalid from Address")
        end
      end
    end

    context 'receiving address' do
      it "returns 200 when receiving email address is valid" do
        valid_email_addresses.each do |valid_email|
          proper_email[:email]["to"] = valid_email
          post(:create, params: proper_email)
          expect(response.status).to eq(200)
        end
      end

      it "returns 422 when reciever email address is invalid" do
        invalid_email_addresses.each do |invalid_email|
          proper_email[:email]["to"] = invalid_email
          post(:create, params: proper_email)
          expect(response.status).to eq(422)
          puts(invalid_email)
          expect(JSON.parse(response.body)["error_message"]).to eq("Invalid to Address")
        end
      end
    end
  end
end
