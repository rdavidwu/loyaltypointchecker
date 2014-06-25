
if Rails.env.production?
	SymmetricEncryption.load!('config/symmetric-encryption.yml', 'production')
end