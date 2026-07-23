<!--
メタディスクリプション：
CryptoBar は、CoinGecko API を使用してリアルタイムの暗号資産価格を表示する軽量な macOS メニューバーアプリケーションです。24 時間の価格チャートも表示し、メニューバーから市場のトレンドをすばやく確認できます。
-->

<p align="center">
  <img src="assets/logo.png" width="128" height="128" alt="CryptoBar Logo">
</p>

<h1 align="center">CryptoBar</h1>

<p align="center">
  <b>macOS のメニューバーにリアルタイムの暗号資産価格を表示</b>
</p>


<p align="center">
  <img src="https://img.shields.io/badge/platform-macOS-blue?style=flat-square&logo=apple" alt="Platform">
  <img src="https://img.shields.io/badge/language-C-gray?style=flat-square&logo=c" alt="Language">
  <img src="https://img.shields.io/badge/license-MIT-green?style=flat-square" alt="License">

</p>

[English](README.md) | [简体中文](README.zh-CN.md) | [日本語](README.ja.md)

---

CryptoBar は、CoinGecko API を使用してリアルタイムの暗号資産価格を表示する軽量な macOS メニューバーアプリケーションです。24 時間の価格チャートも表示し、メニューバーから市場のトレンドをすばやく確認できます。


<table>
<tr>
<td>
<img src="assets/CryptoBar.png" >
</td>
<td>
<img src="assets/CryptoBarShowTRX.png" >
</td>
</tr>
</table>

---

## 機能

- macOS のメニューバーにリアルタイムの暗号資産価格を表示
- トレンドをすばやく確認できる 24 時間の価格チャート
- 軽量で高速なバックグラウンド動作
- CoinGecko API を使用
- データの明瞭さを重視した最小限の UI



## クイックスタート

### オプション 1 - Homebrew でインストール（推奨）

```bash
brew install --cask erdwin90/cask/crypto-bar
open -a "CryptoBar"
```


### オプション 2 - 手動インストール

1. 最新リリースをダウンロードします：https://github.com/erdwin90/crypto-bar-mac/releases/latest
2. .dmg ファイルを開きます
3. CryptoBar.app を /Applications にドラッグします
4. CryptoBar を起動します — メニューバーに表示されます



## 設定

CryptoBar は公開 CoinGecko API を使用するため、API キーは必要ありません。

次の項目をカスタマイズできます：

- 追跡する銘柄
- 更新間隔
- UI レイアウト

## 技術スタック

- Objective-C
- AppKit
- macOS メニューバー（NSStatusItem）
- CoinGecko API

## ライセンス

MIT License。詳細は [LICENSE](LICENSE) を参照してください。


## フィードバック

問題が発生した場合や機能の要望がある場合は、GitHub で [Issue を作成](https://github.com/colin-nian/cryptobar/issues)してください。
