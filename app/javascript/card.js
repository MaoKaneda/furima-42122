const pay = () => {
  const chargeForm = document.getElementById('charge-form');
  if (!chargeForm) return;

  if (typeof Payjp === 'undefined') return;

  if (!gon || !gon.public_key) return;

  const payjp = Payjp(gon.public_key);
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

  const numberForm = document.getElementById('number-form');
  const expiryForm = document.getElementById('expiry-form');
  const cvcForm = document.getElementById('cvc-form');

  if (numberForm && expiryForm && cvcForm) {
    numberElement.mount('#number-form');
    expiryElement.mount('#expiry-form');
    cvcElement.mount('#cvc-form');
  } else {
    return;
  }

  chargeForm.addEventListener('submit', (e) => {
    e.preventDefault();

    payjp.createToken(numberElement).then(function(response) {
      if (response.error) {
        return;
      } else {
        const token = response.id;
        const tokenInput = `<input value="${token}" name="token" type="hidden">`;
        chargeForm.insertAdjacentHTML('beforeend', tokenInput);

        numberElement.clear();
        expiryElement.clear();
        cvcElement.clear();

        chargeForm.submit();
      }
    }).catch(function(error) {
      return;
    });
  });
};

// DOMContentLoadedイベントで初期化を実行
document.addEventListener('DOMContentLoaded', pay);

// 念のため、loadイベントでも実行
window.addEventListener('load', pay);

// renderメソッドに対応したイベントを追加
document.addEventListener('turbo:load', pay);
document.addEventListener('turbo:render', pay); 