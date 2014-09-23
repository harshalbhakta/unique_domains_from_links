require 'csv'
require 'uri'

filename = ARGV[0]
hosts = {}

def valid?(uri)
  !!URI.parse(uri)
rescue URI::InvalidURIError
  false
end

def get_domain_from_url(url)
  
  if !valid?(url)
    return nil
  end

  url = "http://#{url}" if URI.parse(url).scheme.nil?
  host = URI.parse(url).host
  if host != nil
    host.start_with?('www.') ? host[4..-1] : host
  else
    nil
  end
end

CSV.foreach(filename) do |row|
  if row[0].strip =~ /\A#{URI::regexp}\z/
    host =  get_domain_from_url(row[0])
    
    if hosts[host] == nil
      hosts[host] = 0
    end

    hosts[host] += 1
  end
end

CSV.open("unique_domains.csv", "w") do |csv|
  csv << ["host", "count"]
  hosts.sort_by{|k,v| v}.reverse.each do |host, count|
    csv << ["#{host}", "#{count}"]
  end
end
