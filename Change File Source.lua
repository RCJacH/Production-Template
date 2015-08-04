--selected_newitems_count = reaper.CountSelectedMediaItems(0) --if multiple selection, count total selected items
--for i = 0, selected_newitems_count - 1, 1  do --for each selected items
    item = reaper.GetSelectedMediaItem(0, 0) --defines the media item, change the last 0 to i if multiple selection
    take = reaper.GetActiveTake(item) --defines the take
    src = reaper.GetMediaItemTake_Source(take) --defines the source file of the take
    filename = reaper.GetMediaSourceFileName(src, "") --defines the absolute file address of the source file
--end 
path,file,extension = string.match(filename, "(.-)([^\\]-([^\\$.]+))$") --split filename to path, file, extension
number = "%d%d%d" --defines the pattern to search for
variable = string.sub(filename, string.find(filename, number)) --defines the variable that exists in the string
variable = string.format("%03d",variable+1) --increase variable while maintaining the number format
variable = path.."Patt"..variable..".mp3" --define the new filename
reaper.BR_SetTakeSourceFromFile2(take, variable, false, true) --this pushes the new source file into the selected media item
reaper.Main_OnCommand(40441, 0) -- Build peaks of selected item