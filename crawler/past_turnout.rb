map = {"고양시일산구"=>["고양시일산동구","고양시일산서구"],"용인시"=>["용인시처인구","용인시수지구","용인시기흥구"],"천안시"=>["천안시동남구","천안시서북구"],"연기군"=>["연기군"],"당진군"=>["당진시"],"창원시"=>["창원시의창구","창원시성산구"],"마산시"=>["창원시마산합포구","창원시마산회원구"],"진해시"=>["창원시진해구"],"북제주군"=>[],"남제주군"=>[]}
{"20040415"=>17,"20080409"=>18}.each do |k,v|
  Province.all.each do |p|
    next if p.name == "세종특별자치시"
    uri = URI.parse("http://info.nec.go.kr/electioninfo/electionInfo_report.xhtml?electionId=0000000000&requestURI=%2Felectioninfo%2F0000000000%2Fvc%2Fvcvp01.jsp&topMenuId=VC&secondMenuId=VCVP&menuId=VCVP01&statementId=VCVP01_%233&oldElectionType=1&electionType=2&electionName="+k+"&cityCode="+p.code+"&timeCode=0")
    http = Net::HTTP.new(uri.host, uri.port)
    resp = http.get(uri.request_uri)
    doc = Nokogiri::HTML(resp.body)
    doc.css("#table01 tbody tr")[1..-1].each do |d|
      d = d.css("td")
      name = d[0].inner_text.strip.match(/([^(]*)/)[1]
      if map[name].nil?
        region = Region.where(:province_id=>p.id, :name=>name).first
        total = d[1].inner_text.match(/([^(]*)/)[1].gsub(",","").to_f
        1.upto(10) do |i|
          count = d[i+1].inner_text.match(/([^(]*)/)[1].gsub(",","").to_f
          Turnout.create(:time=>i, :region_id=>region.id, :rate=>count/total, :index=>v)
        end
      else
        map[name].each do |n|
          region = Region.where(:name=>n).first
          total = d[1].inner_text.match(/([^(]*)/)[1].gsub(",","").to_f
          1.upto(10) do |i|
            count = d[i+1].inner_text.match(/([^(]*)/)[1].gsub(",","").to_f
            Turnout.create(:time=>i, :region_id=>region.id, :rate=>count/total, :index=>v)
          end
        end
      end
    end
  end
end
