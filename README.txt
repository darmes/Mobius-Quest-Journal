**How to Use**

Script is standard plug and play. Just put it below everything else but above main. 
The "Copy of QuestData.txt" contains an example on how to format your .txt file for 
the quest data, but it essentially follows this pattern:
 
Quest Name
 
Phase 0 info
 
Phase 1 info
 
mobius_quest_break
 
And that's all there is to it! You just repeat that pattern for each quest, 
and save it somewhere in the project folder. The configuration options are 
at the top of the script. They do the following.

If you want to create and then use the .rxdata, 
then you'll simply change the option marked "CREATE_ENCRYPTED = false" to 
"CREATE_ENCRYPTED = true". You'll then either playtest or run your game, 
and the script will automatically generate that file for you. Then just change 
the option back to "false" and change the option marked USE_ENCRYPTED to true. 
The script will now use the encrypted .rxdata.

QUEST_FILENAME = "examplefilename.txt" - just change the example filename 
to yours and you're good to go. 

USE_SWITCHES_VARIABLES - setting this to true will allow you to use the
built-in switches and variables to manipulate your quests as well as being
able to use the standard script calls. Setting it to false will only allow 
you to use script calls.

FIRST_SWITCH_ID - If USE_SWITCHES_VARIABLES is set to false, this does nothing.
Otherwise this sets the starting switch to use for your quests. The script
will then automatically use all sequential switches necessary. Note that
2 switches are need per quest. So if you have 10 quests and you set this
to 5, the script will use switches 5-24. Make sure all of these switches
aren't being used elsewhere! My suggestion is to put these at the end of
all your other switches.

FIRST_VARIABLE_ID - If USE_SWITCHES_VARIABLES is set to false, this does nothing.
Otherwise this sets the starting variable to use for your quests. The script
will then automatically use all sequential variables necessary. Only one
variable is needed per quest. So if you have 10 quests and you set this
to 5, the script will use switches 5-14. Make sure all of these variables
aren't being used elsewhere! My suggestion is to put these at the end of
all your other variables.

RENAME_SWITCHES_VARIABLES - If USE_SWITCHES_VARIABLES is set to false, this 
does nothing. Likewise if this is set to false, this does nothing. Otherwise
this will rename all switches and variables automatically, so that they
are easily identified in the DEBUG screen. Note that they are renamed using
quest names. This function can even be used to rename the switches and
variables in the editor. To do so, follow this checklist.

Step #1 - Ensure your quest data is up to date.
Step #2 - Ensure the FIRST_SWITCH_ID and FIRST_VARIABLE_ID are
	  set to what you want.
Step #3 - Set RENAME_SWITCHES_VARIABLES = true
Step #4 - Save your project in the editor.
Step #5 - Start a playtest and select "New Game"
Step #6 - Close the playtest
Step #7 - Close the editor WITHOUT SAVING!
Step #8 - Re-start the editor

The switches and variables should now be renamed.

SHOW_ALL_QUESTS - If set to false, this does nothing. Otherwise, this is
a debugging tool. When set to true all quests will show up in the journal
regardless of known/completed status.

**Credit and Thanks**
Special thanks to Zeriab. I borrowed the name for two of my classes from the 
Quest Book script, and overall I'd say it influenced my design. 

**Author's Notes**
This script is licensed under a Creative Commons Attribution-ShareAlike 3.0 Unported license. 
A human readable summary is available here: http://creativecommons.org/licenses/by-sa/3.0/deed.en_US 
The full license is availble here: http://creativecommons.org/licenses/by-sa/3.0/legalcode
In addition, this script is only authorized to be posted to the forums on RPGMakerWeb.com.
Further, if you do decide to use this script in a commercial product, I'd ask that you let 
me know via a post on the official topic or a PM (MobiusXVI). Thanks.