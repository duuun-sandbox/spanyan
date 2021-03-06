require 'aws-record'
# require 'httparty'
require 'json'

class Spa
  include Aws::Record
  set_table_name ENV['DDB_TABLE']
  string_attr :id, hash_key: true
  string_attr :name
  string_attr :area
  string_attr :prefecture
  string_attr :effect
  string_attr :image_url
end

def lambda_handler(event:, context:)
  area = event['queryStringParameters']['area']

  scans = Spa.scan(
    filter_expression: "contains(#B, :b)",
    expression_attribute_names: {
        "#B" => "area"
    },
    expression_attribute_values: {
        ":b" => "#{area}"
    }
  )

  spas = []
  scans.each do |spa|
    spas << spa.to_h
  end

  # Parameters
  # ----------
  # event: Hash, required
  #     API Gateway Lambda Proxy Input Format
  #     Event doc: https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html#api-gateway-simple-proxy-for-lambda-input-format

  # context: object, required
  #     Lambda Context runtime methods and attributes
  #     Context doc: https://docs.aws.amazon.com/lambda/latest/dg/ruby-context.html

  # Returns
  # ------
  # API Gateway Lambda Proxy Output Format: dict
  #     'statusCode' and 'body' are required
  #     # api-gateway-simple-proxy-for-lambda-output-format
  #     Return doc: https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html

  # begin
  #   response = HTTParty.get('http://checkip.amazonaws.com/')
  # rescue HTTParty::Error => error
  #   puts error.inspect
  #   raise error
  # end

  {
    statusCode: 200,
    body: {
      spas: spas
      # location: response.body
    }.to_json
  }
end
