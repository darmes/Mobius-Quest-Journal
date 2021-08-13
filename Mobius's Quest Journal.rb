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
      SHOW_ALL_QUESTS = false               # DEBUGGING FEATURE - Always shows all quests  
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
  # * Class Variables
  #--------------------------------------------------------------------------
    @@total_quests = 0           # Used to track number of quest objects

  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
    attr_reader   :id            # ID
    attr_reader   :name          # Name
    #attr_accessor :phase         # Phase
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
    @phase_variable = @id + Mobius::Quests::FIRST_VARIABLE_ID
    @known = false
    @known_switch = ( (@id * 2) + Mobius::Quests::FIRST_SWITCH_ID )
    @completed = false
    @completed_switch = ( (@id * 2) + 1 + Mobius::Quests::FIRST_SWITCH_ID )
    # The info array contains text that corresponds to the current phase
    # of the quest. So, you simply need to get the info in the i-th position
    # of the array for the i-th phase
    @info_array = info_array
    # Call rename if set in customization
    rename if (Mobius::Quests::RENAME_SWITCHES_VARIABLES and Mobius::Quests::USE_SWITCHES_VARIABLES)
  end
  #--------------------------------------------------------------------------
  # * Get Current Info
  # Returns text info for the current phase
  #--------------------------------------------------------------------------
  def get_current_info
    @info_array.fetch(@phase, [])
  end
  #--------------------------------------------------------------------------
  # * Phase=
  # Sets the quest phase 
  #--------------------------------------------------------------------------
  def phase=(value)
    # Set phase
    @phase = value
    if Mobius::Quests::USE_SWITCHES_VARIABLES
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
    if Mobius::Quests::USE_SWITCHES_VARIABLES
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
    if Mobius::Quests::USE_SWITCHES_VARIABLES
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
    if Mobius::Quests::USE_SWITCHES_VARIABLES
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
      # if true
      if Mobius::Quests::CREATE_ENCRYPTED
        # Load unencrypted data
        Game_Quests.normal_setup
        # Create encrypted .rxdata
        Game_Quests.create_encrypted
      # elsif true
      elsif Mobius::Quests::USE_ENCRYPTED
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
    quest_array = File.open(Mobius::Quests::QUEST_FILENAME) {|f| 
                f.readlines("mobius_quest_break\n\n")}
    # Remove empty last element if necessary
    if quest_array.last.rstrip == ""
      quest_array.pop
    end
    # Initialize $data_quests array
    $data_quests = Array.new
    # Create Game_Quest objects from data
    for quest_data in quest_array
      # Split quest data by paragraph
      quest_data_array = quest_data.split("\n\n")
      # Remove file delimiter "mobius_quest_break\n\n"
      quest_data_array.pop
      # Set and remove name
      name = quest_data_array.shift
      # Initialize info array
      info_array = []
      # Organize phase info into useable line lengths
      for quest_data_line in quest_data_array
        new_arr = []
        # Split phase info into words
        temp_arr = quest_data_line.split
        temp_str = ""
        for word in temp_arr
          # Rejoin words together
          temp_str.concat(word + " ")
          # When line length is useable, push to new_arr
          if temp_str.size >= 35
            new_arr.push(temp_str.strip)
            temp_str = ""
          end
        end
        # Push leftover string
        new_arr.push(temp_str.strip) unless temp_str == ""
        # Push phase info to info_array
        info_array.push(new_arr)
      end
      # Push new Game_Quest object to $data_quests array
      $data_quests.push(Game_Quest.new(name, info_array))
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
    refresh([""])
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh(text_array)
    # Clear old contents
    if self.contents != nil
      self.contents.clear
    end
    # Set font color
    self.contents.font.color = normal_color
    # Break if text_array is nil
    return unless text_array
    # Draw info
    for i in 0...text_array.size
      line = text_array[i]
      self.contents.draw_text(0, i * 22, 408, 22, line)
    end
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
    $game_quests.data_check_all if Mobius::Quests::USE_SWITCHES_VARIABLES
    $game_quests.sort_quests
    # Refresh QuestList
    unless Mobius::Quests::SHOW_ALL_QUESTS
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
      @quest_info_window.refresh(new_text)
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

