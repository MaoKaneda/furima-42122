const price = () => {
  console.log("price function called");
  
  const priceInput = document.getElementById("item-price");
  const addTaxDom = document.getElementById("add-tax-price");
  const profitDom = document.getElementById("profit");

  console.log("priceInput:", priceInput);
  console.log("addTaxDom:", addTaxDom);
  console.log("profitDom:", profitDom);

  if (priceInput) {
    console.log("Adding event listener to priceInput");
    priceInput.addEventListener("input", () => {
      console.log("Price input changed:", priceInput.value);
      const inputValue = priceInput.value;
      
      if (inputValue >= 300 && inputValue <= 9999999) {
        const commission = Math.floor(inputValue * 0.1);
        const profit = inputValue - commission;
        
        console.log("Commission:", commission);
        console.log("Profit:", profit);
        
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


