path = Rails.root.join("db/seeds/#{Rails.env}/seeds.rb")
path = path.sub(Rails.env, "development") unless File.exist?(path)

require path
