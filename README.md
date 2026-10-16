# LPlus

LINE向けの独立したiOS Tweakプロジェクト。K2ge3Airのバイナリ、ソース、認証機能は使用しない。

## 現在の段階

まずLINE 26.16.0向けの診断Tweakをビルドする。診断版は機能を変更せず、実機上でクラス・メソッド候補を`Library/Caches/LPlusDiagnostics.log`へ保存する。

## GitHub Actions

Actionsの **Build LPlus diagnostics IPA** を実行し、復号済みLINE IPAを直接返す`https://` URLで入力する。生成された未署名IPAはReleaseに出る。

LiveContainerでは、メインアプリの起動・ログイン確認に使える。通知などのアプリ拡張は別扱いになるため、診断対象はまずLINE本体に限定する。

診断ログを確認してから、広告・おすすめ表示、タブ管理、表示名、確認画面、スタンプコピー、MID検索、設定画面を独立実装する。
