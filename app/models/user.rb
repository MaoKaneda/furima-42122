class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :items
  has_many :orders

  validates :nickname, presence: { message: 'を入力してください' }
  validates :last_name, presence: { message: 'を入力してください' }, format: { with: /\A[ぁ-んァ-ヶ一-龠々ー]+\z/, message: 'は全角文字で入力してください' }
  validates :first_name, presence: { message: 'を入力してください' }, format: { with: /\A[ぁ-んァ-ヶ一-龠々ー]+\z/, message: 'は全角文字で入力してください' }
  validates :last_name_kana, presence: { message: 'を入力してください' }, format: { with: /\A[ァ-ヶー]+\z/, message: 'は全角カタカナで入力してください' }
  validates :first_name_kana, presence: { message: 'を入力してください' }, format: { with: /\A[ァ-ヶー]+\z/, message: 'は全角カタカナで入力してください' }
  validates :birth_date, presence: { message: 'を選択してください' }
  validates :password, format: { with: /\A(?=.*?[a-z])(?=.*?\d)[a-z\d]+\z/i, message: 'は英字と数字の両方を含めて設定してください' }
end
