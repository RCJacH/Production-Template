--Set envelope to fade in and out of digital silence

--[[ by Elan Hickler
www.Soundemote.com
www.elanhickler.com ]]

--possible user values
fadeInTime = .001 --fade time for "in fade"
fadeOutTime = .01
shpI=4 --shape "in"
shpO=3
tenI=.5 --tension for shape "in"
tenO=.5
chan=0 --0 base channel to analyze

reaper.Undo_BeginBlock()

items = reaper.CountSelectedMediaItems(0)
for i=0,items-1 do
  item        = reaper.GetSelectedMediaItem(0, i)
  take        = reaper.GetActiveTake(item)
  source      = reaper.GetMediaItemTake_Source(take)
  position    = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
  length      = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
  srate       = reaper.GetMediaSourceSampleRate(source)  
  sourcelen,x = reaper.GetMediaSourceLength(source)
  chanmode    = reaper.GetMediaItemTakeInfo_Value(take, "I_CHANMODE")
  envelope    = reaper.GetTakeEnvelope(take, 0)
  nch         = reaper.GetMediaSourceNumChannels(source)  

  reaper.SetMediaItemTakeInfo_Value(take, "I_CHANMODE", 0)
  samperchan = math.floor(length*srate)
  nsamples   = math.floor(samperchan*nch)
  accessor   = reaper.CreateTakeAudioAccessor(take)
  buffer     = reaper.new_array(nsamples)
  reaper.GetAudioAccessorSamples(accessor, srate, nch, 0, samperchan, buffer)
  reaper.DestroyAudioAccessor(accessor)

  thresh = 1
  c=1 --counter for number of digital zero sections
  s=0+chan --sample counter
  x=0 --counter for number of consecutive zeros
  locIN  = {}
  locOUT = {}
  repeat
    v = buffer[s+chan+1]
    while v == 0 and s < nsamples-nch-chan do
      if x==thresh then locIN[c] = (s-nch*thresh)/srate/2 end
      s=s+nch
      v = buffer[s+chan+1]
      x=x+1
    end
    if x>thresh then 
      locOUT[c] = s/srate/2
      c=c+1
    end
    x=0
    s=s+nch    
  until s > nsamples-nch-chan

  if #locIN > 0 then
    reaper.DeleteEnvelopePointRange(envelope, 0, length)
    reaper.InsertEnvelopePoint(envelope, locIN[1]-fadeOutTime, 1, shpI, tenI, 0, 1)
    for j=1,#locIN do
      --reaper.AddProjectMarker(0, 1, position + locIN[j], position + locOUT[j], "", -1)
      if j>1 and locOUT[j-1]+fadeInTime < locIN[j]-fadeOutTime then
        reaper.InsertEnvelopePoint(envelope, locIN[j]-fadeOutTime, 1, shpI, tenI, 0, 1)
      end 
      reaper.InsertEnvelopePoint(envelope, locIN[j], 0, shpI, tenI, 0, 1)
      if j<#locIN and locOUT[j]+fadeInTime < locIN[j+1]-fadeOutTime then
        reaper.InsertEnvelopePoint(envelope, locOUT[j], 0, shpO, tenO, 0, 1)
        reaper.InsertEnvelopePoint(envelope, locOUT[j]+fadeInTime, 1, shpO, tenO, 0, 1)
      end
    end 
  end

  reaper.SetMediaItemTakeInfo_Value(take, "I_CHANMODE", chanmode)
end

reaper.UpdateArrange()

reaper.Undo_EndBlock("Set envelope to fade in and out of digital silence", 0)