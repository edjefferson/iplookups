require 'geo_ip'
require 'mysql'

#heroku config:add GEOIPKEY=

GeoIp.api_key=ENV['GEOIPKEY']

#heroku config:add DB_HOST= DB_USER= DB_PW= DB_NAME=

con = Mysql.new ENV['DB_HOST'],ENV['DB_USER'],ENV['DB_PW'],ENV['DB_NAME']

reviews = con.query("select r.id, r.purchaser_line_item_id, r.reviewers_ip_address from reviews r order by r.id")
count = reviews.num_rows
puts reviews.num_rows
puts 'reviews loaded, checking IPs'

maxid = con.query("select max(review_id) from reviewip")

check = maxid.fetch_row[0]

ticker = 0.0

reviews.each do |y|
  if y[0].to_i<=check.to_i
    puts "already done"
  else  
    begin
      puts y[2]
      x = GeoIp.geolocation(y[2])
      
     
  
      con.query("INSERT INTO reviewip(review_id, purchaser_line_item_id, ipaddress, country_code, country_name, region_name, city, latitude, longitude) VALUES('#{y[0]}','#{y[1]}','#{y[2]}','#{x[:country_code]}','#{Mysql.escape_string(x[:country_name])}','#{Mysql.escape_string(x[:region_name])}','#{Mysql.escape_string(x[:city])}','#{x[:latitude]}','#{x[:longitude]}')")

rescue
    puts "done fucked up"
        sleep 5
    
    
   retry
  end
end
ticker +=1 
percent = 100 * (ticker/count)
puts percent
end
con.close