module Plaid
  class Call

    BASE_URL = 'https://tartan.plaid.com/'

    # This initializes our instance variables, and sets up a new Customer class.
    def initialize
      Plaid::Configure::KEYS.each do |key|
        instance_variable_set(:"@#{key}", Plaid.instance_variable_get(:"@#{key}"))
      end
    end
   
    # This is a specific route for auth,
    # it returns specific acct info
    def add_account_auth(type, username, password, email)
      post('/auth', type, username, password, email)
      parse_auth_response(@response)
    end
   
    # This is a specific route for connect,
    # it returns transaction information
    def add_account_connect(type,username,password,email)
      post('/connect',type,username,password,email)
      parse_connect_response(@response)
    end

    def get_place(id)
      get('/entity',id)
      parse_place(@response)
    end

    protected

    # Specific parser for auth response
    def parse_auth_response(response)
      parsed = JSON.parse(response)
      case response.code
      when 200
        [code: response.code, access_token: parsed['access_token'], accounts: parsed['accounts']]
      when 201
        [code: response.code, type: parsed['type'], access_token: parsed['access_token'], mfa_info: parsed['mfa_info']]
      else
        [code: response.code, message: parsed]
      end
    end

    def parse_connect_response(response)
      parsed = JSON.parse(response)
      case response.code
      when 200
        [code: response.code, access_token: parsed['access_token'], accounts: parsed['accounts'], transactions: parsed['transactions']]
      when 201  
        [code: response.code, type: parsed['type'], access_token: parsed['access_token'], mfa_info: parsed['mfa_info']]
      else
        [code: response.code, message: parsed]
      end
    end

    def parse_place(response)
      parsed = JSON.parse(response)['entity']
      [code: response.code, category: parsed['category'], name: parsed['name'], id: parsed['_id'], phone: parsed['meta']['contact']['telephone'], location: parsed['meta']['location']]
    end

    private

    def post(path,type,username,password,email)
      url = BASE_URL + path
      @response = RestClient.post url, client_id: self.instance_variable_get(:'@customer_id') ,secret: self.instance_variable_get(:'@secret'), type: type ,credentials: {username: username, password: password} ,email: email
    end

    def get(path,id)
      url = BASE_URL + path
      @response = RestClient.get(url,params: {entity_id: id})
    end

  end
end
