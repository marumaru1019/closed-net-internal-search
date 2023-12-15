## 変更概要
- 以下のリソースの閉域化の対応
    - Azure OpenAI Service
    - Azure Form Recognizer
    - Azure Search Service
    - Azure Storage
    - Azure App Service
    - Azure Cosmos DB
- 不要リソースの削除
    - Windows 仮想マシン
    - Windows 仮想マシン用 PublicIP アドレス
    - Winodws 仮想マシン用 NIC
- 既存 Vnet へのデプロイ対応
- ハッシュ文字をリソース名に付けない代わりに環境名を付与
- 動作確認手順を追加

## デプロイ手順

### アプリケーションのデプロイ手順
1. サンプル コードをクローンしたディレクトリまで移動してください。
    ```
    cd /path/to/jp-azureopenai-samples\5.internal-document-search
    ```
1. `infra/main.parameters.json` を以下のように書き換えてください。
    ```json
    {
        "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
        "contentVersion": "1.0.0.0",
        "parameters": {
            "environmentName": {
            "value": "${AZURE_ENV_NAME}"
            },
            "location": {
            "value": "${AZURE_LOCATION}"
            },
            "resourceGroupName": {
            "value": <Vnet が作成してあるリソースグループ名>
            },
            "isPrivateNetworkEnabled": {
            "value": true
            },
            "principalId": {
            "value": "${AZURE_PRINCIPAL_ID}"
            },
            "openAiServiceName": {
            "value": "${AZURE_OPENAI_SERVICE}"
            },
            "openAiResourceGroupName": {
            "value": "${AZURE_OPENAI_RESOURCE_GROUP}"
            },
            "openAiSkuName": {
            "value": "S0"
            },
            "formRecognizerServiceName": {
            "value": "${AZURE_FORMRECOGNIZER_SERVICE}"
            },
            "formRecognizerResourceGroupName": {
            "value": "${AZURE_FORMRECOGNIZER_RESOURCE_GROUP}"
            },
            "formRecognizerSkuName": {
            "value": "S0"
            },
            "searchServiceName": {
            "value": "${AZURE_SEARCH_SERVICE}"
            },
            "searchServiceResourceGroupName": {
            "value": "${AZURE_SEARCH_SERVICE_RESOURCE_GROUP}"
            },
            "searchServiceSkuName": {
            "value": "standard"
            },
            "storageAccountName": {
            "value": <任意のストレージ アカウント名>
            },
            "storageResourceGroupName": {
            "value": "${AZURE_STORAGE_RESOURCE_GROUP}"
            },
            "appInsightsInstrumentationKey": {
            "value": "${AZURE_APPINSIGHTS_INSTRUMENTATION_KEY}"
            },
            "principalType": {
            "value": "${AZURE_PRINCIPAL_TYPE}"
            }, 
            "virtualNetworkName": {
            "value": <事前に準備してある Vnet 名>
            },
            "resourceName": {
            "value": "${AZURE_ENV_NAME}"
            }
        }
    }
    ```
1. ホストファイルを編集して、DNS 
    
1. Azure にログインしてください。
    ```
    az login
    ```
1. Azd ログインを実行してください。
    ```
    azd auth login
    ```
1. ホストファイルに以下を追加して DNS の名前解決を設定してください。\
    ここで指定する環境名は次で行う `azd up` で指定する環境名と同じものを指定してください。\
    ※ Windows の場合、ホストファイルは通常 
`C:\Windows\System32\drivers\etc\hosts` にあります。Linux の場合、ホストファイルは `/etc/hosts` にあります。
    ```
    10.0.0.4 <infra/main.parameters.jsonで指定したストレージ アカウント名>.blob.core.windows.net
    10.0.0.5 gptkb-<環境名>.search.windows.net
    10.0.0.7 cog-fr-<環境名>.cognitiveservices.azure.com
    10.0.0.10 app-backend-<環境名>.azurewebsites.net
    10.0.0.10 app-backend-<環境名>.scm.azurewebsites.net
    ```
1. `azd up` を実行してください。\
    環境名は、前の手順で指定したものと同じものを指定してください。


## 動作確認

1. インターネット上からブラウザで `https://app-backend-<環境名>.azurewebsites.net` にアクセスして、アクセスブロックの画面が表示されることを確認してください。
![image](https://github.com/marumaru1019/closed-net-internal-search/assets/70362624/f22e10de-a4d4-4633-ad1f-93f506e27634)

1. Vnet と接続しているネットワーク上のマシンから `https://app-backend-<環境名>.azurewebsites.net` にアクセスして、アプリケーションが表示されることを確認してください。
![image](https://github.com/marumaru1019/closed-net-internal-search/assets/70362624/65356001-f378-4bf0-8427-cea69eeabd4a)

## App Service のカスタム ドメイン設定方法
[既存のカスタム DNS 名を Azure App Service にマップする](https://learn.microsoft.com/ja-jp/azure/app-service/app-service-web-tutorial-custom-domain?tabs=root%2Cazurecli) に従って設定を行ってください。