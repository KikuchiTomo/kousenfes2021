# 高専祭Webアプリリポジトリ

## 概要
2021年度の産技高専の高専祭Webアプリリポジトリ．
(最新のソースは校内サーバのGitリモートを確認のこと)

### 規約
#### コメント
YARDを使用する。Sinatra用のWebアプリケーションファイルは基本的に機能ごとに`Class`を作成する 。
クラスのコメントは以下のように記述すること  
```ruby
#
# クラスの概要説明
# @author 作成者
#
```
名前の形式については、フルネーム日本語であること  
またエンドポイント・APIレベルでのコメントは可能用に入力値と出力値を記載する。例えば、erbファイルに渡すべき変数については、出力値として扱い、返される画面については、
APIの概要に記載すること。
```ruby
#
# API概要説明
# API詳細説明
# @param [型] 説明
# @return [型] 説明
#
```
メソッド内レベルのコメントは、基本的にその命令文の直前に記入すること。  
```ruby
# UserIDでユーザ情報をDBから取得
User.getInfo(user_id)
```
#### コーディング
##### 文法
コーディング規約については原則的にshugoを参照すること。[リンク](https://shugo.net/ruby-codeconv/codeconv.html)

##### 命名
命名規則は以下の通り
- グローバル変数 : `name_`のように末尾に`_`をつける
- メソッド : `getUserInfoFromDB`のように動詞+名詞+取得元など、冗長にすること。また、先頭小文字、それいこうの単語の先頭は大文字とする
- 変数 : `user_info`のように単語動詞は`_`で結合すること

## Git Pushの際のルール 
以下の記述されていないものに関しては`.gitignore`に記載済み

### バイナリファイル 
Git LFSを使用する。導入方法はサイトを参照すること。[リンク](https://git-lfs.github.com/)
#### Install
Macでは`brew install git-lfs`
#### Usage
- .gitがあるディレクトリで`git lfs install`を実行
- `git lfs track "*.jpg"`で`*.jpg`のようにして，LFSに指定したいファイル形式を指定する
- `git add`する
- `git commit`&`git push`

### ディレクトリ
必須なディレクトリでも空の場合はcommitせずに、`Makefile`を使用し`make prepare`で生成すること。

### ブランチ
 - ブランチの確認: `git branch --contains=HEAD`
 - ブランチをきる: `git checkout -b feature/{branchname}`
 - 作業を行う
 - 監視対象へ加える: `git add {filename}`
   - 間違えて`add`した時: `git reset`または特定のファイルならば`git reset {filename}`
 - コミットする: `git commit -m "変更内容/作業内容"`
 - 状態を確認: `git status`
 - リモートの変更を取り込む
   - `git fetch`
   - `git rebase origin/main`
   - 競合が起きたら
     - 競合したところを編集し`git add`&`git rebase --continue`
 - ブランチをpush: `git push origin feature/{branchname}`
 - サイトでプルリクする
 - マスターに戻すとき
   - `git fetch`: 最新のmainを取得
   - `git rebase origin/main`: 今のブランチにマスターの変更を取り込む
   - 競合が起きたら
     - 競合したところを編集し`git add`&`git rebase --continue`
   - 競合が解消したら: `git push origin feature/xxx`
   - `git checkout main`: mainブランチに戻る
   - `git pull`: リモートをローカルに反映
   
## 使用方法
### サーバの起動
`make start`
### 停止
`make stop`
### Webサーバのみの再読み込み
`make reload`
### Webアプリサーバの再起動
`make hup`
### 必要パッケージの準備
`make prepare`

