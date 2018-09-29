require 'trello'
load 'config.rb'

Trello.configure do |config|
  config.developer_public_key = TRELLO_KEY
  config.member_token = TRELLO_TOKEN
end

user = Trello::Member.find("me")
content = ""
boards = user.boards.sort_by do |board|
  PRIORITY_BOARDS.index(board.name) || PRIORITY_BOARDS.length
end
boards.each do |board|
  if !board.closed? && board.starred # (BOARDS.include? board.name)
    # puts board.inspect;
    puts "Processing #{board.name}"
    lists = board.lists.find_all {|l| TARGET_LISTS.include? l.name }
    lists.sort_by! do |list|
      TARGET_LISTS.index(list.name)
    end
    board_title_included = false
    lists.each do |list|
      indent = "  "
      cards = list.cards
      if cards.any?
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
          # content << "#{indent}  #{card.desc.lines[0]}\n" unless card.desc.empty?
          # card.attachments.each do |attachment|
          #   if attachment.url && (!EXCLUDED_ATTACHMENTS.include? attachment.url[-4..-1])
          #     content << "#{indent}  #{attachment.url}\n"
          #   end
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
# puts content
File.write FILE_PATH, content
