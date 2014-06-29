require 'nokogiri'
require 'mechanize'


class LoyaltyAccountController < ApplicationController
	def show
	end

	#GET /addloyaltyaccount
	def add_account
		render 
	end

	def check_done_scraping
		scraped_result = ScrapedResult.find_by_id(params["id"])
		if(scraped_result.status != "in_progress")
			render 	:json => { "is_done" => true, "result" => scraped_result.result }
		else
			render 	:json => { "is_done" => false, "result" => "" }
		end
	end

	#POST /addloyaltyaccount
	def connect
		#pp params
		@loyalty_program = params["loyalty_account"]
	  account = params["username"]
		password = params["password"]

		scraped_result = ScrapedResult.create 
		@random_id = scraped_result.id 
		scraped_result.status = "in_progress"
		scraped_result.save!

		if @loyalty_program == "airmiles"
			scraped_result.delay.airmiles_scrape(account, SymmetricEncryption.encrypt(password))
		elsif @loyalty_program == "aeroplan"
			scraped_result.delay.aeroplan_scrape(account, SymmetricEncryption.encrypt(password))
		elsif @loyalty_program == "starbucks"
			scraped_result.delay.starbucks_scrape(account, SymmetricEncryption.encrypt(password))
		elsif @loyalty_program == "united"
			scraped_result.delay.united_scrape(account, SymmetricEncryption.encrypt(password))
		end

	end
end
