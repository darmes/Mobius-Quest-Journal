#===============================================================================
# Mobius' Quest Journal
# Author: Mobius XVI
# Version: 2.3
# Date: 28 MAY 2020
#===============================================================================
#
# Introduction:
#
#   I wanted to create a plain looking, but robust quest/journal system that 
#   was akin to the one found in Skyrim. I also wanted to make it as user 
#   friendly as possible while still giving you control over implementation. 
#   I hope you enjoy it!
#
# Instructions:
#
#  - Place this script below all the default scripts but above main.
#
#  - Visit the forums for detailed instructions as well as two video tutorials
#    https://forums.rpgmakerweb.com/index.php?threads/mobiuss-quest-journal.19144/
#
# Issues/Bugs/Possible Bugs:
#
#   - Q. Why don't the changes I made to my quests show up during playtesting?
#   - A. Simply put, the script is not save game compatible. This is - 
#     unfortunately - the biggest current limitation of the script. If you start 
#     a playtest, save your game, and exit, and then make changes to the quests 
#     when you load up the save game it will not have any of your changes to the 
#     quests. But any changes you make should display correctly as long as you 
#     start a new game. My recommendation for getting around this problem is 
#     utilizing the debug (F9) menu to set quests to the desired state for testing, 
#     and always starting a new game.
#
#   - Q. Why does the first quest always show in the journal even if it hasn't 
#     been discovered yet?
#   - A. The journal needs at least one quest to function, so the first quest 
#     gets automatically discovered upon starting a new game. You can work 
#     around this limitation by adding a "starting" phase to it that doesn't 
#     give anything away like "You're on a new adventure!".
#
#  Credits/Thanks:
#    - Mobius XVI, author
#    - Special thanks to Zeriab. I borrowed the name for two of my classes 
#       from the Quest Book script, and overall I'd say it influenced my design.
#    - KK20, for finding a fairly obscure bug in my code
#
#  License
#    
#    This script is licensed under a Creative Commons Attribution-ShareAlike 3.0 Unported license. 
#    A human readable summary is available here: http://creativecommons.org/licenses/by-sa/3.0/deed.en_US
#    The full license is availble here: http://creativecommons.org/licenses/by-sa/3.0/legalcode
#    In addition, this script is only authorized to be posted to the forums on RPGMakerWeb.com.
#    Further, if you do decide to use this script in a commercial product, 
#    I'd ask that you let me know via a post here or a PM. Thanks.
#
#==============================================================================
# CUSTOMIZATION START
#==============================================================================
module Mobius
  module Quests
    #--------------------------------------------------------------------------
    # * Module constants
    #--------------------------------------------------------------------------
      CREATE_ENCRYPTED = false              # Determines encrypted file creation
      USE_ENCRYPTED = false                 # Sets use of encrypted file
      QUEST_FILENAME = "Data/QuestData.txt" # Sets unencrypted filename
      USE_SWITCHES_VARIABLES = true         # Sets use of switches/variables
      FIRST_SWITCH_ID = 2                   # Sets the first switch ID
      FIRST_VARIABLE_ID = 2                 # Sets the first variable ID
      RENAME_SWITCHES_VARIABLES = true      # Determines renaming of switches/variables
      SHOW_ALL_QUESTS = true               # DEBUGGING FEATURE - Always shows all quests  
  end
end
#==============================================================================
# CUSTOMIZATION END -- DON'T EDIT BELOW THIS LINE!!!
#==============================================================================

