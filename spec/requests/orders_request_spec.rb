require 'rails_helper'

RSpec.describe 'Orders', type: :request do
  let(:user) { create(:user) }
  let(:item) { create(:item, user: user) }
  let(:other_user) { create(:user) }

  before do
    sign_in user
  end

  describe 'GET /items/:item_id/orders' do
    context '正常な場合' do
      it '購入画面が表示される' do
        get item_orders_path(item)
        expect(response).to have_http_status(:success)
        expect(response.body).to include('購入内容の確認')
      end
    end

    context '異常な場合' do
      it '自分の商品の場合はリダイレクトされる' do
        get item_orders_path(item)
        expect(response).to have_http_status(:success)
      end

      it '既に購入済みの商品の場合はリダイレクトされる' do
        create(:order, item: item, user: other_user)
        get item_orders_path(item)
        expect(response).to redirect_to(root_path)
      end

      it 'ログインしていない場合はリダイレクトされる' do
        sign_out user
        get item_orders_path(item)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'POST /items/:item_id/orders' do
    let(:valid_params) do
      {
        order_address: {
          postal_code: '123-4567',
          prefecture_id: 2,
          city: '横浜市',
          house_number: '青山1-1-1',
          building_name: '柳ビル103',
          phone_number: '09012345678'
        },
        token: 'tok_test_valid_token'
      }
    end

    context '正常な場合' do
      before do
        allow(Payjp::Charge).to receive(:create).and_return(
          double('charge', paid?: true, id: 'ch_test_123', amount: item.price)
        )
      end

      it '決済が成功し、注文が作成される' do
        expect do
          post item_orders_path(item), params: valid_params
        end.to change(Order, :count).by(1)
                                    .and change(Address, :count).by(1)

        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq('購入が完了しました')
      end
    end

    context '異常な場合' do
      context 'バリデーションエラー' do
        let(:invalid_params) do
          {
            order_address: {
              postal_code: 'invalid',
              prefecture_id: 1,
              city: '',
              house_number: '',
              phone_number: 'invalid'
            },
            token: 'invalid_token'
          }
        end

        it 'バリデーションエラーが表示される' do
          post item_orders_path(item), params: invalid_params
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.body).to include('error')
        end
      end

      context 'Pay.jpエラー' do
        before do
          allow(Payjp::Charge).to receive(:create).and_raise(
            Payjp::CardError.new('カードが拒否されました', 'card_declined', 'generic_decline')
          )
        end

        it 'Pay.jpエラーが表示される' do
          post item_orders_path(item), params: valid_params
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.body).to include('カードエラー')
        end
      end

      context 'トークンが無効' do
        before do
          allow(Payjp::Charge).to receive(:create).and_raise(
            Payjp::InvalidRequestError.new('無効なトークンです')
          )
        end

        it 'トークンエラーが表示される' do
          post item_orders_path(item), params: valid_params
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.body).to include('無効なリクエスト')
        end
      end
    end
  end
end
