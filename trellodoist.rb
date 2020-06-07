require 'trello'
require 'todoist'
load 'config.rb'

Trello.configure do |config|
  config.developer_public_key = TRELLO_KEY
  config.member_token = TRELLO_TOKEN
end

@client = Todoist::Client.create_client_by_token(TODOIST_TOKEN)

user = Trello::Member.find("me")
# content = "Trellopaper\nCaptured on " + Time.now.to_s.split(" ")[0] + "\n"
user.boards.each do |board|
  if BOARDS.include? board.name
    # puts board.inspect;
    puts "Processing #{board.name}"
    lists = board.lists.find_all {|l| TARGET_LISTS.include? l.name }
    lists.sort_by! do |list|
      TARGET_LISTS.index(list.name)
    end
    # board_title_included = false
    lists.each do |list|
      # indent = "  "
      cards = list.cards
      if cards.any?
        # if !board_title_included
        #   content << "#{board.name}:\n  #{board.url}\n"
        #   board_title_included = true
        # end
        # if TARGET_LISTS.length > 1
        #   content << "#{indent}#{list.name}:\n" 
        #   indent = "    "
        # end
        cards.each do |card|
          # content << "#{indent}- #{card.name}\n"
          # content << "#{indent}  #{card.desc.lines[0]}\n" unless card.desc.empty?
          # card.attachments.each do |attachment|
          #   if attachment.url && (!EXCLUDED_ATTACHMENTS.include? attachment.url[-4..-1])
          #     content << "#{indent}  #{attachment.url}\n"
          #   end
          # end
          @client.sync_items.add({content: card.name})
          # card.checklists.each do |checklist|
          #   list = Trello::Checklist.find checklist.id
          #   list.items.each do |item|
          #     content << "#{indent}  - #{item.name}\n" if item.state == "incomplete"
          #   end
          # end
        end
        @client.sync_items.collection
      end
    end
  end
end
