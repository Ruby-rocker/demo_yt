class PackageConfig

  FIXED_FEE = 25.0

  PAY_AS_YOU_GO = 'pay_as_you_go'
  MINUTE_200 = '200minutes'
  MINUTE_500 = '500minutes'
  ADD_ON_SERVICE = 'add_on_service'

  ADD_ON_ID = ['yestrak_monthly_fee', 'one_time_add_on', 'voicemail', 'call_record', 'phone_menu', 'script_calls',
               'menu_calls', 'voicemail_calls']

  MAIN_PLAN_IDS = [PAY_AS_YOU_GO, MINUTE_200, MINUTE_500]

  PLANS = {PAY_AS_YOU_GO => 'Pay as you go - $1.50/minute',
           MINUTE_200 => '200 minutes of monthly talk time - $250/month',
           MINUTE_500 => '500 minutes of monthly talk time - $500/month'}

  PLAN_NAME = {PAY_AS_YOU_GO => 'Pay As You Go', MINUTE_200 => '200 Minutes', MINUTE_500 => '500 Minutes'}

  PLAN_PRICE = {PAY_AS_YOU_GO => 0.0, MINUTE_200 => 250.0,
                MINUTE_500 => 500.0, ADD_ON_SERVICE => 10.0}

  OVERAGE = {PAY_AS_YOU_GO => 1.5, MINUTE_200 => 1.25, MINUTE_500 => 1.0, ADD_ON_SERVICE => 0.10 }
  FREE_MINUTES = {PAY_AS_YOU_GO => 0, MINUTE_200 => 200, MINUTE_500 => 500, ADD_ON_SERVICE => 100 }

  def initialize(plan_id)
    @plan_id = plan_id
  end

  def overage
    OVERAGE[@plan_id]
  end

  def plan_price
    PLAN_PRICE[@plan_id]
  end

  def free_minutes
    FREE_MINUTES[@plan_id]
  end

  def monthly_fee
    PLAN_PRICE[@plan_id] + FIXED_FEE
  end

end

#"Active"
#"Canceled"
#"Expired"
#"Past Due"
#"Pending"
#"Unrecognized"