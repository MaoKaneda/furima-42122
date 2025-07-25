const price = () => {
  const priceInput = document.getElementById("item-price");
  const addTaxDom = document.getElementById("add-tax-price");
  const profitDom = document.getElementById("profit");

  if (priceInput) {
    priceInput.addEventListener("input", () => {
      const inputValue = priceInput.value;
      
      if (inputValue >= 300 && inputValue <= 9999999) {
        const commission = Math.floor(inputValue * 0.1);
        const profit = inputValue - commission;
        
        addTaxDom.innerHTML = commission.toLocaleString();
        profitDom.innerHTML = profit.toLocaleString();
      } else {
        addTaxDom.innerHTML = '';
        profitDom.innerHTML = '';
      }
    });
  }
};

window.addEventListener("turbo:load", price);
window.addEventListener("turbo:render", price);


