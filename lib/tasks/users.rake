namespace :users do
  desc "Creates a new admin user with given name and email"
  task :create_admin, [:name, :email] => :environment do |t, args|
    user = User.new(:nickname => args.name, :username => args.name, :email => args.email, :password => 'admin', :password_confirmation => 'admin', :role => 'admin')
    if user.save
      puts "User '#{user.username}' was successfully created :-)"
    else
      puts "User '#{user.username}' could not be created :-("
    end
  end
end
