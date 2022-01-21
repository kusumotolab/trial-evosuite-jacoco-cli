# trial-evosuite-jacoco-cli

## What's this?

- EvoSuiteでテストを生成する
- JaCoCoでEvoSuiteで生成したテストの実行情報を得る

## How to use

```
$ ./run.sh [ instrument | non-instrument ]
```

#### やっていること

- ソースコンパイル
- EvoSuiteでテスト生成
- JaCoCoを使いながらJUnitでテスト実行．実行情報を取得
  - 引数 instrument / non-instrumentで取得方法を変更可能（詳しくは下）

- report作成（今回はHTML）

## 解説

EvoSuiteのテストは，独自のクラスローダを利用するためJaCoCoのJava agentのみを使った方法が利用できない（出力されるカバレッジが常に0%になる）．

実行情報を取得するための方法が2通りある．

1. JaCoCoのOffline Instrumentationを利用する．
2. EvoSuite独自のクラスローダを利用しない．

### 1. Offline Instrumentation

`run.sh`の`instrument()`が対応．

Instrumentedのクラスファイルを作って，JUnitにそれを指定して実行すれば良い．

ただし結局Java agentの指定は必要な模様．

[公式ドキュメント](https://www.jacoco.org/jacoco/trunk/doc/offline.html)ではPre-instrumentedなクラスは除外しろといっているが，特に何も起きない．

### 2. 独自のクラスローダを利用しない

`run.sh`の`non-instrument()`が対応．

EvoSuiteが生成したテストクラスの内容を一部変更する．

`separateClassLoader`を`false`に設定する．

```diff
- @RunWith(EvoRunner.class) @EvoRunnerParameters(mockJVMNonDeterminism = true, useVFS = true, useVNET = true, resetStaticState = true, separateClassLoader = true) 
+ @RunWith(EvoRunner.class) @EvoRunnerParameters(mockJVMNonDeterminism = true, useVFS = true, useVNET = true, resetStaticState = true, separateClassLoader = false) 
```

あとはコンパイルして実行すれば良い．

この場合，JUnitテストの実行にはevosuite本体が必要なことに注意．

## 参考

- [公式ドキュメント](https://www.jacoco.org/jacoco/trunk/doc/index.html)
  - Java Agent, Command Line, Interface, Offline Instrumentationあたり
- [trial-evosuite](https://github.com/shinsuke-mat/trial-evosuite)
- [trial-jacoco](https://github.com/shinsuke-mat/trial-jacoco-cli)
