const price = () => {
  const priceInput = document.getElementById("item-price");
  const addTaxDom = document.getElementById("add-tax-price");
  const profitDom = document.getElementById("profit");

  // 必要な要素が存在しない場合は処理を終了
  if (!priceInput || !addTaxDom || !profitDom) {
    return;
  }

  priceInput.addEventListener("input", () => {
    const inputValue = priceInput.value;
    const tax = Math.floor(inputValue * 0.1);
    const profit = inputValue - tax;

    addTaxDom.innerHTML = tax;
    profitDom.innerHTML = profit;
  })
};
 
window.addEventListener("turbo:load", price);
window.addEventListener("turbo:render", price);