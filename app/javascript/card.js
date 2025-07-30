const pay = () => {
  // gonとPayjpが利用可能かチェック
  if (typeof gon === 'undefined' || !gon.public_key) {
    console.error('gonまたはgon.public_keyが利用できません');
    return;
  }

  if (typeof Payjp === 'undefined') {
    console.error('Payjpが利用できません');
    return;
  }

  const publicKey = gon.public_key;
  const payjp = Payjp(publicKey);
  const elements = payjp.elements();
  
  const numberElement = elements.create('cardNumber', {
    placeholder: '4242 4242 4242 4242'
  });
  const expiryElement = elements.create('cardExpiry', {
    placeholder: '12/25'
  });
  const cvcElement = elements.create('cardCvc', {
    placeholder: '123'
  });

  // フォーム要素が存在するかチェック
  const numberForm = document.getElementById('number-form');
  const expiryForm = document.getElementById('expiry-form');
  const cvcForm = document.getElementById('cvc-form');
  const form = document.getElementById('charge-form');

  if (!numberForm || !expiryForm || !cvcForm || !form) {
    console.error('必要なフォーム要素が見つかりません');
    return;
  }

  // 既存の要素をクリア
  numberForm.innerHTML = '';
  expiryForm.innerHTML = '';
  cvcForm.innerHTML = '';

  numberElement.mount('#number-form');
  expiryElement.mount('#expiry-form');
  cvcElement.mount('#cvc-form');

  console.log('Pay.jp要素をマウントしました');

  form.addEventListener("submit", (e) => {
    e.preventDefault();
    console.log('フォーム送信開始');

    payjp.createToken(numberElement).then(function (response) {
      if (response.error) {
        console.error('トークン生成エラー:', response.error);
        alert('カード情報に誤りがあります。');
      } else {
        console.log('トークン生成成功:', response.id);
        const token = response.id;
        const renderDom = document.getElementById("charge-form");
        const tokenObj = `<input value="${token}" name="token" type="hidden">`;
        renderDom.insertAdjacentHTML("beforeend", tokenObj);
        
        numberElement.clear();
        expiryElement.clear();
        cvcElement.clear();
        document.getElementById("charge-form").submit();
      }
    }).catch(function(error) {
      console.error('Pay.jpエラー:', error);
      alert('カード情報の処理中にエラーが発生しました。');
    });
  });
};

// 複数のイベントで初期化を試行
window.addEventListener("turbo:load", pay);
window.addEventListener("turbo:render", pay);
window.addEventListener("DOMContentLoaded", pay); 