ROOT_ZONE_URL = 'http://www.internic.net/domain/root.zone'
ZONE_FILE     = File.expand_path('../data/root.zone', __FILE__)
TLD_FILE      = File.expand_path('../data/TLD.txt', __FILE__)
require 'zonefile'
require 'net/http'
require 'uri'

task default: :prepare

task :prepare do
  Rake::Task['zones:update'].invoke
end

namespace :zones do
  task :update do
    Rake::Task['zones:download'].invoke
    Rake::Task['zones:parse'].invoke
  end

  task :download do
    puts "# Downloading zones from #{ROOT_ZONE_URL}"
    uri = URI(ROOT_ZONE_URL)
    Net::HTTP.start(uri.host, uri.port) do |http|
      request = Net::HTTP::Get.new uri.to_s
      http.request request do |response|
        file_size = response['content-length'].to_i
        amount_downloaded = 0
        current_width = 0
        open ZONE_FILE, 'w' do |io|
          print ' #> 000%'
          response.read_body do |chunk|
            io.write chunk
            amount_downloaded += chunk.size
            percentage = (amount_downloaded.to_f / file_size * 100)
            if (current_width+percentage.to_i/2 > current_width+1 )
              diff = (percentage.to_i/2-current_width)
              current_width += diff
              print "\b" * 6 + '=' * diff.to_i + "> #{percentage.to_i.to_s.rjust(3, "0")}%"
            end
          end
        end
        puts ' ok'
      end
    end
  end

  task :parse do
    puts "# Reading #{ZONE_FILE}"
    zf = Zonefile.from_file(ZONE_FILE)
    zones = zf.records[:ns].map { |hash|
      hash[:name]
    }.map { |string|
      string.split('.')[-1]
    }.uniq
    puts "- #{zones.length} TLDs found."
    puts "# Writng TLDs to #{TLD_FILE}"
    File.open(TLD_FILE, 'w') do |f|
      zones.each { |tld| f.puts(tld) }
    end
    puts '- done'
  end

end
