# How to Use

Place the script below all the default scripts but above main.
Create a file to hold your quests. There's an example in "Data/QuestData.txt".
The quest data file will hold all your quests. There's a special format you need to follow.
You starting by writing the quest's name, then a blank line, then the first phase info, then
a blank line, then the next phase, and so on. When you're done with a quest, leave a blank
line then write "mobius_quest_break" (without quotes). It should look like this:

```text
Quest Name

Phase 0 info

Phase 1 info

mobius_quest_break
```

And that's all there is to it! You just repeat that pattern for each quest, 
and save it somewhere in the project folder. (I recommend the data folder).
Finally, you'll need to add your quest data filename to the script's configuration.
See below for how to do that.

### Advanced Quest Formatting
In addition to plain text, you can also add "control codes" similar to RMXP's default message window.
To see how to use those, view the guide [here](https://github.com/darmes/Mobius-Quest-Journal/blob/f3cf242013f8091e9a3864acee3a65a0f8700ad3/Using%20Control%20Codes%20in%20Your%20Quests.pdf).

# Configuration Options

The configuration options are at the top of the script. Make sure you only edit them
and not other parts of the script to avoid causing issues.

#### QUEST_FILENAME
This option tells the script where your quest data file is relative to the project root.
You can place the file anywhere inside the project folder but I recommend storing it
with the other data files in the Data folder. Assuming you put it there, then you just
need to change the "QuestData" part to whatever you named yours.

Example: `QUEST_FILENAME = "Data/QuestData.txt"`

#### CREATE_ENCRYPTED
This option lets you convert your plain text file into RMXP's `rxdata` format.
This format is slightly more secure and can prevent players from being able
to simply read all of your quests directly. Note that this is NOT perfectly
secure. A determined player will still be able to view all the info.

If you decide to create and then use the .rxdata, simply change the option marked
`"CREATE_ENCRYPTED = false"` to `"CREATE_ENCRYPTED = true"`.
Then either playtest or run your game, and the script will automatically generate the
encrypted file for you. After that's done, stop the game and change the option back
to `"CREATE_ENCRYPTED = false"`. See `USE_ENCRYPTED` option for how to use it.

Note! If you later change your quests, you'll need to re-run this step.
So it's best saved for last or near the end of development.

#### USE_ENCRYPTED
This option lets you use an `rxdata` file for your quests.
Once you have an `rxdata` file for your quests, setting this to `USE_ENCRYPTED = true`
will cause the script to ignore your quest data file in favor of the encrypted version.
You can remove your original text file from the game's folder and just leave the
`rxdata` file.

#### USE_SWITCHES_VARIABLES
This option lets you use the built-in switches and variables to manipulate your quests
as well as being able to use the standard script calls. Setting it to false will only allow 
you to use script calls.

#### FIRST_SWITCH_ID
If `USE_SWITCHES_VARIABLES` is set to false, this does nothing.
Otherwise this sets the starting switch to use for your quests. The script
will then automatically use all sequential switches necessary. Note that
2 switches are need per quest. So if you have 10 quests and you set this
to 5, the script will use switches 5-24. Make sure all of these switches
aren't being used elsewhere! My suggestion is to put these at the end of
all your other switches.

#### FIRST_VARIABLE_ID
If `USE_SWITCHES_VARIABLES` is set to false, this does nothing.
Otherwise this sets the starting variable to use for your quests. The script
will then automatically use all sequential variables necessary. Only one
variable is needed per quest. So if you have 10 quests and you set this
to 5, the script will use switches 5-14. Make sure all of these variables
aren't being used elsewhere! My suggestion is to put these at the end of
all your other variables.

#### USE_SWITCHES_VARIABLES
If `USE_SWITCHES_VARIABLES` is set to false, this does nothing.
Likewise if this is set to false, this does nothing. Otherwise
this will rename all switches and variables automatically, so that they
are easily identified in the DEBUG screen. Note that they are renamed using
quest names. This function can even be used to rename the switches and
variables in the editor. To do so, follow this checklist.

Step #1 - Ensure your quest data is up to date.
Step #2 - Ensure the FIRST_SWITCH_ID and FIRST_VARIABLE_ID are set to what you want.
Step #3 - Set RENAME_SWITCHES_VARIABLES = true
Step #4 - Save your project in the editor.
Step #5 - Start a playtest and select "New Game"
Step #6 - Close the playtest
Step #7 - Close the editor WITHOUT SAVING!
Step #8 - Re-start the editor

The switches and variables should now be renamed.

#### SHOW_ALL_QUESTS
If this is set to false, this does nothing. Otherwise, this is
a debugging tool. When set to true all quests will show up in the journal
regardless of known/completed status.

# Credit and Thanks
- Mobius XVI, author
- Special thanks to Zeriab. I borrowed the name for two of my classes from the Quest Book script, and overall I'd say it influenced my design.
- KK20, for finding a fairly obscure bug in my code
- Supergenio, for suggesting the control codes

# Author's Notes
This script is licensed using the MIT License. See the license file for more info.
In addition, this script is only authorized to be posted to the forums on RPGMakerWeb.com.
Further, if you do decide to use this script in a commercial product, I'd ask that you let 
me know via a post on the official topic or a PM (MobiusXVI). Thanks.