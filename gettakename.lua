selected_newitems_count = reaper.CountSelectedMediaItems(0)
  for i = 0, selected_newitems_count - 1, 1  do
    j = i + selected_newitems_count -- prevent new and old indexes crossing
    item = reaper.GetSelectedMediaItem(0, i)
    take = reaper.GetActiveTake(item)
    takename = reaper.GetTakeName(take, takename)
  end 
reaper.ShowConsoleMsg("")
  reaper.ShowConsoleMsg(takename)
