const price = () => {
  console.log("price function called");

  const priceInput = document.getElementById("item-price");
  const addTaxDom = document.getElementById("add-tax-price");
  const profitDom = document.getElementById("profit");

  console.log("priceInput:", priceInput);
  console.log("addTaxDom:", addTaxDom);
  console.log("profitDom:", profitDom);

  if (priceInput) {
    priceInput.addEventListener("input", () => {
      console.log("Price input changed:", priceInput.value);
      const inputValue = priceInput.value;
      const tax = Math.floor(inputValue * 0.1);
      const profit = inputValue - tax;

      console.log("Tax:", tax);
      console.log("Profit:", profit);

      addTaxDom.innerHTML = tax;
      profitDom.innerHTML = profit;
    })
  }
};

window.addEventListener("turbo:load", price);
window.addEventListener("turbo:render", price);


