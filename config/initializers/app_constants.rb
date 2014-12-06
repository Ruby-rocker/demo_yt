#US_STATES = ["Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado", "Connecticut", "Delaware", "District Of Columbia", "Florida", "Georgia", "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa ", "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland", "Massachusetts", "Michigan", "Minnesota", "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire", "New Jersey", "New Mexico", "New York", "North Carolina", "North Dakota", "Ohio ", "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", "South Carolina", "South Dakota", "Tennessee", "Texas", "Utah ", "Vermont", "Virginia", "Washington", "West Virginia", "Wisconsin", "Wyoming"]

APP_CONFIG = YAML.load_file(Rails.root.join('config/application_config.yml'))[Rails.env]

US_STATES = {"AL"=>"Alabama", "AK"=>"Alaska", "AZ"=>"Arizona", "AR"=>"Arkansas", "CA"=>"California", "CO"=>"Colorado",
             "CT"=>"Connecticut", "DE"=>"Delaware", "DC"=>"District of Columbia", "FL"=>"Florida", "GA"=>"Georgia",
             "HI"=>"Hawaii", "ID"=>"Idaho", "IL"=>"Illinois", "IN"=>"Indiana", "IA"=>"Iowa", "KS"=>"Kansas",
             "KY"=>"Kentucky", "LA"=>"Louisiana", "ME"=>"Maine", "MD"=>"Maryland", "MA"=>"Massachusetts",
             "MI"=>"Michigan", "MN"=>"Minnesota", "MS"=>"Mississippi", "MO"=>"Missouri", "MT"=>"Montana",
             "NE"=>"Nebraska", "NV"=>"Nevada", "NH"=>"New Hampshire", "NJ"=>"New Jersey", "NM"=>"New Mexico",
             "NY"=>"New York", "NC"=>"North Carolina", "ND"=>"North Dakota", "OH"=>"Ohio", "OK"=>"Oklahoma",
             "OR"=>"Oregon", "PA"=>"Pennsylvania", "RI"=>"Rhode Island", "SC"=>"South Carolina",
             "SD"=>"South Dakota", "TN"=>"Tennessee", "TX"=>"Texas", "UT"=>"Utah", "VT"=>"Vermont",
             "VA"=>"Virginia", "WA"=>"Washington", "WV"=>"West Virginia", "WI"=>"Wisconsin", "WY"=>"Wyoming"}

CA_STATES = {"AB" => "Alberta",
              "BC" => "British Columbia",
              "MB" => "Manitoba",
              "NB" => "New Brunswick",
              "NL" => "Newfoundland and Labrador",
              "NS" => "Nova Scotia",
              "NT" => "Northwest Territories",
              "NU" => "Nunavut",
              "ON" => "Ontario",
              "PE" => "Prince Edward Island",
              "QC" => "Quebec",
              "SK" => "Saskatchewan",
              "YT" => "Yukon"}

