module PaypalApi
  extend self
  require 'paypal-sdk-merchant'
  require 'paypal-sdk-adaptiveaccounts'
  
  def mass_pay_request(email, total_amount)
    api = PayPal::SDK::Merchant::API.new
      
    mass_pay = api.build_mass_pay({
      :ReceiverType => "EmailAddress",
      :MassPayItem => [{
        :ReceiverEmail => email,
        :Amount => {
          :currencyID => "USD",
          :value => total_amount }, }] })

    api.mass_pay(mass_pay)
  end

  def verify_paypal_account(email)
    ip=Socket.ip_address_list.detect{|intf| intf.ipv4_private?}
    if ip
      api = PayPal::SDK::AdaptiveAccounts::API.new( :device_ipaddress => "#{ip.ip_address}" )

      get_verified_status = api.build_get_verified_status({
        :emailAddress => email,
        :matchCriteria => "NONE" })

      return api.get_verified_status(get_verified_status)
    else
      return false
    end
  end
end