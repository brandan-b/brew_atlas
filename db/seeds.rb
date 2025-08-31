require 'json'
require 'open-uri'
require 'faker'

puts "clearing data..."
BreweryTag.delete_all
Tag.delete_all
Brewery.delete_all
Country.delete_all

def fetch_json(url)
  URI.open(url, read_timeout: 20).read
rescue => e
  puts "fetch failed: #{url} (#{e.class})"
  nil
end
countries_json = fetch_json("https://restcountries.com/v3.1/all?fields=name,cca2,region,capital,latlng,population,area")
countries = []
if countries_json
  JSON.parse(countries_json).each do |c|
    name = c.dig("name", "common")
    code = c["cca2"]
    region = c["region"]
    capital = Array(c["capital"]).first
    latlng = c["latlng"] || [nil, nil]
    countries << { name: name, code: code, region: region, capital: capital, population: c["population"], area: c["area"], lat: latlng[0], lng: latlng[1] }
  end
  puts "loaded #{countries.size} countries from api"
else
  puts "api unavailable, generating fake countries"
  250.times do
    countries << {
      name: Faker::Address.unique.country,
      code: Faker::Base.regexify(/[A-Z]{2}/),
      region: %w[Americas Europe Asia Africa Oceania Antarctica].sample,
      capital: Faker::Address.city,
      population: rand(100_000..200_000_000),
      area: rand(1000..2_000_000),
      lat: Faker::Address.latitude,
      lng: Faker::Address.longitude
    }
  end
end
countries_map = {}
countries.shuffle.each do |attrs|
  next if attrs[:name].blank? || attrs[:code].blank?
  begin
    country = Country.create!(attrs)
    countries_map[country.name.downcase] = country
    countries_map[country.code.downcase] = country
  rescue => e
    # skip invalid rows
  end
end
puts "countries created: #{Country.count}"
breweries_json = fetch_json("https://api.openbrewerydb.org/v1/breweries?per_page=200")
breweries_data = []
if breweries_json
  JSON.parse(breweries_json).each do |b|
    breweries_data << {
      external_id: b["id"],
      name: b["name"],
      brewery_type: b["brewery_type"],
      street: b["street"],
      city: b["city"],
      state: b["state_province"] || b["state"],
      postal_code: b["postal_code"],
      website_url: b["website_url"],
      phone: b["phone"],
      latitude: b["latitude"]&.to_f,
      longitude: b["longitude"]&.to_f,
      country_name: b["country"]
    }
  end
  puts "loaded #{breweries_data.size} breweries from api"
else
  puts "api unavailable, generating fake breweries"
  400.times do
    country = Country.order("RANDOM()").first
    breweries_data << {
      external_id: nil,
      name: Faker::Company.unique.name + " Brewing",
      brewery_type: %w[micro regional brewpub contract large planning proprietor].sample,
      street: Faker::Address.street_address,
      city: Faker::Address.city,
      state: Faker::Address.state_abbr,
      postal_code: Faker::Address.zip_code,
      website_url: "https://#{Faker::Internet.domain_name}",
      phone: Faker::PhoneNumber.phone_number,
      latitude: country&.lat ? country.lat + rand(-5.0..5.0) : Faker::Address.latitude,
      longitude: country&.lng ? country.lng + rand(-5.0..5.0) : Faker::Address.longitude,
      country_name: country&.name || "United States"
    }
  end
end
type_names = breweries_data.map { |b| b[:brewery_type].to_s.strip.downcase }.reject(&:blank?).uniq
type_names.each { |t| Tag.find_or_create_by!(name: t) }
puts "tags created: #{Tag.count}"
created = 0
breweries_data.each do |b|
  cname = b[:country_name].to_s.downcase
  country = countries_map[cname] || countries_map[cname[0,2]]
  next unless country
brewery = Brewery.create!(
    name: b[:name] || "unknown brewery",
    brewery_type: b[:brewery_type] || "unknown",
    street: b[:street],
    city: b[:city] || "unknown",
    state: b[:state],
    postal_code: b[:postal_code],
    website_url: b[:website_url],
    phone: b[:phone],
    latitude: b[:latitude],
    longitude: b[:longitude],
    external_id: b[:external_id],
    country: country
  )
  if (t = Tag.find_by(name: (b[:brewery_type] || "").downcase))
    BreweryTag.create!(brewery: brewery, tag: t)
  end
  created += 1
rescue => e
  # skip invalid rows
end
puts "breweries created: #{Brewery.count} (attempted: #{created})"
total_rows = Country.count + Brewery.count + Tag.count + BreweryTag.count
puts "total rows across all tables: #{total_rows}"
puts "done"
