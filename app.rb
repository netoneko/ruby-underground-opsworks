connection_settings = YAML.load_file('./config/database.yml')[ENV['RACK_ENV']]
ActiveRecord::Base.establish_connection(connection_settings)

class App < Grape::API
  REDIS = ::Redis.new(url: ENV['REDIS_URL'])

  format 'json'

  get '/' do
    {status: 'ok', message: 'Hello, Ruby Underground!'}
  end

  resource :checks do
    desc 'Check database connection'
    get :database do
      ::ActiveRecord::Base.connection.execute('SELECT 1')
      {status: 'ok', message: 'Database connection established'}
    end

    desc 'Check cache connection'
    get :cache do
      REDIS.ping
      {status: 'ok', message: 'Cache connection established'}
    end

    if ENV['DEBUG_ENV']
      desc 'Dumb all environment variables (do not do it in production)!'
      get :env do
	{status: 'ok', environment: ENV.to_h}
      end
    end
  end
end

