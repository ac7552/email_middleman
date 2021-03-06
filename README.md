# Email Middleman

This service is an abstraction between two email service providers(MailGun & SendGrid). Simply change a env variable/restart app and failover to a different provider

## Getting Started

1. Install Docker :

        On mac go to: 'https://docs.docker.com/docker-for-mac/install/'


2. Sign Up for SendGrid and MailGun
        Sendgrid: https://app.sendgrid.com/
        MailGun: https://www.mailgun.com/


3. In MailGun:
        Once Signed Up with Mailgun click on the Sending Tab followed by the Overview tab.
        In the overview Tab click on API box. You will need to copy and save the apikey and API base URL fields for later.
        ![MailGun reference](mailgun.png)

        If you're using the free version of mailgun you'll need to whitelist the email addresses you want to send
        and email to. In the image above I've verified that the only email address that can receive emails via
        MailGun acampbe2@binghamton.edu


4. In SendGrid:
        click on the Settings tab followed by API Keys tab. Create a new API Key via the API KEY button.
        You'll need to save the api key for later.
        ![SendGrid reference](sendgrid.png)


5. You'll need to build the web app docker image, so run the below command once: 
        
        docker-compose build
        
   Run the command below whenever you want to start the app: 
        
        docker-compose up       
        
6. Create a .env to store all your environmental variables. You'll need the following below.  

        MAILGUN_DOMAIN_NAME = "API base URL field"
        MAILGUN_APIKEY="apikey key"
        SENDGRID_PASSWORD="Your sendgrid API key"

    Both the mail_gun_api_service & send_grid_api_service use the .env variables for sending http request


7. Switching between MailGun and SendGrid:  
        This app uses the [Flipper Active Record Adapter](https://github.com/jnunemaker/flipper/tree/master/docs/active_record) for feature toggling. You'll need to create the     
        default_mailer feature flag in the console as so:

      Flipper Active Record Adapter Setup:
        
        rails g flipper:active_record
        docker-compose run web rake db:migrate
        

Enabling Feature flag:
````Ruby
  adapter = Flipper::Adapters::ActiveRecord.new
  flipper = Flipper.new(adapter)
  flipper[:default_mailer].enable
````
Disabling Feature flag:
````Ruby
  flipper = Flipper::Adapters::ActiveRecord::Gate.find_by(feature_key: "default_mailer", key: "boolean")
  flipper.update! value: "false"
````


## Tools/Migrations
1. For running Rspec run: docker-compose run web rspec
2. For checking routes: docker-compose run web rake routes
3. For running migrations: docker-compose run web rails g migration etc


### Prerequisites
Docker
SendGrid and MailGun Sign up


### Code Snippet:
  - In the emails_controller.rb file the send_mail contains the logic for deciding between email services.
````Ruby
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
````

### Email Middleman in Action

![Email Middleman](postman_example.png)


## Built With

* [MailGun](https://www.mailgun.com/)
* [SendGrid](https://sendgrid.com/)
* [Docker](https://docs.docker.com/docker-for-mac/install/) - Containers for an easy setup


## Future Work

- Move App to a more lightweight framework like Tornado:
        I belive Rails was a little overkill for this project, but it's the framework I'm most proficient with. 
        
- Store Emails in Postgres:      
        I belive a nice to have would be the ability to store emails at the database level for logging, resend emails, etc..
        The Email table would look something like below:
        
                time_delievered: timestamp
                successfully_delievered: boolean
                body: string
                to: string
                from: string
                subject: string
                id: integer => index
                email_age: timestamp
                
 - Job to Resend Emails using SideKiq scheduler: 
        I'd want a job to resend emails if an email wasn't successully sent. The job would check the successfully delivered           field.
        
 - Job to Clear Emails from Postgres using SideKiq scheduler: 
        I'd also want a job to remove emails from postgres, so there isn't an ever growing table. I'd want to set expiration  
        for emails at a day. The Clear Emails Job would look at the email_age field in determining which email rows to remove 

- Automatic Failover:
        I'd implement a mechanism to failover to the non default service in the event of failed responses.
        Essentially this would be toggling the feature flipper after an X amount of failures.
        
 - Lastly I'd want to support multiple recievers:
        Only one person can receive an email via the current API. I'd need to adjust the MailGunAPIService &                           SendGridAPIService in order to do so. 


## Authors

* **Aaron Campbell**