#http://www.freeformatter.com/iso-country-list-html-select.html
#COUNTRIES = {"US"=>"United States","AF"=>"Afghanistan","AX"=>"Aland Islands","AL"=>"Albania","DZ"=>"Algeria","AS"=>"American Samoa",
#             "AD"=>"Andorra","AO"=>"Angola","AI"=>"Anguilla","AQ"=>"Antarctica","AG"=>"Antigua and Barbuda",
#             "AR"=>"Argentina","AM"=>"Armenia","AW"=>"Aruba","AU"=>"Australia","AT"=>"Austria","AZ"=>"Azerbaijan",
#             "BS"=>"Bahamas","BH"=>"Bahrain","BD"=>"Bangladesh","BB"=>"Barbados","BY"=>"Belarus","BE"=>"Belgium",
#             "BZ"=>"Belize","BJ"=>"Benin","BM"=>"Bermuda","BT"=>"Bhutan","BO"=>"Bolivia, Plurinational State of",
#             "BQ"=>"Bonaire, Sint Eustatius and Saba","BA"=>"Bosnia and Herzegovina","BW"=>"Botswana",
#             "BV"=>"Bouvet Island","BR"=>"Brazil","IO"=>"British Indian Ocean Territory","BN"=>"Brunei Darussalam",
#             "BG"=>"Bulgaria","BF"=>"Burkina Faso","BI"=>"Burundi","KH"=>"Cambodia","CM"=>"Cameroon","CA"=>"Canada",
#             "CV"=>"Cape Verde","KY"=>"Cayman Islands","CF"=>"Central African Republic","TD"=>"Chad","CL"=>"Chile",
#             "CN"=>"China","CX"=>"Christmas Island","CC"=>"Cocos (Keeling) Islands","CO"=>"Colombia","KM"=>"Comoros",
#             "CG"=>"Congo","CD"=>"Congo, the Democratic Republic of the","CK"=>"Cook Islands","CR"=>"Costa Rica",
#             "CI"=>"Cote d'Ivoire","HR"=>"Croatia","CU"=>"Cuba","CY"=>"Cyprus","CZ"=>"Czech Republic",
#             "DK"=>"Denmark","DJ"=>"Djibouti","DM"=>"Dominica","DO"=>"Dominican Republic","EC"=>"Ecuador","EG"=>"Egypt",
#             "SV"=>"El Salvador","GQ"=>"Equatorial Guinea","ER"=>"Eritrea","EE"=>"Estonia","ET"=>"Ethiopia",
#             "FK"=>"Falkland Islands (Malvinas)","FO"=>"Faroe Islands","FJ"=>"Fiji","FI"=>"Finland","FR"=>"France",
#             "GF"=>"French Guiana","PF"=>"French Polynesia","TF"=>"French Southern Territories","GA"=>"Gabon",
#             "GM"=>"Gambia","GE"=>"Georgia","DE"=>"Germany","GH"=>"Ghana","GI"=>"Gibraltar","GR"=>"Greece",
#             "GL"=>"Greenland","GD"=>"Grenada","GP"=>"Guadeloupe","GU"=>"Guam","GT"=>"Guatemala","GG"=>"Guernsey",
#             "GN"=>"Guinea","GW"=>"Guinea-Bissau","GY"=>"Guyana","HT"=>"Haiti","HM"=>"Heard Island and McDonald Islands",
#             "VA"=>"Holy See (Vatican City State)","HN"=>"Honduras","HK"=>"Hong Kong","HU"=>"Hungary","IS"=>"Iceland",
#             "IN"=>"India","ID"=>"Indonesia","IR"=>"Iran, Islamic Republic of","IQ"=>"Iraq","IE"=>"Ireland",
#             "IM"=>"Isle of Man","IL"=>"Israel","IT"=>"Italy","JM"=>"Jamaica","JP"=>"Japan","JE"=>"Jersey",
#             "JO"=>"Jordan","KZ"=>"Kazakhstan","KE"=>"Kenya","KI"=>"Kiribati","KP"=>"Korea, Democratic People's Republic of",
#             "KR"=>"Korea, Republic of","KW"=>"Kuwait","KG"=>"Kyrgyzstan","LA"=>"Lao People's Democratic Republic","LV"=>"Latvia",
#             "LB"=>"Lebanon","LS"=>"Lesotho","LR"=>"Liberia","LY"=>"Libya","LI"=>"Liechtenstein","LT"=>"Lithuania",
#             "LU"=>"Luxembourg","MO"=>"Macao","MK"=>"Macedonia, the former Yugoslav Republic of","MG"=>"Madagascar",
#             "MW"=>"Malawi","MY"=>"Malaysia","MV"=>"Maldives","ML"=>"Mali","MT"=>"Malta","MH"=>"Marshall Islands",
#             "MQ"=>"Martinique","MR"=>"Mauritania","MU"=>"Mauritius","YT"=>"Mayotte","MX"=>"Mexico",
#             "FM"=>"Micronesia, Federated States of","MD"=>"Moldova, Republic of","MC"=>"Monaco","MN"=>"Mongolia",
#             "ME"=>"Montenegro","MS"=>"Montserrat","MA"=>"Morocco","MZ"=>"Mozambique","MM"=>"Myanmar","NA"=>"Namibia",
#             "NR"=>"Nauru","NP"=>"Nepal","NL"=>"Netherlands","NC"=>"New Caledonia","NZ"=>"New Zealand","NI"=>"Nicaragua",
#             "NE"=>"Niger","NG"=>"Nigeria","NU"=>"Niue","NF"=>"Norfolk Island","MP"=>"Northern Mariana Islands","NO"=>"Norway",
#             "OM"=>"Oman","PK"=>"Pakistan","PW"=>"Palau","PS"=>"Palestinian Territory, Occupied","PA"=>"Panama",
#             "PG"=>"Papua New Guinea","PY"=>"Paraguay","PE"=>"Peru","PH"=>"Philippines","PN"=>"Pitcairn","PL"=>"Poland",
#             "PT"=>"Portugal","PR"=>"Puerto Rico","QA"=>"Qatar","RE"=>"Reunion","RO"=>"Romania","RU"=>"Russian Federation",
#             "RW"=>"Rwanda","BL"=>"Saint Barthelemy","SH"=>"Saint Helena, Ascension and Tristan da Cunha",
#             "KN"=>"Saint Kitts and Nevis","LC"=>"Saint Lucia","MF"=>"Saint Martin (French part)",
#             "PM"=>"Saint Pierre and Miquelon","VC"=>"Saint Vincent and the Grenadines","WS"=>"Samoa","SM"=>"San Marino",
#             "ST"=>"Sao Tome and Principe","SA"=>"Saudi Arabia","SN"=>"Senegal","RS"=>"Serbia","SC"=>"Seychelles",
#             "SL"=>"Sierra Leone","SG"=>"Singapore","SX"=>"Sint Maarten (Dutch part)","SK"=>"Slovakia","SI"=>"Slovenia",
#             "SB"=>"Solomon Islands","SO"=>"Somalia","ZA"=>"South Africa","GS"=>"South Georgia and the South Sandwich Islands",
#             "SS"=>"South Sudan","ES"=>"Spain","LK"=>"Sri Lanka","SD"=>"Sudan","SR"=>"Suriname","SJ"=>"Svalbard and Jan Mayen",
#             "SZ"=>"Swaziland","SE"=>"Sweden","CH"=>"Switzerland","SY"=>"Syrian Arab Republic","TW"=>"Taiwan, Province of China",
#             "TJ"=>"Tajikistan","TZ"=>"Tanzania, United Republic of","TH"=>"Thailand","TL"=>"Timor-Leste","TG"=>"Togo",
#             "TK"=>"Tokelau","TO"=>"Tonga","TT"=>"Trinidad and Tobago","TN"=>"Tunisia","TR"=>"Turkey","TM"=>"Turkmenistan",
#             "TC"=>"Turks and Caicos Islands","TV"=>"Tuvalu","UG"=>"Uganda","UA"=>"Ukraine","AE"=>"United Arab Emirates",
#             "GB"=>"United Kingdom","UM"=>"United States Minor Outlying Islands","UY"=>"Uruguay",
#             "UZ"=>"Uzbekistan","VU"=>"Vanuatu","VE"=>"Venezuela, Bolivarian Republic of","VN"=>"Viet Nam",
#             "VG"=>"Virgin Islands, British","VI"=>"Virgin Islands, U.S.","WF"=>"Wallis and Futuna","EH"=>"Western Sahara",
#             "YE"=>"Yemen","ZM"=>"Zambia","ZW"=>"Zimbabwe"}

