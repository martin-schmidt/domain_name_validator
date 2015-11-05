require 'domain_name_validator/config'
require 'zonefile'
require 'net/http'
require 'uri'

class DomainNameValidator

  def self.update_zones
    uri = URI(ROOT_ZONE_URL)
    dnv = DomainNameValidator.new
    dnv.download_zone_file(uri)
    zones = dnv.parse_zone_file
    dnv.write_tlds(zones)
  end

  def download_zone_file(uri)
    puts "# Downloading zones from #{ROOT_ZONE_URL}"
    amount_downloaded = 0
    current_width = 0
    print ' #> 000%'
    Net::HTTP.start(uri.host, uri.port) do |http|
      request = Net::HTTP::Get.new uri.to_s
      http.request request do |response|
        file_size = response['content-length'].to_i
        open ZONE_FILE, 'w' do |io|
          response.read_body do |chunk|
            io.write chunk
            amount_downloaded += chunk.size
            diff = status_bar(file_size, amount_downloaded, current_width)
            current_width += diff
          end
        end
      end
    end
    puts ' ok'
  end

  def status_bar(file_size, amount_downloaded, current_width)
    percentage = (amount_downloaded.to_f / file_size * 100)
    diff = (percentage.to_i/2-current_width)
    if (current_width+percentage.to_i/2 > current_width+1 )
      print "\b" * 6 + '=' * diff.to_i + "> #{percentage.to_i.to_s.rjust(3, "0")}%"
    end
    return diff
  end

  def parse_zone_file
    puts "# Parsing #{ZONE_FILE}"
    zf = Zonefile.from_file(ZONE_FILE)
    zones = zf.records[:ns].map { |hash|
      hash[:name]
    }.map { |string|
      string.split('.')[-1]
    }.uniq
    puts "- #{zones.length} TLDs found."
    return zones
  end

  def write_tlds(zones)
    puts "# Writng TLDs to #{TLD_FILE}"
    File.open(TLD_FILE, 'w') do |f|
      zones.each { |tld| f.puts(tld) }
    end
    puts '- done'
  end
end
