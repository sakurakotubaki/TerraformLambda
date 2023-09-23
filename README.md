# Terraform で Lambda をデプロイするサンプル
## 概要
Terraform で Lambda をデプロイするサンプルです。

## 前提
- Terraform がインストールされていること
- AWS CLI がインストールされていること
- AWS CLI で AWS アカウントにログインしていること
- AWS CLI で AWS アカウントにデプロイ用の権限があること

## Hello Worldする関数を作成する
### 1. ディレクトリを作成する
```
mkdir hello-world
cd hello-world
```

### 2. ファイルを作成する
```
touch hello.js
```

### 3. ファイルに以下の内容を記述する
```
exports.handler = async (event) => {
    const response = {
        statusCode: 200,
        body: JSON.stringify('Hello World!'),
    };
    return response;
};
```

### 4. ディレクトリをZip化する
```
zip -r hello.zip lambda_function
```

## デプロイ手順
### 1. Terraform の初期化
```
terraform init
```

## 2. デプロイ内容を確認
```
terraform plan
```

### 3. Terraform の実行
```
terraform apply
```

### 4. Terraform の破棄
```
terraform destroy
```

------

Terraformによるデプロイが成功した場合、設定ファイルに`output`ブロックを追加していれば、その情報はコマンドラインの出力にも表示されます。上述のサンプルコードでは、`invoke_url`という名前でAPI GatewayのエンドポイントURLを出力しています。

もし既に`terraform apply`を実行した後で、この`output`ブロックが存在している場合、次のコマンドで再度その値を確認することができます。

```bash
terraform output invoke_url
```

また、AWS Management Consoleにログインして、API Gatewayのセクションに移動することで、手動でエンドポイントURLを確認することも可能です。具体的には、API Gatewayダッシュボードから該当するAPIを選択し、ステージ（Stage）を選びます。そこでエンドポイントURLが表示されるはずです。このURLにパス（上述の例では`/myresource`）を追加することで、フルのエンドポイントURLを構築できます。

ただし、Consoleで確認する手段は、Terraformでの管理とは別になるため、自動化や文書化の観点からは`output`を使用する方が好まれます。

### API Gateway のエンドポイントにアクセスする
```bash
curl https://iscbh4xuih.execute-api.ap-northeast-1.amazonaws.com/test/myresource