#==============================================================================
# ** Game Quest -- Mobius
#------------------------------------------------------------------------------
#  The class that holds quests. Each instance of Game Quest is used to hold
#  one quest.
#==============================================================================
class Game_Quest
  #--------------------------------------------------------------------------
  # * Configuration Binding
  #--------------------------------------------------------------------------
  include Mobius::Quests
  #--------------------------------------------------------------------------
  # * Class Variables
  #--------------------------------------------------------------------------
    @@total_quests = 0           # Used to track number of quest objects

  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
    attr_reader   :id            # ID
    attr_reader   :name          # Name
    attr_reader   :known         # Known status (true / false)
    attr_reader   :completed     # Completed status (true / false)
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(name = "", info_array = [] )
    @id = @@total_quests
    @@total_quests += 1
    @name = name
    @phase = 0
    @phase_variable = @id + FIRST_VARIABLE_ID
    @known = false
    @known_switch = ( (@id * 2) + FIRST_SWITCH_ID )
    @completed = false
    @completed_switch = ( (@id * 2) + 1 + FIRST_SWITCH_ID )
    # The info array contains text that corresponds to the current phase
    # of the quest. So, you simply need to get the info in the i-th position
    # of the array for the i-th phase
    @info_array = info_array
    # Call rename if set in customization
    rename if (RENAME_SWITCHES_VARIABLES and USE_SWITCHES_VARIABLES)
  end
  #--------------------------------------------------------------------------
  # * Get Current Info
  # Returns text info for the current phase
  #--------------------------------------------------------------------------
  def get_current_info
    @info_array.fetch(@phase, "").clone
  end
  #--------------------------------------------------------------------------
  # * Phase=
  # Sets the quest phase 
  #--------------------------------------------------------------------------
  def phase=(value)
    # Set phase
    @phase = value
    if USE_SWITCHES_VARIABLES
      # Set phase variable
      $game_variables[@phase_variable] = value
      # Refresh map
      $game_map.need_refresh = true
    end
  end
  #--------------------------------------------------------------------------
  # * Discover
  # Changes quest state known to true 
  #--------------------------------------------------------------------------
  def discover
    # Set known flag
    @known = true
    if USE_SWITCHES_VARIABLES
      # Set known switch
      $game_switches[@known_switch] = true
      # Refresh map
      $game_map.need_refresh = true
    end
  end
  #--------------------------------------------------------------------------
  # * Complete
  # Changes quest state completed to true 
  #--------------------------------------------------------------------------
  def complete
    # Set completed flag
    @completed = true
    if USE_SWITCHES_VARIABLES
      # Set completed switch
      $game_switches[@completed_switch] = true
      # Refresh map
      $game_map.need_refresh = true
    end
  end
  #--------------------------------------------------------------------------
  # * Data Check
  # Updates quest phase, known, and completed with switch/variable  
  #--------------------------------------------------------------------------
  def data_check
    if USE_SWITCHES_VARIABLES
      @phase = $game_variables[@phase_variable]
      @known = $game_switches[@known_switch]
      @completed = $game_switches[@completed_switch]
    end
  end
  #--------------------------------------------------------------------------
  # * Rename
  # Renames associated switches and variables 
  #--------------------------------------------------------------------------
  def rename
    str = @name + " Phase"
    $data_system.variables[@phase_variable] = str
    str = @name + " Known"
    $data_system.switches[@known_switch] = str
    str = @name + " Completed"
    $data_system.switches[@completed_switch] = str
    save_data($data_system, "Data/System.rxdata")
  rescue
    print(self.to_s)
    raise
  end
  #--------------------------------------------------------------------------
  # * to_s
  # Returns quest object data as string
  # Mostly used for debugging purposes
  #--------------------------------------------------------------------------
  def to_s
    "Quest ID: #{@id}\n" +
    "Quest Name: #{@name}\n" +
    "Quest Info:\n" +
    @info_array.join("\n")
  end
end

