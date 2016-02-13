require 'rubygems'            
require 'sinatra'
require 'sinatra/reloader'

get '/' do
 	@message = 'Hello, this is not original page!'
	erb "#{@message}"			
end

get '/about' do
	erb :about
end

get '/visit' do
	erb :visit
end

get '/contacts' do
	erb :contacts
end

post '/visit' do
	@username = params[:username]
	@phone = params[:phone]
	@datetime = params[:datetime]
	@master = params[:master]
	@color = params[:colorpicker]

#хеш ошибок при пропущенных полях во вкладке "Записаться"
	h1 = {
		:username => "Ведите имя",
		:phone => "Введите телефон",
		:datetime => "Введите дату и время"
	}

	@error = h1.select{|key,_| params[key]==''}.values.join(", ")
	
	if @error != ""
		erb :visit
	else	

		f = File.open './public/users.txt', 'a'                                                            
		f.write "Client name: #{@username}, Phone number: #{@phone}, Date and time: #{@datetime}, Master name: #{@master}, Selected color: #{@color}\n"
		f.close

		@message = "Thank you #{@username}, we will wait for you."

		erb "#{@message}"
	end
end

post '/contacts' do
	@email = params[:email]
	@letter = params[:letter]

	h2 = {
		:email => "Введите ваш электронный адрес",
		:letter => "Ваше письмо пустое"
	}

	@error = h2.select{|key,_| params[key]==''}.values.join(", ")
	
	if @error != ""
		erb :contacts
	else
		f = File.open './public/contacts.txt', 'a'                                                            
		f.write "Client email - #{@email}:\nMessage:\n#{@letter}.\n\n"
		f.close
		@message = "Thank you for your message."

		erb "#{@message}"
	end
end