COUNTRIES = {"US"=>"United States","CA"=>"Canada"}

DEFAULT_SUBDOMAIN = 'www'
ADMIN_SUBDOMAIN = APP_CONFIG['admin_subdomain']
PARTNER_SUBDOMAIN = APP_CONFIG['partner_subdomain']

TOTAL_SMS_EMAIL = 3

DAYS = [["Monday",1],["Tuesday",2],["Wednesday",3],["Thursday",4],["Friday",5],["Saturday",6],["Sunday",0]]

DATES_MONTH = [["1st", 1], ["2nd", 2], ["3rd", 3], ["4th", 4], ["5th", 5], ["6th", 6], ["7th", 7], ["8th", 8], ["9th", 9], ["10th", 10], ["11th", 11], ["12th", 12], ["13th", 13], ["14th", 14], ["15th", 15], ["16th", 16], ["17th", 17], ["18th", 18], ["19th", 19], ["20th", 20], ["21st", 21], ["22nd", 22], ["23rd", 23], ["24th", 24], ["25th", 25], ["26th", 26], ["27th", 27], ["28th", 28], ["29th", 29], ["30th", 30], ["31st", 31]]

PHONE_TYPE = [["Home","Home"], ["Office","Office"], ["Mobile","Mobile"], ["Fax","Fax"]]

STAGING = "admin"

LIVE_HOST = "yestrak.com"

LOCAL_HOST = "lvh.me:3000"

LIVE_PRICING_PAGE = "http://yestrak.com/pricing/"

TIME = ["12AM","1AM","2AM","3AM","4AM","5AM","6AM", "7AM", "8AM", "9AM", "10AM", "11AM", "12PM", "1PM", "2PM", "3PM", "4PM", "5PM", "6PM", "7PM","8PM", "9PM", "10PM", "11PM"]

ADMIN_MAIL = "mayank.jani@softwebsolutions.com"

CARD_TYPE = ["Visa", "MasterCard", "AmEx", "Diners", "Discover", "JSB"]

ADMIN_URL = APP_CONFIG['admin_url']
PARTNER_URL = APP_CONFIG['partner_url']