#==============================================================================
# ** Game_Quests
#------------------------------------------------------------------------------
#  This class handles the Game Quest arrays. Refer to "$game_quests" for the
#  instance of this class.
#==============================================================================
class Game_Quests
  #--------------------------------------------------------------------------
  # * Configuration Binding
  #--------------------------------------------------------------------------
  include Mobius::Quests
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
    attr_accessor :all_quests           # Array of all quest objects
    attr_accessor :current_quests       # Array of all current quest objects
    attr_accessor :completed_quests     # Array of all completed quest objects
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    @all_quests = []
    @current_quests = []
    @completed_quests = []
    setup
  end
  #--------------------------------------------------------------------------
  # * Add Quest - adds a quest object to the all_quests array
  #--------------------------------------------------------------------------
  def add_quest(quest)
    @all_quests.push(quest)
  end
  #--------------------------------------------------------------------------
  # * Sort Quests
  # Refreshes the current_quests and completed_quests arrays
  # Also sorts them as well as the all quests array by ID's
  #--------------------------------------------------------------------------
  def sort_quests
    # Sort the all_quests array by ID
    @all_quests.sort {|a,b| a.id <=> b.id }
    # Reset the current and completed quest arrays
    @current_quests = []
    @completed_quests = []
    # Push known and completed quests to their appropiate arrays
    for quest in @all_quests
      if quest.known and quest.completed
        @completed_quests.push(quest)
      elsif quest.known
        @current_quests.push(quest)
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Discover Quest - uses quest name or id to change state of quest to known
  #--------------------------------------------------------------------------
  def discover_quest(name_or_id)
    make_quest_change(name_or_id, :discover)
  end
  # Create shorthand name for eventing scripts
  alias dq discover_quest
  #--------------------------------------------------------------------------
  # * Set Phase - uses quest name or id to change phase
  #--------------------------------------------------------------------------
  def set_phase(name_or_id, phase)
    make_quest_change(name_or_id, :phase=, phase)
  end
  # Create shorthand name for eventing scripts
  alias sp set_phase
  #--------------------------------------------------------------------------
  # * Complete Quest
  # Uses quest name or id to change state of quest to complete
  #--------------------------------------------------------------------------
  def complete_quest(name_or_id)
    make_quest_change(name_or_id, :complete)
  end
  # Create shorthand name for eventing scripts
  alias cq complete_quest
  #--------------------------------------------------------------------------
  # * Try Lookup Quest
  # Uses quest name or id to get the quest object
  #--------------------------------------------------------------------------
  def try_lookup_quest(name_or_id)
    # Check if passed value is ID
    if name_or_id.is_a?(Integer)
      # Check if ID is valid
      if @all_quests[name_or_id].is_a?(Game_Quest)
        # Return found quest
        return true, @all_quests[name_or_id]
      # If ID is invalid
      else 
        # Return error message
        message = "The quest ID provided (#{name_or_id}) is not valid." +
                  "Check that the quest exists and that the id is correct."
        return false, message
      end
    # Else is it a string
    elsif name_or_id.is_a?(String)
      # Look up quest using name
      quest_to_change = @all_quests.find {|quest| quest.name == name_or_id}
      # Check if quest is valid
      if quest_to_change.is_a?(Game_Quest)
        # Return found quest
        return true, quest_to_change
      # If quest is invalid
      else     
        # Make newlines literal to call attention to them
        name_or_id = name_or_id.gsub("\n",'<line break>')
        # Return error message
        message = "The quest name '#{name_or_id}' was not found.\n" +
              "Check that the quest exists and that the spelling\n" +
              "is correct."
        return false, message
      end
    # If input is invalid
    else 
      # Return error message
      message = "Unrecognized input provided to method 'discover_quest'.\n" +
                "Input should be either an integer for the quest ID or\n" +
                "a string representing the quest name." 
      return false, message
    end
  end
  #--------------------------------------------------------------------------
  # * Make Quest Change
  # Uses quest name or id to change the state of a quest per the action
  #--------------------------------------------------------------------------
  def make_quest_change(name_or_id, action, *args)
    # Try to find a matching quest based on the name or ID
    found, quest_or_message = try_lookup_quest(name_or_id)
    # If we found a match...
    if found
      # ...Then this should be a quest
      quest = quest_or_message
      # Safety check that the method exists
      if quest.respond_to?(action)
        # Do the action on the quest (discover, complete, etc.)
        quest.send(action, *args)
      end
    # If we didn't find anything...
    else
      # ...Then this should be an error message
      message = quest_or_message
      # Display the message to the user
      print(message)
    end
    # Since things have changed, re-sort the quests
    sort_quests
  end
  #--------------------------------------------------------------------------
  # * Data Check
  # Performs a data check on the specified quest
  #--------------------------------------------------------------------------
  def data_check(id)
    @all_quests[id].data_check if @all_quests[id]
  end
  #--------------------------------------------------------------------------
  # * Data Check All
  # Performs a data check on all quests
  #--------------------------------------------------------------------------
  def data_check_all
    for quest in @all_quests
      quest.data_check
    end
  end
  #--------------------------------------------------------------------------
  # * Setup - Performs first time setup of quest data
  #--------------------------------------------------------------------------
  def setup
    # begin block for error handling
    begin
      # This flag has priority
      if CREATE_ENCRYPTED
        # Load unencrypted data
        Game_Quests.normal_setup
        # Create encrypted .rxdata
        Game_Quests.create_encrypted
      elsif USE_ENCRYPTED
        # Load encrypted data
        Game_Quests.encrypted_setup
      else
        # Load unencrypted data
        Game_Quests.normal_setup
      end
      # initialize Game_Quest object data from $data_quests array
      for quest in $data_quests
        self.add_quest(quest)
      end
      # Set Main Quest to known
      discover_quest(0)
    # rescue when no file is found   
    rescue Errno::ENOENT => e 
      Game_Quests.on_no_file(e)
      raise SystemExit
    end
  end
  #--------------------------------------------------------------------------
  # * GQs - Normal Setup
  # Class method that intializes normal quest data 
  #--------------------------------------------------------------------------
  def Game_Quests.normal_setup
    # Create array of quest data from file
    all_quests_array = File.open(QUEST_FILENAME) {|f|
      f.readlines("mobius_quest_break\n\n")
    }
    # Remove empty last element if necessary
    if all_quests_array.last.rstrip == ""
      all_quests_array.pop
    end
    # Initialize $data_quests array
    $data_quests = Array.new
    # Create Game_Quest objects from data
    for single_quest_str in all_quests_array
      # Split quest data by paragraph
      single_quest_array = single_quest_str.split("\n\n")
      # Remove file delimiter "mobius_quest_break\n\n"
      single_quest_array.pop
      # Set and remove name
      name = single_quest_array.shift
      # Push new Game_Quest object to $data_quests array
      $data_quests.push(Game_Quest.new(name, single_quest_array))
    end
  end
  #--------------------------------------------------------------------------
  # * GQs - Encrypted Setup
  # Class method that intializes encrypted quest data 
  #--------------------------------------------------------------------------
  def Game_Quests.encrypted_setup
    # load encrypted data
    $data_quests = load_data("Data/Quests.rxdata")
  end
  #--------------------------------------------------------------------------
  # * GQs - Create Setup
  # Class method that creates encrypted quest data 
  #--------------------------------------------------------------------------
  def Game_Quests.create_encrypted
    # save encrypted data
    save_data($data_quests, "Data/Quests.rxdata")
  end
  #--------------------------------------------------------------------------
  # * GQs - File Search
  # Class method that runs a search looking for similarly named files 
  #--------------------------------------------------------------------------
  def Game_Quests.file_search(dir, search_string)
    matches = []
    Dir.foreach(dir) do |entry|
      next if ((entry == ".") or (entry == ".."))
      if File.directory?(entry)
        # search sub directory
        sub_dir = File.expand_path(entry, dir)
        matches += Game_Quests.file_search(sub_dir, search_string)
      else
        # run comparison
        if entry.match(Regexp.new(search_string, true))
          full_path = File.expand_path(entry, dir)
          matches.push(full_path)
        end
      end
    end
    return matches
  end
  #--------------------------------------------------------------------------
  # * GQs - On No File
  # Class method that handles a no file error 
  #--------------------------------------------------------------------------
  def Game_Quests.on_no_file(error)
    # Construct filenames
    user_filename = error.message.sub("No such file or directory - ", "")
    user_basename = File.basename(user_filename, ".*")
    full_path = File.expand_path(user_filename)
    # Run search using given filename    
    matches = Game_Quests.file_search(Dir.pwd, user_basename)
    # Construct error message to user
    message = "##Mobius' Quest Journal Script Says##\n"
    message += "I was unable to find the file named: "
    message += "\n\"" + full_path + "\"\n\n"
    message += "I searched this folder: \n\"" + Dir.pwd + "\"\n"
    message += "and its subfolders for similar file names"
    unless matches.empty?
      message += " and I found these. Maybe they're what you want?\n\n\""
      message += matches.join("\"\n\n")
    else
      message += " but I couldn't find anything."
    end
    # display error message to user
    print(message)
  end
