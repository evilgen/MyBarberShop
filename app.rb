require 'rubygems'            
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def get_db
	db = SQLite3::Database.new 'BarberShop.db'
	db.results_as_hash = true
	return db
end

def is_barber_exists? db, name
	db.execute('select * from Barbers Where Barber = ?', [name]).length > 0
end

def seed_db db, barbers
	barbers.each do |barber|
		if !is_barber_exists? db, barber
			db.execute 'insert into Barbers (Barber) values (?)',[barber]	
		end	
	end	
end

configure do 
	db = get_db
	db.execute 'CREATE TABLE IF NOT EXISTS
	`Users`
	(
		`id`	INTEGER PRIMARY KEY AUTOINCREMENT,
		`Name`	TEXT,
		`Phone`	TEXT,
		`DateStamp`	TEXT,
		`Barber`	TEXT,
		`Color`	TEXT
	)'
	db.execute 'CREATE TABLE IF NOT EXISTS 
	`Barbers`
	(
		`id`	INTEGER PRIMARY KEY AUTOINCREMENT,
		`Barber`	TEXT
	)'
	seed_db db, ['Walter White', 'Jessie Pinkman', 'Gus Fring', 'Mike Ehrmantraut']
end

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

get '/showusers' do
db = get_db
@results = db.execute 'select * from Users order by id desc'	
	erb :showusers
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

db = get_db
db.execute 'insert into
Users
(
	Name,
	Phone,
	DateStamp,
	Barber,
	Color
)
values (?, ?, ?, ?, ?)', [@username, @phone, @datetime, @master, @color]

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