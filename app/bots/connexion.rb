include Facebook::Messenger

Facebook::Messenger::Subscriptions.subscribe

Facebook::Messenger::Thread.set(
  setting_type: 'greeting',
  greeting: {
    text: 'Hey there! Anything I can help with?'
  }
)

Bot.on :message do |message|
  resp = parse_message(message.text)

  if resp[:type] == "file"
    Bot.deliver(
      recipient: message.sender,
       message: {
        attachment: {
          type: 'file',
          payload: {
            url: resp[:url]
          }
        }
      }
    )
  elsif resp[:type] == "text"
    Bot.deliver(
      recipient: message.sender,
      message: {
        text: resp[:text]
      }
    )
  end

end

def parse_message(message)
  case message 
  when /Cutsheets for project# (\d+)/
    retrieve_cutsheets($1)
  when /Fixtures for project# (\d+)/
    retrieve_fixtures($1)
  when /Shipments for project# (\d+)/
    retrieve_shipments($1)
  else 
    {
      type: "text",
      text: "Sorry, I don't understand that"
    }
  end
end

def retrieve_cutsheets(number)

end

def retrieve_fixtures(number)
  @project = JobProject.find(number.to_i)
  @fixtures = @project.bom.fixtures
  resp = { type: "text" }
  resp[:text] = @fixtures.map{ |f| f.summary }.join("\n")[0...310]
  resp
end

def retrieve_shipments(number)
  @project = JobProject.find(number)
  @fixtures = @project.bom.fixtures
  resp = { type: "text" }
  resp[:text] = @fixtures.map { |f| f.shipment_header + "\n" + f.shipments.map {|s| s.summary }.join("\n") }.join("\n")[0...310]
  resp
end