end

#==============================================================================
# ** Window_Base
#==============================================================================
class Window_Base < Window
  #--------------------------------------------------------------------------
  # * Process Control Codes
  #--------------------------------------------------------------------------
  def process_control_codes(text)
    # Change "\\" to forward slash literal
    text.gsub!(/\\\\/) { "\\" }
    # Replace \v with variable
    # The loop here is necessary to allow for deep nesting, i.e.
    # \n[\v[\v[0]]] - Use the value of variable 0 to find a variable
    # to set which actor name to use. Why would you need this? Idk...
    begin
      last_text = text.clone
      text.gsub!(/\\[Vv]\[([0-9]+)\]/) {
        $game_variables[$1.to_i]
      }
    end until text == last_text
    # Replace \n with actor name
    text.gsub!(/\\[Nn]\[([0-9]+)\]/) {
      $game_actors[$1.to_i] != nil ? $game_actors[$1.to_i].name : ""
    }
    # Replace \np with party actor name
    text.gsub!(/\\[Nn][Pp]\[([0-9]+)\]/) {
      $game_party.actors[$1.to_i - 1] != nil ? $game_party.actors[$1.to_i - 1].name : ""
    }
    # Replace \g with party gold
    text.gsub!(/\\[Gg]/) {
      $game_party.gold.to_s + "  " + $data_system.words.gold
    }
    # Replace \br with line break
    text.gsub!(/\\[Bb][Rr]/) { "\n" }

    # For a bunch of these next ones, we replace the code i.e. "\c"
    # with a non-printing character to make future parsing easier

    # Replace regular \c with \001
    text.gsub!(/\\[Cc]\[([0-9]+)\]/) { "\001[#{$1}]" }

    # Skipped \002 to preserve compatibility with default implementation of \g

    # Replace Hex \c with \003
    text.gsub!(/\\[Cc]\[#([0-9a-fA-F]+)\]/) { "\003[#{$1}]" }

    # Bold
    text.gsub!(/\\[Ff][Bb]/) { "\004" }
    # Italics
    text.gsub!(/\\[Ff][Ii]/) { "\005" }
    # Font
    text.gsub!(/\\[Ff][Nn]\[(.*?)\]/) { "\006[#{$1}]" }

    # Replace \icon[name] with \007[name]
    text.gsub!(/\\[Ii][Cc][Oo][Nn]\[(.*?)\]/) {
      "\007[#{$1}]"
    }

    # We can display any armor, item, skill, or weapon
    # We can optionally include an icon for them
    text.gsub!(/\\[Dd]([Aa]|[Ii]|[Ss]|[Ww])([Ii])?\[([0-9]+)\]/) {
      index = $3.to_i # The number portion in square brackets
      item = case $1.downcase # The second letter (a,i,s,w)
        when "a" then $data_armors[index]
        when "i" then $data_items[index]
        when "s" then $data_skills[index]
        when "w" then $data_weapons[index]
      end
      if $2 != nil # Did they include the "i" for icon?
        next "\007[#{item.icon_name}]" + "  " + item.name
      else
        next item.name
      end
    }

    # Data Words
    text.gsub!(/\\[Ww][Gg][Dd]/) {
      $data_system.words.gold
    }
    text.gsub!(/\\[Ww][Hh][Pp]/) {
      $data_system.words.hp
    }
    text.gsub!(/\\[Ww][Ss][Pp]/) {
      $data_system.words.sp
    }
    text.gsub!(/\\[Ww][Ss][Tt][Rr]/) {
      $data_system.words.str
    }
    text.gsub!(/\\[Ww][Dd][Ee][Xx]/) {
      $data_system.words.dex
    }
    text.gsub!(/\\[Ww][Aa][Gg][Ii]/) {
      $data_system.words.agi
    }
    text.gsub!(/\\[Ww][Ii][Nn][Tt]/) {
      $data_system.words.int
    }
    text.gsub!(/\\[Ww][Aa][Tt][Kk]/) {
      $data_system.words.atk
    }
    text.gsub!(/\\[Ww][Pp][Dd][Ee][Ff]/) {
      $data_system.words.pdef
    }
    text.gsub!(/\\[Ww][Mm][Dd][Ee][Ff]/) {
      $data_system.words.mdef
    }
    text.gsub!(/\\[Ww][Ww][Pp][Nn]/) {
      $data_system.words.weapon
    }
    text.gsub!(/\\[Ww][Aa][Rr][Mm]1/) {
      $data_system.words.armor1
    }
    text.gsub!(/\\[Ww][Aa][Rr][Mm]2/) {
      $data_system.words.armor2
    }
    text.gsub!(/\\[Ww][Aa][Rr][Mm]3/) {
      $data_system.words.armor3
    }
    text.gsub!(/\\[Ww][Aa][Rr][Mm]4/) {
      $data_system.words.armor4
    }
    text.gsub!(/\\[Ww][Aa]/) {
      $data_system.words.attack
    }
    text.gsub!(/\\[Ww][Ss]/) {
      $data_system.words.skill
    }
    text.gsub!(/\\[Ww][Gg]/) {
      $data_system.words.guard
    }
    text.gsub!(/\\[Ww][Ii]/) {
      $data_system.words.item
    }
    text.gsub!(/\\[Ww][Ee]/) {
      $data_system.words.equip
    }

    return text
  end
  #--------------------------------------------------------------------------
  # * Process Line Length
  # Takes a given piece of text and tries to wrap it across multiple lines
  # while still respecting any existing line breaks
  #--------------------------------------------------------------------------
  def process_line_length(text, max_width = self.contents.width)
    # Respect any existing line breaks by splitting on them
    lines = text.split("\n")
    new_lines = []
    # For each line, test if the line is too long for the window.
    # If it is, then split that line into multiple lines
    for line in lines
      new_line_array = []
      words = line.split
      for word in words
        # Add word to see if it fits
        new_line_array.push(word)
        # Remove any non-printing or control codes while we calc the width
        printed_str = new_line_array.join(" ").gsub(/[^:print]\[(.*?)\]/, "")
        line_width = self.contents.text_size(printed_str).width
        # If the line was too long, mark this line as done and
        # move current word to next line
        if line_width > max_width
          new_line_array.pop
          new_lines.push(new_line_array.join(" "))
          new_line_array = [word]
        end
      end
      # Add any leftover words
      new_lines.push(new_line_array.join(" "))
    end
    # Return the original text with new line breaks as needed
    return new_lines.join("\n")
  end
  #--------------------------------------------------------------------------
  # * Draw Processed Text
  #--------------------------------------------------------------------------
  def draw_processed_text(text, x = 0, y = 0, max_width = self.contents.width)
    # When slicing text this way, you get an int rather than a string
    # So be sure to convert it back using "chr" when needed
    while (char = text.slice!(0)) != nil
      x, y = draw_char(char, text, x, y, max_width)
    end
  end
  #--------------------------------------------------------------------------
  # * Draw Char
  #--------------------------------------------------------------------------
  def draw_char(char, text, x, y, max_width)
    case char
    when 1 # handle default color (\001)
      change_color(text)
    when 3 # handle hex color (\003)
      change_color_hex(text)
    when 4 # handle bold (\004)
      change_bold
    when 5 # handle italics (\005)
      change_italics
    when 6 # handle font (\006)
      change_font(text)
    when 7 # handle icon (\007)
      x, y = draw_icon(text, x, y, max_width)
    when 10 # handle newline (\n)
      x, y = change_line(x, y)
    else
      new_text = char.chr
      new_width = self.contents.text_size(new_text).width
      x, y = check_draw_length(x, y, new_width, max_width)
      self.contents.draw_text(x, y * 22, new_width + 2, 22, new_text)
      x += new_width
    end
    return x, y
  end
  #--------------------------------------------------------------------------
  # * Change Color
  #--------------------------------------------------------------------------
  def change_color(text)
    text.sub!(/\[([0-9]+)\]/, "")
    color = $1.to_i
    if color >= 0 and color <= 7
      self.contents.font.color = text_color(color)
    end
  end
  #--------------------------------------------------------------------------
  # * Change Color Hex
  #--------------------------------------------------------------------------
  def change_color_hex(text)
    text.sub!(/\[([0-9a-fA-F]+)\]/, "")
    hex_code = $1.to_s.downcase

    red   = hex_code.slice(0..1).hex
    blue  = hex_code.slice(2..3).hex
    green = hex_code.slice(4..5).hex

    self.contents.font.color = Color.new(red, blue, green)
  end
  #--------------------------------------------------------------------------
  # * Change Bold
  #--------------------------------------------------------------------------
  def change_bold
    self.contents.font.bold = !self.contents.font.bold
  end
  #--------------------------------------------------------------------------
  # * Change Italics
  #--------------------------------------------------------------------------
  def change_italics
    self.contents.font.italic = !self.contents.font.italic
  end
  #--------------------------------------------------------------------------
  # * Change Font
  #--------------------------------------------------------------------------
  def change_font(text)
    text.sub!(/\[(.*?)\]/, "")
    font = $1.to_s
    if font == ""
      self.contents.font.name = Font.default_name
    else
      self.contents.font.name = font
    end
  end
  #--------------------------------------------------------------------------
  # * Draw Icon
  #--------------------------------------------------------------------------
  def draw_icon(text, x, y, max_width)
    text.sub!(/\[(.*?)\]/, "")
    icon = RPG::Cache.icon($1.to_s)
    width = 24
    # If drawing will exceed boundaries, move to new line
    x, y = check_draw_length(x, y, width, max_width)
    # draw the icon
    self.contents.blt(x, y * 22, icon, Rect.new(0, 0, width, width))
    x += width
    return x, y
  end
  #--------------------------------------------------------------------------
  # * Change Line
  #--------------------------------------------------------------------------
  def change_line(x, y)
    return 0, y + 1
  end
  #--------------------------------------------------------------------------
  # * Check Draw Length
  #--------------------------------------------------------------------------
  def check_draw_length(x, y, width, max_width)
    if x + width > max_width
      x, y = change_line(x, y)
    end
    return x, y
  end
end

#==============================================================================
# ** Window Quest Info
#------------------------------------------------------------------------------
#  This window lists the info for the quests
#==============================================================================
class Window_QuestInfo < Window_Selectable
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize()
    super(200, 0, 440, 480)
    self.active = false
    self.contents = Bitmap.new(width - 32, height - 32)
    self.index = -1
    @text = ""
  end
  #--------------------------------------------------------------------------
  # * Set Text
  #--------------------------------------------------------------------------
  def set_text(quest_text)
    if @text != quest_text
      refresh(quest_text)
    end
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh(quest_text)
    # Clear old contents
    if self.contents != nil
      self.contents.clear
    end
    # Break if text is nil
    return unless quest_text

    # Reset font
    self.contents.font.name = Font.default_name
    self.contents.font.color = normal_color
    self.contents.font.bold = false
    self.contents.font.italic = false

    # Process and draw quest info
    quest_text = process_control_codes(quest_text)
    quest_text = process_line_length(quest_text)
    draw_processed_text(quest_text)
  end
end

#==============================================================================
# ** Window Quest List
#------------------------------------------------------------------------------
#  This window lists all currently active/completed quests
#==============================================================================
class Window_QuestList < Window_Selectable 
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize()
    super(0, 0, 200, 480)
    @current_quests = []        # Array of current quests
    @completed_quests = []      # Array of completed quests
    @top_half_size = 0          # Number of rows of current quests
    @bottom_half_size = 0       # Number of rows of completed quests
    self.active = true
    self.index = 0
    refresh
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    # Determine total number of rows
    @item_max = [@top_half_size + @bottom_half_size, 1].max
    if self.contents != nil
      self.contents.dispose
    end
    # Draw bitmap
    self.contents = Bitmap.new(200 - 32, row_max * 32)
    self.contents.font.color = normal_color
    # Draw current quests
    for i in 0...@top_half_size
      quest_name = @current_quests[i].name
      self.contents.draw_text(8, i * 32, 160, 32, quest_name)
    end
    self.contents.font.color = disabled_color
    # Draw completed quests
    for i in 0...@bottom_half_size
      quest_name = @completed_quests[i].name
      self.contents.draw_text(8, i * 32 + @top_half_size * 
      32, 160, 32, quest_name)
    end
  end
  #--------------------------------------------------------------------------
  # * Set Quests
  #--------------------------------------------------------------------------
  def set_quests(new_current_quests, new_completed_quests)
    if @current_quests != new_current_quests or
       @completed_quests != new_completed_quests
       #set new quests
       @current_quests = new_current_quests
       @completed_quests = new_completed_quests
       @top_half_size = @current_quests.size
       @bottom_half_size = @completed_quests.size
       #call update
       refresh
    end
  end
  #--------------------------------------------------------------------------
  # * Get Index Info
  #   Returns the text info from which ever quest is currently highlighted
  #--------------------------------------------------------------------------
  def get_index_info
    # Unless there are no quests
    unless @current_quests.empty? and @completed_quests.empty?
      # Determine cursor location
     if self.index < @top_half_size
        # Get selected quest info
        @current_quests[self.index].get_current_info 
      else
        # Get selected quest info
        @completed_quests[self.index - @top_half_size].get_current_info
      end
    end
  end
end

#==============================================================================
# ** Scene_Quest
#------------------------------------------------------------------------------
#  This class performs quest screen processing.
#==============================================================================
class Scene_Quest
  #--------------------------------------------------------------------------
  # * Configuration Binding
  #--------------------------------------------------------------------------
  include Mobius::Quests
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(return_scene = $scene.type)
    @return_scene = return_scene
  end
  #--------------------------------------------------------------------------
  # * Main Processing
  #--------------------------------------------------------------------------
  def main
    # Make QuestList Window
    @quest_list_window = Window_QuestList.new
    # Make QuestInfo Window
    @quest_info_window = Window_QuestInfo.new
    # Create memory variable
    @list_index = @quest_list_window.index
    # Update Game Quests
    $game_quests.data_check_all if USE_SWITCHES_VARIABLES
    $game_quests.sort_quests
    # Refresh QuestList
    unless SHOW_ALL_QUESTS
      # Normal refresh
      @quest_list_window.set_quests($game_quests.current_quests, 
                                    $game_quests.completed_quests)
    else
      # DEBUG refresh
      @quest_list_window.set_quests($game_quests.all_quests, [] )
    end
    # Redraw info window
    new_text = @quest_list_window.get_index_info
    @quest_info_window.refresh(new_text)
    # Execute transition
    Graphics.transition
    # Main loop
    loop do
      # Update game screen
      Graphics.update
      # Update input information
      Input.update
      # Frame update
      update
      # Abort loop if screen is changed
      if $scene != self
        break
      end
    end
    # Prepare for transition
    Graphics.freeze
    # Dispose of windows
    @quest_list_window.dispose
    @quest_info_window.dispose
  
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    # Update windows
    @quest_list_window.update
    # If index has changed
    if @list_index != @quest_list_window.index
      # Redraw info window
      new_text = @quest_list_window.get_index_info
      @quest_info_window.set_text(new_text)
      # Set index memory
      @list_index = @quest_list_window.index
    end
    # When cancel
    if Input.trigger?(Input::B)
      # Play cancel SE
      $game_system.se_play($data_system.cancel_se)
      # Return to menu
      $scene = @return_scene.new
    end
  end
end

# Changes to Scene_Title
class Scene_Title
  
  # Alias old method
  alias mobius_command_new_game command_new_game
  def command_new_game
    # Call old method
    mobius_command_new_game
    # Initialize Game_Quests object
    $game_quests = Game_Quests.new
  end
end

# Changes to Scene_Save
class Scene_Save
  
  # Alias old method
  alias mobius_write_save_data write_save_data
  def write_save_data(file)
    # Call old method
    mobius_write_save_data(file)
    # Dump Game_Quests object state to the save file
    Marshal.dump($game_quests, file)
  end
end

# Changes to Scene_Load
class Scene_Load
  
  # Alias old method
  alias mobius_read_save_data read_save_data
  def read_save_data(file)
    # Call old method
    mobius_read_save_data(file)
    # Load Game_Quests object state from the save file
    $game_quests = Marshal.load(file) 
  end
  
end

# Changes to Interpreter
class Interpreter
  # Create alias
  alias mobius_command_121 command_121
  #--------------------------------------------------------------------------
  # * Control Switches
  #--------------------------------------------------------------------------
  def command_121
    mobius_command_121
    # Only do this is using switches/variables
    if Mobius::Quests::USE_SWITCHES_VARIABLES and $game_quests
      # Get first quest switch id
      first = Mobius::Quests::FIRST_SWITCH_ID
      # Loop for group control
      for i in @parameters[0] .. @parameters[1]        
        # If first id and chosen id have same parity
        if (first % 2) == ( i % 2 )
          # Determine corresponding quest id
          id = ( i - first ) / 2
        # If first id and chosen id have different parity
        else
          # Determine corresponding quest id
          id = ( i - first - 1 ) / 2
        end
        $game_quests.data_check(id)      
      end
    end
    # Continue
    return true
  end
  # Create alias
  alias mobius_command_122 command_122
  #--------------------------------------------------------------------------
  # * Control Variables
  #--------------------------------------------------------------------------
  def command_122
    mobius_command_122
    # Only do this is using switches/variables
    if Mobius::Quests::USE_SWITCHES_VARIABLES and $game_quests
      # Get first quest switch id
      first = Mobius::Quests::FIRST_VARIABLE_ID
      # Loop for group control
      for i in @parameters[0] .. @parameters[1]        
        # Determine corresponding quest id
        id = ( i - first )
        $game_quests.data_check(id)
      end
    end
    # Continue
    return true
  end
  
end

