require 'trello'
load 'config.rb'

Trello.configure do |config|
  config.developer_public_key = TRELLO_KEY
  config.member_token = TRELLO_TOKEN
end

user = Trello::Member.find("me")
content = ""
user.boards.each do |board|
  if !board.closed?
    lists = board.lists.find_all {|l| TARGET_LISTS.include? l.name }
    lists.sort_by! do |list|
      TARGET_LISTS.index(list.name)
    end
    board_title_included = false
    if lists.any?
      lists.each do |list|
        indent = "  "
        cards = list.cards
        if cards.any? && (!EXCLUDED_BOARDS.include? board.name)
          if !board_title_included
            content << "#{board.name}:\n  #{board.url}\n"
            board_title_included = true
          end
          if TARGET_LISTS.length > 1
            content << "#{indent}#{list.name}:\n" 
            indent = "    "
          end
          cards.each do |card|
            content << "#{indent}- #{card.name}\n"
            ## don't want this at the moment
            # content << "   #{card.desc}\n" if !card.desc.empty?
            ## this is not working when there are a lot of cards, I think it's an API call per card
            # card.attachments.each do |attachment|
            #   content << "   #{attachment.url}\n" if attachment.url
            # end
            card.checklists.each do |checklist|
              list = Trello::Checklist.find checklist.id
              list.items.each do |item|
                content << "#{indent}  - #{item.name}\n" if item.state == "incomplete"
              end
            end
          end
        end
      end
    end
  end
end
puts content
File.write FILE_PATH, content
