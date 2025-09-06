# ProRes Delivery Converter

Convert H264 and H265 to ProRes422 or ProRes422HQ. MP4 and MOV supported.

Converted files will now also work on Windows in Davinci Resolve (free).

This takes care of the H265 problem if others you work with need ProRes files and your camera cannot record in ProRes natively.

I built this little utility script because I am often asked to provide ProRes files.

The script itself has a bunch of useful comments and isn't terribly large for what it does.

The script will skip files that have already been converted.

This should be useful! But it can also not be so. To prevent skipping set `SKIP=false`

---

### Example Useage

Example One:   `./main.sh movs prores 422`

Example Two:   `./main.sh mp4s prores 422`

Example Three: `./main.sh /Volumes/T9/FX30 /Volumes/T9/FX30/PRORES 422`

Example Four:  `./main.sh /Volumes/T9/XH2S /Volumes/T9/XH2S/PRORES 422HQ`

_to avoid skipping already converted files:_

Example Five:   `SKIP=false ./main.sh $HOME/FX30 $HOME/FX30/PRORES 422`

---

`$1` - directory where your mov and mp4 files are (converts all .mov and .mp4 files in that directory)

`$2` - directory where you want your prores files to go (all movs and mp4s will be converted here)

`$3` - the quality, currently 2 are recognized: 422 and 422HQ

--

### Considerations

This asumes you record in 422 10bit.

I am sure it will work with 420 10bit or 420 8bit but I haven't tested.

_theoretically no need for ProRes422HQ if your source is below ProRes422 bitrate_

_ProRes 422: ~470 Mbps @ 4k_

_ProRes 422 HQ: ~700 Mbps @ 4k_

---

### Caveats

**Needs ffmpeg to be installed**! Script checks for it. Won't run if it's not there.

Works on Mac. Should work on Linux. Probably works on WSL, but pure Windows support is not in my pipeline at the moment.

Original timestamps (created and modified) should be preserved on Mac. On Linux, modified date should be preserved but not created date.

---

### Additional Caveats

This will use all cores by default. Your files will get much bigger.

Example file bloat: A 448MB h265 422 10 bit LongGOP mov file will turn into 1.12GB for ProRes 422. ProRes 422 HQ should get close to 2GB.
