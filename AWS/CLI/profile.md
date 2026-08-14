# 複数のAWSアカウント（本番環境と開発環境など）を使い分ける場合

## "develop" という名前でプロファイルを作成
aws configure --profile develop

## コマンド実行時に、このプロファイルを指定します
aws s3 ls --profile develop

## 作業するターミナルセッションで AWS_PROFILE をセットすると、そのターミナルを開いている間はすべての AWS コマンドが指定したプロファイルで実行
export AWS_PROFILE=develop

## 解除・元に戻す場合
unset AWS_PROFILE