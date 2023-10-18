## Ruby, ASP による迷路求解プログラムの実装例

### 動作に必要なソフトウェア・ライブラリ

* [Ruby](https://www.ruby-lang.org/)
    * 迷路生成・求解プログラムは Ruby で実装されています．
    * 迷路の表示にターミナルでの色付き出力をサポートする [Ruby Paint](https://github.com/janlelis/paint) が必要です．
        * `gem install paint` で導入できます．
* [Clingo](https://github.com/potassco/clingo)
    * 制約プログラミングによる実装例として解集合プログラミング (Answer Set Programming; ASP) を利用しています．Clingo は ASP の代表的な処理系です．
    * 最も簡単なインストール方法は [Anacond](https://docs.conda.io/) を利用することです．詳細は[こちら](https://github.com/potassco/clingo/releases/)を参照してください．

### 迷路の生成方法

Ruby スクリプト `makeMaze.rb` を使用すると迷路を生成できます．生成したい迷路のサイズを指定する必要があります．

```
❯ ./makeMaze.rb
Usage: makeMaze [options] SIZE [SCALE]
    -o FILE  
```

- オプション `SIZE` で迷路のサイズを指定します．
- オプション `SCALE` は迷路を画面に表示するときの倍率です（デフォルトは1倍）
- オプション `-o FILE` で迷路データをファイルに出力できます．迷路ファイルのフォーマットは，壁が `1`，通路が `0`，スタート `S`，ゴール `G` とするテキストファイルです．以下は small.txt の例です．
```
1111111G1
100000101
101110101
101000101
101110101
100010101
101011101
101000001
1S1111111
```
### 迷路の求解：命令型プログラミング
#### ランダム移動
Ruby スクリプト `randRobot.rb` は，ランダムに移動するアルゴリズムの実装例です．コマンドライン引数に迷路データファイルを指定してください．
```
❯ ./randRobot.rb small.txt
```
* 実行中 `u` キーを押すとロボットの移動速度が上昇し，`i` で低下します．
* 巨大なメールを解く場合，迷路の表示が遅いため画面がちらつきます．そのような場合は `s` キーを押して描画を間引いてください．`d` キーを押すと `s` の逆の動作をします．
    * デフォルトではロボットが１歩移動するたびに描画しますが，`s` を１回押すと５歩移動するたびに描画します．

#### 分岐でランダム移動
Ruby スクリプト `randIntersectRobot.rb` は，分岐に出会うまで迷路に沿って進み，分岐でランダムに方向を決定するアルゴリズムの実装例です．利用方法は `randRobot.rb` と同様です．
```
❯ ./randIntersectRobot.rb small.txt
```

#### 左手法
Ruby スクリプト `wallForllowerRobot.rb` は，左手を壁につけたまま移動するアルゴリズムの実装例です．利用方法は `randRobot.rb` と同様です．
```
❯ ./wallFollowerRobot.rb small.txt
```
* オプション `-r` を指定すると，ゴールに到着後，スタートに向けて再出発します．

#### バックトラック法
Ruby スクリプト `backtrackRobot.rb` は，バックトラック法で迷路を解くアルゴリズムの実装例です．分岐ではランダムに移動方法を選択します．また後戻りするとき足跡を消去します．利用方法は `randRobot.rb` と同様です．
```
❯ ./backtrackRobot.rb small.txt
```

### 迷路の求解：制約プログラミング
#### 迷路の解を制約として定式化

`path-rules.lp` は，迷路の解を表す制約を ASP で記述したものです．求解する場合は，以下のように実行してください：
```
❯ clingo path-rules.lp small.lp | ./printModel.rb
```
* `small.lp` が迷路データ `small.txt` を ASP の facts として表現したファイルです．これは以下のコマンドで生成できます．
    ```
    ❯ ./maze2facts.rb small.txt > small.lp
    ```
* `printModel.rb` は，ASP 処理系 `clingo` が見つけた解を可視化して表示する Ruby スクリプトです．

#### 迷路の「解ではない部分」を制約として定式化

`deadend-rules.lp` は，迷路の解ではない部分を表す制約を ASP で記述したものです．求解する場合は，以下のように実行してください：
```
❯ clingo deadend-rules.lp small.lp | ./printModel.rb
```
