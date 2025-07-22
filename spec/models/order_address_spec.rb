require 'rails_helper'

RSpec.describe OrderAddress, type: :model do
  let(:user) { create(:user) }
  let(:item) { create(:item, user: user) }
  let(:order_address) { build(:order_address, user_id: user.id, item_id: item.id) }

  describe 'バリデーション' do
    context '正常系' do
      it '有効である' do
        expect(order_address).to be_valid
      end

      it '建物名が空でも購入できる' do
        order_address.building_name = ''
        expect(order_address).to be_valid
      end
    end

    context '異常系' do
      context '必須項目のバリデーション' do
        it 'postal_codeが空の場合は無効' do
          order_address.postal_code = nil
          expect(order_address).not_to be_valid
          expect(order_address.errors[:postal_code]).to include("can't be blank")
        end

        it 'prefecture_idが空の場合は無効' do
          order_address.prefecture_id = nil
          expect(order_address).not_to be_valid
          expect(order_address.errors[:prefecture_id]).to include("can't be blank")
        end

        it 'cityが空の場合は無効' do
          order_address.city = nil
          expect(order_address).not_to be_valid
          expect(order_address.errors[:city]).to include("can't be blank")
        end

        it 'house_numberが空の場合は無効' do
          order_address.house_number = nil
          expect(order_address).not_to be_valid
          expect(order_address.errors[:house_number]).to include("can't be blank")
        end

        it 'phone_numberが空の場合は無効' do
          order_address.phone_number = nil
          expect(order_address).not_to be_valid
          expect(order_address.errors[:phone_number]).to include("can't be blank")
        end

        it 'user_idが空の場合は無効' do
          order_address.user_id = nil
          expect(order_address).not_to be_valid
          expect(order_address.errors[:user_id]).to include("can't be blank")
        end

        it 'item_idが空の場合は無効' do
          order_address.item_id = nil
          expect(order_address).not_to be_valid
          expect(order_address.errors[:item_id]).to include("can't be blank")
        end

        it 'tokenが空の場合は無効' do
          order_address.token = nil
          expect(order_address).not_to be_valid
          expect(order_address.errors[:token]).to include("can't be blank")
        end
      end

      context 'フォーマットのバリデーション' do
        it 'postal_codeが正しいフォーマットの場合は有効' do
          order_address.postal_code = '123-4567'
          expect(order_address).to be_valid
        end

        it 'postal_codeが不正なフォーマットの場合は無効' do
          order_address.postal_code = '1234567'
          expect(order_address).not_to be_valid
          expect(order_address.errors[:postal_code]).to include('はハイフン(-)を含めて入力してください')
        end

        it 'phone_numberが正しいフォーマットの場合は有効' do
          order_address.phone_number = '09012345678'
          expect(order_address).to be_valid
        end

        it 'phone_numberが9桁以下では購入できない' do
          order_address.phone_number = '090123456'
          expect(order_address).not_to be_valid
          expect(order_address.errors[:phone_number]).to include('は10桁または11桁の数字で入力してください')
        end

        it 'phone_numberが12桁以上では購入できない' do
          order_address.phone_number = '090123456789'
          expect(order_address).not_to be_valid
          expect(order_address.errors[:phone_number]).to include('は10桁または11桁の数字で入力してください')
        end

        it 'phone_numberに半角数字以外が含まれている場合は購入できない' do
          order_address.phone_number = '090-1234-5678'
          expect(order_address).not_to be_valid
          expect(order_address.errors[:phone_number]).to include('は10桁または11桁の数字で入力してください')
        end

        it 'tokenが正しいフォーマットの場合は有効' do
          order_address.token = 'tok_test_valid_token_123'
          expect(order_address).to be_valid
        end

        it 'tokenが不正なフォーマットの場合は無効' do
          order_address.token = ''
          expect(order_address).not_to be_valid
          expect(order_address.errors[:token]).to include("can't be blank")
        end
      end

      context 'prefecture_idのバリデーション' do
        it 'prefecture_idが1の場合は無効' do
          order_address.prefecture_id = 1
          expect(order_address).not_to be_valid
          expect(order_address.errors[:prefecture_id]).to include("を選択してください")
        end

        it 'prefecture_idが2以上の場合は有効' do
          order_address.prefecture_id = 2
          expect(order_address).to be_valid
        end
      end
    end
  end

  describe '#save' do
    context '正常な場合' do
      it 'OrderとAddressが作成される' do
        expect do
          order_address.save
        end.to change(Order, :count).by(1)
                                    .and change(Address, :count).by(1)
      end

      it 'Orderが正しく作成される' do
        order_address.save
        order = Order.last
        expect(order.user_id).to eq(user.id)
        expect(order.item_id).to eq(item.id)
      end

      it 'Addressが正しく作成される' do
        order_address.save
        address = Address.last
        expect(address.postal_code).to eq(order_address.postal_code)
        expect(address.prefecture_id).to eq(order_address.prefecture_id)
        expect(address.city).to eq(order_address.city)
        expect(address.house_number).to eq(order_address.house_number)
        expect(address.building_name).to eq(order_address.building_name)
        expect(address.phone_number).to eq(order_address.phone_number)
        expect(address.order_id).to eq(Order.last.id)
      end
    end

    context 'バリデーションエラーの場合' do
      it 'OrderとAddressが作成されない' do
        order_address.postal_code = 'invalid'
        expect do
          order_address.save
        end.not_to(change { [Order.count, Address.count] })
      end

      it 'falseを返す' do
        order_address.postal_code = 'invalid'
        expect(order_address.save).to be false
      end
    end
  end
end
