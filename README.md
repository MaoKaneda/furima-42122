## users テーブル

| Column             | Type    | Options                   |
|--------------------|---------|---------------------------|
| nickname           | string  | null: false               |
| email              | string  | null: false, unique: true |
| encrypted_password | string  | null: false               |
| last_name          | string  | null: false               |
| first_name         | string  | null: false               |
| last_name_kana     | string  | null: false               |
| first_name_kana    | string  | null: false               |
| birth_date         | date    | null: false               |

### Association
- has_many :items
- has_many :orders

## items テーブル

| Column           | Type       | Options                        |
|------------------|------------|--------------------------------|
| name             | string     | null: false                    |
| description      | text       | null: false                    |
| category_id      | integer    | null: false                    |
| condition_id     | integer    | null: false                    |
| delivery_fee_id  | integer    | null: false                    |
| prefecture_id    | integer    | null: false                    |
| shipping_day_id  | integer    | null: false                    |
| price            | integer    | null: false                    |
| user             | references | null: false, foreign_key: true |

### Association
- belongs_to :user
- has_one :order

## orders テーブル

| Column  | Type       | Options                        |
|---------|------------|--------------------------------|
| user    | references | null: false, foreign_key: true |
| item    | references | null: false, foreign_key: true |

### Association
- belongs_to :user
- belongs_to :item
- has_one :address

## addresses テーブル

| Column        | Type       | Options                        |
|---------------|------------|--------------------------------|
| postal_code   | string     | null: false                    |
| prefecture_id | integer    | null: false                    |
| city          | string     | null: false                    |
| house_number  | string     | null: false                    |
| building_name | string     |                                |
| phone_number  | string     | null: false                    |
| order         | references | null: false, foreign_key: true |

### Association
- belongs_to :order

## 環境変数の設定

Pay.jp決済機能を使用するために、以下の環境変数を設定してください：

```bash
# Pay.jp API Keys
PAYJP_PUBLIC_KEY=pk_test_your_public_key_here
PAYJP_SECRET_KEY=sk_test_your_secret_key_here

# Basic Auth (for production)
BASIC_AUTH_USER=your_username
BASIC_AUTH_PASSWORD=your_password
```

### 環境変数の設定方法

1. **開発環境の場合**
   ```bash
   export PAYJP_PUBLIC_KEY="pk_test_your_public_key_here"
   export PAYJP_SECRET_KEY="sk_test_your_secret_key_here"
   ```

2. **本番環境の場合**
   - Heroku: `heroku config:set PAYJP_PUBLIC_KEY="pk_live_your_public_key_here"`
   - その他のホスティングサービス: 各サービスの環境変数設定画面で設定

### Pay.jp APIキーの取得方法

1. [Pay.jp](https://pay.jp/) にアカウント登録
2. ダッシュボードでAPIキーを取得
3. テスト用と本番用のキーを適切に使い分け