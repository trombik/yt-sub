# `yt-sub`

A Google API client for uploading subtitles.


## Usage

```console
Usage: app.rb [options]
        --version                    show version
    -v, --verbose                    be verbose
    -l, --language LANGUAGE          Language of FILE
    -f, --file FILE                  Upload .srt file, FILE
    -i, --video-id ID                Video ID of FILE
```

```console
> bundle exec ruby bin/app.rb -i Hg03aM39itg -l en -f captions.srt
```
