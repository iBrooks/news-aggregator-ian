require 'sinatra'
require 'sinatra/reloader'
require 'pry'
require 'csv'

configure :development, :test do
  require 'pry'
end

Dir[File.join(File.dirname(__FILE__), 'lib', '**', '*.rb')].each do |file|
  require file
  also_reload file
end

get '/' do
  erb :index
end
get '/articles' do
  @articles = CSV.read("articles.csv")
  erb :articles
end
get '/articles/new' do
  @errors = []
  erb :newArticle
end
post '/articles/new' do
  @errors = []
  @errors.push('Please enter a valid URL.') if !verifyURL(params['url'])
  @errors.push('Please enter a title.') if !verifyTitle(params['title'])
  @errors.push('Please enter a description of at least 20 characters.') if !verifyDescription(params['description'])
  @errors.push('This link has already been submitted') if checkDuplicate(params['url'])


  if @errors.count == 0
    addToCSV(params['url'], params['title'], params['description'])
    redirect "/articles"
  else
    @errorMessage = "Revision required:"
    @url = params['url']
    @title = params['title']
    @description = params['description']
    erb :newArticle
  end
end

def verifyURL(url)
  url.include?("http://") || url.include?("https://")
end

def verifyTitle(title)
  title.length > 0
end

def verifyDescription(description)
  description.length >= 20
end

def addToCSV(url, title, description)
  CSV.open("articles.csv","a") do |csv|
    csv.add_row([url.to_s, title.to_s, description.to_s])
  end
  redirect "/articles"
end

def checkDuplicate(url)
  csvArray = CSV.read("articles.csv")
  csvArray.each do |row|
    if row[0] == url
      return true
    end
  end
  return false
end

def clean_csv
  CSV.open("articles.csv", "wb") do |csv|
    csv
  end
end