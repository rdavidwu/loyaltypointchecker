require 'nokogiri'
require 'mechanize'


class LoyaltyAccountController < ApplicationController
	def show
	end

	#GET /addloyaltyaccount
	def add_account
		render 
	end

	#POST /addloyaltyaccount
	def connect
		#pp params
		@loyalty_program = params["loyalty_account"]
	  account_num = params["username"]
		password = params["password"]

		if @loyalty_program == "airmiles"

		  agent = Mechanize.new

		  page = agent.get('https://www.airmiles.ca/arrow/login/SignIn')
			airmiles_form = page.form_with(:dom_id => "form_sign_in")
			airmiles_form.field_with(:dom_id => "collectorNum").value = account_num
			airmiles_form.field_with(:dom_class => "input small").value = password
			page = airmiles_form.submit(airmiles_form.button_with( :value => 'Continue'))
			
			if page.uri.to_s.include? "https://www.airmiles.ca/arrow/Home"
				@cashmiles = agent.page.parser.css('.balance.cash').text().gsub(/\D/, '')
				@dreammiles = agent.page.parser.css('.balance.dream').text().gsub(/\D/, '')
				@name = agent.page.parser.css('.logged-out h2').children().text().split(/,/)[1]
				@name.gsub!('!', '').strip!

			else
				error_msg = page.parser.css('.error-text').text().gsub(/(\t)|(\n)/, '').strip
				flash.now[:error] = error_msg
				render 'add_account'	
			end
		elsif @loyalty_program == "aeroplan"

			agent = Mechanize.new

			page = agent.get('https://www4.aeroplan.com/landing/process.do?lang=E')
			aeroplan_form = page.form('LoginForm')

			if account_num.size < 9 
				render 'add_account'
			else
				# aeroplan_form.CUST1 = account_num[0..2]
		  #   aeroplan_form.CUST2 = account_num[3..5]
		  #   aeroplan_form.CUST3 = account_num[6..8] 
		  #   aeroplan_form.pin = password
		  

		    page = aeroplan_form.submit()

		    if page.uri.to_s.include? "https://www4.aeroplan.com/home.do"
 					@mileage = page.parser.css('.mileage').children.children.inner_html.gsub(/\D/, '')
 					@name = page.parser.css('.name').text().gsub(',','')
 				else
 					error_msg = page.parser.css('.mainErrorBodyLoginFailed').text()
 					flash.now[:error] = error_msg
 					render 'add_account'
 				end
			end
		end
	end
end
