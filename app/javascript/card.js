// 初期化フラグ
let isInitialized = false;

const pay = () => {
  // 既に初期化済みの場合は何もしない
  if (isInitialized) {
    console.log('既に初期化済みです');
    return;
  }
  
  // DOMが完全に読み込まれているかチェック
  if (document.readyState === 'loading') {
    console.log('DOMがまだ読み込み中です');
    return;
  }
  
  console.log('=== card.js 初期化開始 ===');
  
  // 必要な要素の存在確認
  const chargeForm = document.getElementById('charge-form');
  if (!chargeForm) {
    console.log('charge-formが見つかりません');
    console.log('document.readyState:', document.readyState);
    console.log('現在のURL:', window.location.href);
    console.log('フォーム要素の確認:');
    const forms = document.querySelectorAll('form');
    forms.forEach((form, index) => {
      console.log(`フォーム${index}: id="${form.id}", class="${form.className}"`);
    });
    return;
  }
  
  // Payjpライブラリの確認
  if (typeof Payjp === 'undefined') {
    console.error('Payjpライブラリが読み込まれていません');
    return;
  }
  
  try {
    // gonから公開鍵を取得
    if (!gon || !gon.public_key) {
      console.error('gon.public_keyが設定されていません');
      return;
    }
    
    const payjp = Payjp(gon.public_key);
    const elements = payjp.elements();
    
    console.log('Payjpライブラリ確認完了');
    
    // カード入力フィールドの作成
    const numberElement = elements.create('cardNumber', {
      placeholder: '4242 4242 4242 4242'
    });
    
    const expiryElement = elements.create('cardExpiry', {
      placeholder: '12/25'
    });
    
    const cvcElement = elements.create('cardCvc', {
      placeholder: '123'
    });
    
    // 要素のマウント
    const numberForm = document.getElementById('number-form');
    const expiryForm = document.getElementById('expiry-form');
    const cvcForm = document.getElementById('cvc-form');
    
    if (numberForm && expiryForm && cvcForm) {
      numberElement.mount('#number-form');
      expiryElement.mount('#expiry-form');
      cvcElement.mount('#cvc-form');
      console.log('カード入力フィールドのマウント完了');
    } else {
      console.error('カード入力フィールドの要素が見つかりません');
      console.log('要素確認:', {
        numberForm: !!numberForm,
        expiryForm: !!expiryForm,
        cvcForm: !!cvcForm
      });
      return;
    }
    
    // フォーム送信時の処理
    chargeForm.addEventListener('submit', (e) => {
      console.log('フォーム送信開始');
      console.log('フォームデータ:', new FormData(chargeForm));
      e.preventDefault();
      
      payjp.createToken(numberElement).then(function(response) {
        if (response.error) {
          console.error('Pay.jpエラー:', response.error);
        } else {
          console.log('トークン作成成功:', response.id);
          
          // トークンをフォームに追加
          const token = response.id;
          const tokenInput = `<input value="${token}" name="token" type="hidden">`;
          chargeForm.insertAdjacentHTML('beforeend', tokenInput);
          
          console.log('トークン追加完了:', token);
          console.log('最終フォームデータ:', new FormData(chargeForm));
          
          // 入力フィールドをクリア
          numberElement.clear();
          expiryElement.clear();
          cvcElement.clear();
          
          // フォームを送信
          chargeForm.submit();
        }
      }).catch(function(error) {
        console.error('トークン生成エラー:', error);
      });
    });
    
    // 初期化完了フラグを設定
    isInitialized = true;
    console.log('=== card.js 初期化完了 ===');
    
  } catch (error) {
    console.error('Pay.jp初期化エラー:', error);
  }
};

// DOMContentLoadedイベントで初期化を実行
document.addEventListener('DOMContentLoaded', pay);

// 念のため、loadイベントでも実行
window.addEventListener('load', pay); 