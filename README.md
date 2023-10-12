#  wateco
このアプリケーションは、音声ファイルからテキストファイルまたは、テキストファイルから音声ファイルを生成するためのCLIアプリケーションです。

> [!WARNING]
> 現在、本プログラムは十分にテストされていません。
> 本ソフトウェアを利用したことで何か問題が発生した場合、作者は一切の責任を負いません。
> エラーが発生した場合はIssuesにてご報告ください。

## 対応フォーマット
### 対応音声ファイル
入力に入れることができる音声ファイルは以下の通りです。
- .wav(kAudioFormatLinearPCM)
- .aiff(kAudioFormatLinearPCM)
- .alac(kAudioFormatAppleLossless)
- .aac(kAudioFormatMPEG4AAC)
- .m4a(kAudioFormatMPEG4AAC)
音声ファイルのチャンネル数はモノラルまたは、ステレオの2つのみに対応しています。

### 対応テキスト(数値)ファイル
入力に入れることができるテキストファイルは以下の通りです。
- .txt, .dat(どちらも同様のファイルフォーマット)
- .csv

### 対応数値タイプ
- Float 32bit
- Int 16bit
- Int 32bit

## 動作環境
macOS High Sierra 10.13以上

## インストール方法
リリース後、お知らせします。

## 使い方
本アプリケーションは、以下の2つの操作について行うことができます。
1. [音声ファイルから数値化されたデータが列挙されたテキストファイルに変換](#音声ファイルからテキストファイル-to-text)
1. [数値化されたデータが列挙されたテキストファイルから音声ファイルに変換](#テキストファイルから音声ファイル-to-wave)

それぞれの操作はサブコマンドによって分かれておりそれぞれに合ったオプションを設定することができます。
```terminal wateco_sambucommand_usage
USAGE: wateco <subcommand>

OPTIONS:
  --version               Show the version.
  -h, --help              Show help information.

SUBCOMMANDS:
  to-text                 Convert audio file to text format
  to-wave                 Convert text file to audio format
```
以下にそれぞれの詳しい操作について紹介します。

### 音声ファイルからテキストファイル(to-text)
音声ファイル(example.wav)をテキストファイルに変換するには以下のコマンドで実行できます。
```sh to-text_example1
wateco to-text example.wav
```
エラーが特別無ければテキストファイルが生成されます。上記の例では、`example.txt`のテキストファイルが生成されます。
出力データ`example.txt`は、入力ファイルとなっている`example.wav`のチャンネル数によってデータが変わります。

#### モノラルの場合
モノラルの場合は以下のように音圧値が１サンプル目から列挙されます。
```txt example.txt_ver.monaural
-3069 <- 1サンプル目
-1735 <- 2サンプル目...
-439
750
1701
2319
...
```

#### ステレオの場合
ステレオの場合は、以下のようにL chから交互に１サンプル目から列挙されます。
```txt example.txt_ver.stereo
6467 <- L chの1サンプル目
-2576 <- R chの1サンプル目
6427 <- L chの2サンプル目
-171 <- R chの2サンプル目...
5248
-1600
3707
-2323
3248
-2815
...
```

以上が、音声ファイルからテキストファイルに変換する方法になります。

#### options
本コマンド`to-text`では、3つのオプションを設定することができます。
1. 出力ファイルのファイル形式設定`--write-type <type>`
  ファイル形式`<type>`は、3種から設定することができます。
  - txt(.txt) // default
  - data(.dat)
  - csv(.csv)
  `txt`, `data`に関しては拡張子の違いのみで同じテキストが出力されます。
  `csv`の場合は、チャンネル毎に列が分かれて出力されます。
1. 数値データの設定`--pcm-format <pcm-format>`
  数値データ`<pcm-format>`は、3種から設定することができます。
  - int16 // default
  - int32
  - float32
  `int16`,`int32`は、整数値で出力されそれぞれ16bit, 32bitの量子値に変換されて出力されます。
  `float32`は、浮動小数値で出力されます。 ※ Double型には出力することができません
1. 出力ファイル名の設定`--output <file>`
  `<file>`は、出力ファイル名を任意の名前で出力することができます。
  例:
  ```sh set_output
  wateco to-text -o hogehoge.txt example.wav
  ```
  上記例では、example.wavの数値データがhogehoge.txtに書き込まれます。


#### USAGE(ヘルプ表示)
下記は`to-text`サブコマンドのヘルプ内容の写しになります。
```terminal to-text's_usage
USAGE: wateco to-text [--write-type <type>] [--pcm-format <pcm-format>] [--output <file>] <input-file>

ARGUMENTS:
  <input-file>            Specifies the input file to read from

OPTIONS:
  --write-type <type>     Write output to <type> (default: txt)
  --pcm-format <pcm-format>
                          Write output to <pcm-format> (default: int16)
  -o, --output <file>     Write output to <file>
  --version               Show the version.
  -h, --help              Show help information.
```

### テキストファイルから音声ファイル(to-wave)
テキストファイル(example.txt)をテキストファイルに変換するには以下のコマンドで実行できます。
```sh to-wave_example1
wateco to-wave example.txt
```
エラーが特別無ければ音声ファイルが生成されます。デフォルトは、`wavファイル`, `Int16`, `44100Hz`, `モノラル`に設定されているため、
上記の例では`example.wav`のモノラル音声ファイルが生成されます。
もし、ステレオ音声の場合は`--channel 2`のオプションを追加してください。
また、数値データが浮動小数である場合は`--pcm-format float32`のオプションを追加してください。
そのほかの詳しいオプションについては、下記の[options]()をご覧ください。

#### options
本コマンド`to-wave`では、4つのオプションを設定することができます。
1. 出力ファイルの圧縮形式(拡張子)設定`--format <audio-format>`
  圧縮形式`<audio-format>`は、3種(拡張子5種)から設定することができます。
  - .wav(kAudioFormatLinearPCM)
  - .aiff(kAudioFormatLinearPCM)
  - .alac(kAudioFormatAppleLossless)
  - .aac(kAudioFormatMPEG4AAC)
  - .m4a(kAudioFormatMPEG4AAC)
1. 読み込むテキストの数値データの設定`--pcm-format <pcm-format>`
  読み込むテキストの数値データ`<pcm-format>`は、3種から設定することができます。
  - int16 // default
  - int32
  - float32
  `int16`,`int32`は、整数値として読み込まれ指定されるbitで読み込まれます。適切でない値があった場合はエラーになります。
  `float32`は、浮動小数値として読み込まれます。
1. サンプリング周波数設定`--sampling-rate <sampling-rate>`
  サンプリング周波数`--sampling-rate <sampling-rate>`は、読み込むテキストデータのサンプリング周波数を設定することができます。
  default値は`44100Hz`に設定されています。
1. チャンネル数設定`--channel <channel>`
  チャンネル数`<channel>`は、読み込むテキストデータのチャンネル数を設定することができます。
  この時、**読み込むファイルがcsvファイルであってもこの項目の設定は必須です。**
1. 出力ファイル名の設定`--output <file>`
  `<file>`は、出力ファイル名を任意の名前で出力することができます。
  例:
  ```sh set_output
  wateco to-wave -o hogehoge.wav example.txt
  ```
  上記例では、example.txtのデータが音声ファイルhogehoge.wavに書き込まれます。

#### USAGE(ヘルプ表示)
```terminal to-wave's_usage
USAGE: wateco to-wave [--format <audio-format>] [--pcm-format <pcm-format>] [--sampling-rate <sampling-rate>] [--channel <channel>] [--output <file>] <input-file>

ARGUMENTS:
  <input-file>            Specifies the input file to read from

OPTIONS:
  --format <audio-format> Write output to <audio-format> (default: wav)
  --pcm-format <pcm-format>
                          Write output to <pcm-format> (default: int16)
  --sampling-rate <sampling-rate>
                          (default: 44100.0)
  --channel <channel>     (default: 1)
  -o, --output <file>     Write output to <file>
  --version               Show the version.
  -h, --help              Show help information.
```

## お問い合わせ先
以下のメールアドレスまでダメ元でお問い合わせください。
[creamylette@lattenote.info](mailto:creamylette@lattenote.info)
内容に関わらず対応できない場合がありますがご了承ください。

