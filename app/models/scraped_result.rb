require 'nokogiri'
require 'mechanize'
class ScrapedResult < ActiveRecord::Base

	def airmiles_scrape(account_num, password)
	  agent = Mechanize.new
	  agent.user_agent_alias = 'Mac Safari'
	  pass = SymmetricEncryption.decrypt(password)

	  page = agent.get('https://www.airmiles.ca/arrow/login/SignIn')
		
		if page.forms.empty? 
			self.status = "error"
			self.result = "Airmiles could not be accessed. Please try again later."
			self.save!
		else
			airmiles_form = page.form_with(:dom_id => "form_sign_in")
			airmiles_form.field_with(:dom_id => "collectorNum").value = account_num
			airmiles_form.field_with(:dom_class => "input small").value = pass
			page = airmiles_form.submit(airmiles_form.button_with( :value => 'Continue'))
			
			if page.uri.to_s.include? "https://www.airmiles.ca/arrow/Home"	
				cashmiles = agent.page.parser.css('.balance.cash').text().gsub(/\D/, '')
				dreammiles = agent.page.parser.css('.balance.dream').text().gsub(/\D/, '')
				name = agent.page.parser.css('.header-form.col-xs-12').children().text().split(/,/)[1].split("!")[0]
				name.strip!
				self.status = "success"
				self.result = "Hi #{name}\nYou have #{cashmiles} cash miles\nand #{dreammiles} dream miles"
			else		
				error_msg = page.parser.css('.error-text').text().gsub(/(\t)|(\n)/, '').strip
				self.status = "error"
				self.result = "Incorrect Airmiles Number or Pin was entered.\n#{error_msg}"	
			end
			self.save!
		end
	end

	def aeroplan_scrape(account_num, password)
		agent = Mechanize.new
		agent.user_agent_alias = 'Mac Safari'
		pass = SymmetricEncryption.decrypt(password)

		page = agent.get('https://www4.aeroplan.com/landing/process.do?lang=E')

		if page.forms.empty?
			self.status = "error"
			self.result = "Aeroplan could not be accessed. Please try again later."
			self.save!
		else
			aeroplan_form = page.form('LoginForm')

			if account_num.size < 9 
				render 'add_account'
			else
				aeroplan_form.CUST1 = account_num[0..2]
		    aeroplan_form.CUST2 = account_num[3..5]
		    aeroplan_form.CUST3 = account_num[6..8] 
		    aeroplan_form.pin = pass

		    page = aeroplan_form.submit()

		    if page.uri.to_s.include? "https://www4.aeroplan.com/home.do"
					mileage = page.parser.css('.mileage').children.children.inner_html.gsub(/\D/, '')
					name = page.parser.css('.name').text().gsub(',','')
					self.status = "success"
					self.result = "Hi #{name}\nYou have #{mileage} aeroplan miles"
				else
					error_msg = page.parser.css('.mainErrorBodyLoginFailed').text()
					self.status = "error"
					self.result = error_msg			
		#			flash.now[:error] = error_msg
		#			render 'add_account'
				end
				self.save!
			end	
		end
	end


	def starbucks_scrape(username, password)
		agent = Mechanize.new
		agent.user_agent_alias = 'Mac Safari'
		pass = SymmetricEncryption.decrypt(password)

		page = agent.get('https://www.starbucks.ca/account/signin')

		if page.forms.empty?
			self.status = "error"
			self.result = "Starbucks could not be accessed. Please try again later."
			self.save!
		else
			starbucks_form = page.form_with(:dom_id => "accountForm")
			starbucks_form.field_with(:dom_id => "Account_UserName").value = username
			starbucks_form.field_with(:dom_id => "Account_PassWord").value = pass
			
			page = starbucks_form.submit()

			if page.uri.to_s.include? "https://www.starbucks.ca/account/home"	
				rewards_bar = page.parser.css('#rewards-bar p.star-info')
				self.status = "success"
				if rewards_bar.empty?	#it only exists if there are rewards
					self.result = "there are currently no rewards for this account"
				else
					self.result = "Your current rewards: <br><br> #{rewards_bar.inner_html}"
				end		
			else		
				self.status = "error"
				self.result = "Incorrect username or password. Please try again."	

			end
			self.save!
		end
	end


	def united_scrape(username, password)
		agent = Mechanize.new
		agent.user_agent_alias = 'Mac Safari'
		pass = SymmetricEncryption.decrypt(password)

		page = agent.get('http://www.united.com/web/en-US/apps/account/account.aspx')

		if page.forms.empty?
			self.status = "error"
			self.result = "United could not be accessed. Please try again later."
			self.save!
		else
			united_form = page.form_with(:dom_id => "aspnetForm")
			united_form.field_with(:dom_id => "ctl00_ContentInfo_SignIn_onepass_txtField").value = username
			united_form.field_with(:dom_id => "ctl00_ContentInfo_SignIn_password_txtPassword").value = pass
			
			page = united_form.submit(united_form.button_with( :value => 'Sign In (Secure)'))

			if page.uri.to_s.include? "https://www.united.com/web/en-US/apps/account/signin.aspx"	
				self.status = "error"
				self.result = "Incorrect username or password. Please try again."					
			else		
				rewards = page.parser.css('#ctl00_ContentInfo_AccountSummary_lblMileageBalanceNew').text()
				name = page.parser.css('#ctl00_ContentInfo_AccountSummary_lblOPNameNew').text()
				self.status = "success"
				if rewards.empty?	#it only exists if there are rewards
					self.result = "there are currently no rewards for this account"
				else
					self.result = "Hi #{name}<br> Your have #{rewards} miles"
				end		
			end
			self.save!
		end
	end

end
